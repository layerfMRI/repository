clc, clearvars, close all;

% update TR, , number of TR and flip angles
% add Mz_postInv_W formula

NumTR = 124; % 120 previously
TR = 36; % msec, 36 previously

Acq_Time = NumTR*TR;
MzG=zeros(1,Acq_Time); MzW=zeros(1,Acq_Time);
MxG=zeros(1,Acq_Time); MxW=zeros(1,Acq_Time);
FA=zeros(1,Acq_Time);
Flip_angle_1 = 15;  Flip_angle_2 = 10; % 10 and 20 previously
FA(1) = Flip_angle_1;

for i=TR + 1 : TR : Acq_Time/2
    FA(i) = Flip_angle_1;
    i = i + TR;
end

for i = Acq_Time/2 + 1 : TR : Acq_Time
    FA(i) = Flip_angle_2;
    i = i + TR;
end

T1G = 1800; T1W = 1100;
Mz_postInv_G = 1-(1-(-1))*exp(-200/T1G);
Mz_postInv_W = 1-(1-(-1))*exp(-200/T1W);

MzG(1)=Mz_postInv_G; MzW(1)=Mz_postInv_W;
MxG(1) = MzG(1) * sind(FA(1));
MxW(1) = MzW(1) * sind(FA(1));

% Gray matter calculation
increment = 1;
for i=2:length(MzG)
MzG(i) = 1-(1-(MzG(i-1)))*exp(-increment/T1G);

MxG(i) = MzG(i) * sind(FA(i));
MzG(i) = MzG(i) * cosd(FA(i));
end

% White matter calculation
for i=2:length(MzW)
MzW(i) = 1-(1-(MzW(i-1)))*exp(-increment/T1W);

MxW(i) = MzW(i) * sind(FA(i));
MzW(i) = MzW(i) * cosd(FA(i));
end

% Remove gaps from Mx graph
MxG_noGap = zeros(1,NumTR);
increment = 2;
MxG_noGap(1) = MxG(1);

for i=TR+1:TR:Acq_Time 
  
    MxG_noGap(increment) =  MxG(i);
    increment = increment +1 ;
  
end 

MxW_noGap = zeros(1,NumTR);
increment = 2;
MxW_noGap(1) = MxW(1);

for i=TR+1:TR:Acq_Time 
  
    MxW_noGap(increment) =  MxW(i);
    increment = increment +1 ;
  
end 
%Graph
subplot(1,2,1)
plot(1:length(MxG_noGap),MxG_noGap), xlabel('Number of TR'), ylabel('Mx')
hold on
plot(1:length(MxW_noGap),MxW_noGap), xlabel('Number of TR'), ylabel('Mx')
legend('Grey Matter', 'White Matter', 'Location', 'southeast' )


subplot(1,2,2)
plot(1:length(MzG),MzG), xlabel('Millisecond'), ylabel('Mz')
hold on
plot(1:length(MzW),MzW), xlabel('Millisecond'), ylabel('Mz')
hold on
yline(0)
legend('Grey Matter', 'White Matter', 'Location', 'southeast' )
