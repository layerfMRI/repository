clc, clearvars, close all;

%Parameters
TR = 29; 
max_flip_angle_1 = 50;  max_flip_angle_2 = 50;

Inv_flip_angle = 180;
NumTR = 124; 
NumAcq = 1;
RelaxDelay = 0;
InvPulse = 1;
InvDelay = 200;
RdIp = RelaxDelay + InvPulse;
RdIpId = RelaxDelay + InvPulse + InvDelay;
Single_Acq_Time = NumTR * TR;
Total_Acq_Time = NumTR * TR * NumAcq + RdIpId;
MzG=zeros(1,Total_Acq_Time); MzW=zeros(1,Total_Acq_Time);
MxG=zeros(1,Total_Acq_Time); MxW=zeros(1,Total_Acq_Time);

%Flip angles calculation

FA=zeros(1,Total_Acq_Time);

for r = 1 : max_flip_angle_1
        Flip_angle_1 = r; 

    for s = 1 : max_flip_angle_2
        Flip_angle_2 = s; 

FA(1) = Flip_angle_1;
    
        for i=TR + 1 : TR : Single_Acq_Time

            if i >= TR + 1 & i < Single_Acq_Time/2
           FA(i) = Flip_angle_1;
            end

            if i > Single_Acq_Time/2 & i < Single_Acq_Time
           FA(i) = Flip_angle_2;
            end
                i = i + TR;

         end


%Mz Mx calculation

T1G = 1800; T1W = 1100;
Mz_postInv_G = 1-(1-(-1))*exp(-200/T1G);
Mz_postInv_W = 1-(1-(-1))*exp(-200/T1W);

MzG(1) = Mz_postInv_G; MzW(1) = Mz_postInv_W;
MxG(1) = MzG(1) * sind(FA(1));
MxW(1) = MzW(1) * sind(FA(1));

% Gray matter calculation

increment_G= 1;
        for i=2:length(MzG)
        MzG(i) = 1-(1-(MzG(i-1)))*exp(-increment_G/T1G);

        MxG(i) = MzG(i) * sind(FA(i));
        MzG(i) = MzG(i) * cosd(FA(i));
    
        end

% White matter calculation

increment_W= 1;
        for i=2:length(MzW)
        MzW(i) = 1-(1-(MzW(i-1)))*exp(-increment_W/T1W);

        MxW(i) = MzW(i) * sind(FA(i));
        MzW(i) = MzW(i) * cosd(FA(i));
    
        end


% Remove gaps from Mx graph
MxG_noGap = zeros(1, NumAcq * NumTR);
MxG_noGap(1) = MxG(1);
increment_ng_G = 2;

        for i=TR + 1: TR : Single_Acq_Time
  
        MxG_noGap(increment_ng_G) =  MxG(i);
        increment_ng_G = increment_ng_G + 1 ;
  
        end 

        for i=Single_Acq_Time + RdIpId + 1: TR : Total_Acq_Time
  
        MxG_noGap(increment_ng_G) =  MxG(i);
        increment_ng_G = increment_ng_G + 1 ;
  
        end

MxW_noGap = zeros(1, NumAcq * NumTR);
MxW_noGap(1) = MxW(1);
increment_ng_W = 2;

        for i=TR + 1 : TR : Single_Acq_Time
  
        MxW_noGap(increment_ng_W) =  MxW(i);
        increment_ng_W = increment_ng_W +1 ;
  
        end 

        for i=Single_Acq_Time + RdIpId + 1: TR : Total_Acq_Time 
  
        MxW_noGap(increment_ng_W) =  MxW(i);
        increment_ng_W = increment_ng_W + 1 ;
  
        end
%CNR
    
        for k = 1 : NumTR/2

        CN_all(k) = abs(MxG_noGap(k)/MxG_noGap(k + NumTR/2) - MxW_noGap(k)/MxW_noGap(k + NumTR/2)) / sqrt((1/MxG_noGap(k + NumTR/2))^2 + (-MxG_noGap(k)/MxG_noGap(k + NumTR/2)^2)^2 + (-1/MxW_noGap(k + NumTR/2))^2 + (MxW_noGap(k)/MxW_noGap(k + NumTR/2)^2)^2);
        k = k + 1;

        end

        CNR_avg = sum(CN_all)/length(CN_all);
%Table
        CNR_table(r,s) = CNR_avg;

    end

end

max_value = max(CNR_table,[],"all");
[tabl_row,tabl_col] = find(CNR_table==max_value);
z = ['TI-1 flip angle: ', num2str(tabl_row), '          TI-2 flip angle: ', num2str(tabl_col)];

disp(z)

%3D graph

figure; clf;
xlabel('TI(1) flip angle')
ylabel('TI(2) flip angle')
zlabel('CNR')
hold on
surf(CNR_table')
scatter3(tabl_row, tabl_col, max_value, 50, 'filled', 'r')    % 50 is size of red dot
daspect([1,1,.001]);axis tight;
OptionZ.FrameRate=30;OptionZ.Duration=15.5;OptionZ.Periodic=true;
CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], 'CNR_average_3D_TR29_video',OptionZ) 

view(-9, 38)
colorbar
