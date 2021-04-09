%% SiemensPulsRespdataToBIDS_NoHeader_DCMAcqTime_VASO
% % last adapted by Judith Eck 2021-03-04
% Version for .puls and .resp files with only 4 numbers before data acquisition starts and one footer
% and 5000 as trigger for peak and 6000 as ?
% example data set: VASO data Alessandra
% (VASO_124_V1_template_TR5_4.9KERNEL_5000regul_E00_M)
%%
clear
clc

%% Import Data
% .puls, .resp, .fmr, .dcm/.ima
 
[tempfile, tempdir] = uigetfile({'*.puls;*.resp','Physiorecordings (*.puls,*.resp)'}, 'Select the Physiorecordings of a Single Run (*.puls and/or *.resp)', 'MultiSelect', 'on');
tempfile = cellstr(tempfile);
[fmrifile,fmridir] = uigetfile({'*.fmr'},'Select FMR File of corresponding fMRI dataset');
[dcmname, dcmdir] = uigetfile({'*.dcm';'*.IMA'}, 'Select all Volumes of that RUN ( _.DCM,_.IMA)','MultiSelect', 'on');
dcmname = cellstr(dcmname);

%% Collect Imaging Information
% get all the required information from the fMRI data:
% acquisition times of all volumes, acquisition time of first volume in FMR, No of Volumes

dcmname = sort(dcmname); % sort the dcm file names ascending
% save the volume acquistion time of each dicom in VolAcqTimes
for c = 1:length(dcmname)
    dcm = dicominfo([dcmdir, dcmname{1,c}]);
    VolAcqTimes{c} = dcm.AcquisitionTime;
end

% shift the dicom acquisition time to the the k-space center
shift = input(['If you would like to shift the temporal sampling of the physiological data trace to the k-space center, \n',  ...
    'please provide the temporal delay between readout start and k-space center in msec, e.g. 1042.5: ']);
if isempty(shift)
    shift = 0;
end

% open BV FMR file to check acquisition time of 1st volume used in that run
% and to extract the number of volumes used for FMR creation
fid = fopen([fmridir fmrifile]); 
FMR = textscan(fid, '%s'); FMR = FMR{1};
AcquisitionTime = str2double(FMR(find(ismember(FMR,'AcqusitionTime:'))+1)); % Acquisition time of first NON-Skipped volume in FMR
NoVols = str2double(FMR(find(ismember(FMR,'NrOfVolumes:'))+1)); % no of volumes in run


% DICOM time to MDH conversion (MDH time is expressed in msec after
% midnight)
temp = strfind(VolAcqTimes, num2str(AcquisitionTime)); % find the image that was used as first volume in the FMR
temp = find(~cellfun('isempty', temp)); % get the index of that volume in the list of VolAcqTimes
VolAcqTimes = VolAcqTimes(temp:end); % delete all volumes acquired before the first FMR volume from the list of dcm acquisition times
clear temp
% start the conversion to MDH time
for i = 1 : length(VolAcqTimes)
    temp = VolAcqTimes{i};
    StartMDHVol(i) = (str2num(temp(1:2)) * 60  * 60  * 1000)...
      + (str2num(temp(3:4))  * 60 * 1000)...
      + (str2num(temp(5:6)) * 1000)...
      + (str2num(temp(8:11))/10);
  clear temp
end

% apply the temporal shift to sample k-space center
StartMDHVol = StartMDHVol + shift;

clear temp clear AcquisitionTime fid FMR ind i


%% Read *.puls and/or *.resp data

% 5000 - represents trigger of peak
% 6000 - represents trigger of ?
% 5003 - indicates start of footer
% 6003 - indicates end of footer
% physio traces, 12 Bits (0-4095)


for i = 1 : length(tempfile)
    % read the log file of the physio-recording and strip the header
    fid = fopen([tempdir tempfile{i}]);
    read = textscan(fid, '%s');
    tempcell = read{1};
    data = str2double(tempcell);
    data(1:4) = []; % delete first 4 numbers (acquisition parameters)
    
    ind = find(data == 5003 | data == 6003); % 5003 footer starts, 6003 footer ends
    data(ind(1):ind(2)) = []; % delete the footer
    data(data == 5000) = []; % delete all triggers of peak
    data(data == 6000) = []; % delete all triggers?
    % data(isnan(data)) = [];

    % start time of physiological recording
    StartMDH = str2double(tempcell(find(ismember(tempcell,'LogStartMDHTime:'))+1)); 
    if isempty(StartMDH)
        disp('The start time of the physiological recording is not defined in the file!')
    end
    
    % stop time of physiological recording
    StopMDH = str2double(tempcell(find(ismember(tempcell,'LogStopMDHTime:'))+1)); 
    if isempty(StopMDH)
        disp('The stop time of the physiological recording is not defined in the file!')
    end
    
    % calculate timing/sampling parameters from raw physiological logfile
    LogDuration = StopMDH - StartMDH; % in msec
    SampleRate = LogDuration/(length(data)-1)/1000; %in sec
    Hz = (1/SampleRate); %Hz = 50; %( 50 data points a second, 1/50 or every 0.02 sec or every 20 msec)
    DataTimeStamps = (StartMDH : SampleRate*1000 : StopMDH)'; % in msec

    %% Save information about physiological data
    % Save all neccessary information in Matlab data structure
    
    if strcmp(tempfile{i}(end-3:end),'resp') 
        Resp.StartMDH = StartMDH;
        Resp.StopMDH = StopMDH;
        Resp.Hz = Hz;
        Resp.SampleRate = SampleRate;
        Resp.LogDuration = LogDuration;
        Resp.DataTimeStamps = DataTimeStamps;
        Resp.Data = data;
        save ([fmridir fmrifile(1:end-4) '_resp.mat'], 'Resp');
        col = '["respiratory", "trigger"]';
        json = [fmridir fmrifile(1:end-4) '_resp.json'];
        tsv = [fmridir fmrifile(1:end-4) '_resp.tsv'];
    elseif strcmp(tempfile{i}(end-3:end),'puls')
        Puls.StartMDH = StartMDH;
        Puls.StopMDH = StopMDH;
        Puls.Hz = Hz;
        Puls.SampleRate = SampleRate;
        Puls.LogDuration = LogDuration;
        Puls.DataTimeStamps = DataTimeStamps;
        Puls.Data = data; 
        save ([fmridir fmrifile(1:end-4) '_puls.mat'], 'Puls');
        col = '["cardiac", "trigger"]';
        json = [fmridir fmrifile(1:end-4) '_puls.json'];
        tsv = [fmridir fmrifile(1:end-4) '_puls.tsv'];
    else
        disp('Unexpected Error!')
    end
    

    %% Link physiological data trace with timing information of imaging data
 
    % Calculate the Trigger Locations with respect to the Physiological Recordings
    for v = 1: NoVols
        [minValVol(v),VolumeIdx(v)] = min(abs(DataTimeStamps-StartMDHVol(v))); % VolumeIdx represents the volume (scanner) trigger indices + specified time shift for the physiological vector
    end
      
    % Save Physio Data with Trigger Information in BIDS Format
    StartTime = (StartMDH-StartMDHVol)/1000;
    trigger = zeros(size(data));
    trigger(VolumeIdx) = 1;
    
    fileID = fopen(json,'w');
    fprintf(fileID,'%s\n','{');
    fprintf(fileID,'%s %.2f%s\n','"SamplingFrequency":',Hz,',');
    fprintf(fileID,'%s %.3f%s\n','"StartTime":',StartTime,',');
    fprintf(fileID,'%s %s\n','"Columns":',col);
    fprintf(fileID,'%s','}');
    fclose(fileID);
    
    dlmwrite(tsv,[data, trigger],'delimiter','\t','precision','%i');
    gzip(tsv,fmridir);
    delete(tsv);
    
    clear col counter data DataTimeStamps fid fileID Hz idxcounter ind json LogDuration MinValSli minValVol Puls Resp read s SampleRate SliceIdx StartMDH StartTime StopMDH tempcell trigger tsv v VolumeIdx
end
