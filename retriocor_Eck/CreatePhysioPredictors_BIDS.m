%% Import .json and tsv.gz physiological recordings that follow BIDS standard as well as the corresponding FMR

% create RETROICOR SDM predictors based on the method proposed by Glover:
% Glover, G. H., Li, T.-Q., & Ress, D. (2000). Image-based method for retrospective correction of physiological motion effects in fMRI: RETROICOR. Magnetic Resonance in Medicine, 44(1), 162?167. https://doi.org/10.1002/1522-2594(200007)44:1<162::AID-MRM23>3.0.CO;2-E
% In addition SDM files with the filtered physio data traces are saved 
% last changed by Judith Eck, 2019-09-10

clear
clc

% save the script name and the date the script was changed last in the
% ouptut file
p = mfilename('fullpath');
file = dir([p, '.m']);
physio.scriptname = file.name;
physio.scriptdate = file.date;

clear p file

% PLEASE NOTE the Physio.tsv.gz file should take the number of skipped volumes
% during FMR creation into account (and hence should not include any
% triggers for these skipped volumes). Also the "StartTime" in the JSON
% file should be computed with respect to the 1st non-skipped volume

% Definition of RETROICOR model
% number of harmonics based on Harvey, A. K., Pattinson, K. T. S., Brooks, J. C. W., Mayhew, S. D., Jenkinson, M., & Wise, R. G. (2008). Brainstem functional magnetic resonance imaging: Disentangling signal from physiological noise. Journal of Magnetic Resonance Imaging, 28(6), 1337?1344. https://doi.org/10.1002/jmri.21623
order_c = 3; %number of cardiac harmonics (based on brainstem imaging), change order if needed
order_r = 4; %number of respiratory harmonics (based on brainstem imaging), change order if needed
order_cr = 1; % number of multiplicative harmonics (based on brainstem imaging)

% cutoff frequencies in Hz for zero-phase second-order bandpass butterworth
% filter of the cardiac signal, default values taken from Elgendi et al.,
% 2013
cardiac_low = 0.5;
cardiac_high = 8;

% cutoff frequency in Hz for zero-phase second-order lowpass butterworth
% filter of the respiratory signal, default value taken from Elgendi et al.,
% 2013
resp_high = 2;

% Save current date in output file
physio.currentdate = today('datetime');

%% Read in all necessary files, i.e. .json, .tsv.gz, .fmr
[jsonfile,jsondir] = uigetfile('*.json', 'Select the JSON File of the Physiorecordings of a Single Run');
[tsvgzfile,tsvgzdir] = uigetfile('*.tsv.gz', 'Select the corresponding TSV.GZ File with the Recordings');
temptsv = gunzip([tsvgzdir, tsvgzfile]);
[fmrifile,fmridir] = uigetfile({'*.fmr'},'Select FMR File of corresponding fMRI dataset');


%% Import keydata from .json file
alltext = fileread([jsondir jsonfile]);

strsampling='"SamplingFrequency":';
strstart='"StartTime":';
strcolumns='"Columns":';

% Save Sampling Frequency in variable 'sampling'
ind = strfind(alltext, strsampling);
assert(~isempty(ind), 'The sampling frequency of the data is not defined in the file!');
physio.sampling = sscanf(alltext(ind(1) + length(strsampling):end), '%g');
clear ind

% Save Start Time in variable 'startsec'
ind = strfind(alltext, strstart);
assert(~isempty(ind),'The start time of the physiological recording is not defined in the file!');
physio.startsec = sscanf(alltext(ind(1) + length(strstart):end), '%g');

% Save Column Headers of the physiological recording in 'colheader'
ind = strfind(alltext, strcolumns);
assert(~isempty(ind),'The column headers of the physiological recording saved in the tsv file are not defined!');
indstart = strfind(alltext(ind(1):end),'[');
indend = strfind(alltext(ind(1):end),']');
colheader = strsplit(alltext(ind(1) + indstart+1 : ind(1)+indend-2), {', ',',','"'});
colheader = strtrim(colheader);
physio.colheader = colheader(~cellfun('isempty',colheader));


%% Import physiological data from .tsv.gz file
physio.data = dlmread(temptsv{1});
delete(temptsv{1});
clear temptsv
physio.NoOfTriggerIntervals = sum(diff([0; physio.data(:,end)]) == 1); % number of trigger start times

clearvars -except physio *dir *file order* cardiac_low cardiac_high resp_high


%% Import timing parameters from corresponding FMR project
fid = fopen([fmridir fmrifile]);
FMR = textscan(fid, '%s'); FMR = FMR{1};

physio.TR = str2double(FMR(find(ismember(FMR,'TR:'))+1)); % TR of dataset
physio.NoVols = str2double(FMR(find(ismember(FMR,'NrOfVolumes:'))+1)); % no of volumes in run
physio.NoSlices = str2double(FMR(find(ismember(FMR,'NrOfSlices:'))+1)); % no of slices in run
physio.SliceTimingTableSize = str2double(FMR(find(ismember(FMR,'SliceTimingTableSize:'))+1)); % indicating whether slice acquisition times have been saved in FMR


% Check whether the number of slice acquistion times saved in the FMR
% corresponds to the number of slices per volume
if physio.SliceTimingTableSize == physio.NoSlices
    ind = find(ismember(FMR,'SliceTimingTableSize:'));
    physio.SliceTable = str2double(FMR(ind+2 : ind+1+physio.NoSlices)); % save slice acquisition times
else
    disp('No Slice Acquisition Information Saved in Slice Timing Table');
    %physio.SliceTable = input('Please specify the slice acquisition times relative to the volume onset in msec , e.g. [0; 452.5; 905; 352.5]:   ');
    physio.SliceTable = [];
end

% if it is a MB sequence several slices have been acquired at the same
% time, so only unique entries from the SliceTimeTable will be used
physio.SliceTimes = unique(physio.SliceTable);

clearvars -except physio order* fmridir fmrifile cardiac_low cardiac_high resp_high

% Get Time Stamps of Physio Data and the Trigger times
timestamps = (physio.startsec : 1/physio.sampling : physio.startsec + 1/physio.sampling*(length(physio.data)-1))'; % create a time vector of the same length as data in sec
physio.timestampsinms = timestamps*1000; % save the time stamps in msec of the physio data in the physio structure with 0 being the start of the run
trigind = find(physio.data(:,end)); % find the trigger indices in the data trace
% Determine Nyquist frequency for filtering the data
nyq_freq = physio.sampling/2; % Nyquist frequency



%% Extract trigger locations
trig_startsli_ind = find(diff([0; physio.data(:,end)]) == 1); % sometimes (e.g for the CMRR Sequence) there are 1s written for the entire time a slice acquisition is on and not just for the start of a slice/volume, by finding all indices in the last physio.data column where the data trace changes from 0 to 1, it is possible identify just the bebinning of the slice/volume acquisition


%% Check whether both pulse and respiration data is available
pulse_col = find(contains(physio.colheader, 'card'));
resp_col = find(contains(physio.colheader, 'resp'));

%% make sure that the data is double (for filtering)
physio.data = double(physio.data);


%% If Cardiac Data exists start to analyze it
if ~isempty(pulse_col)
    % check input signal
    assert(~any(isnan(physio.data(:,pulse_col))), 'Nan values in the cardiac signal');
    
    %% Plotting Cardiac Raw Data
    figurerawpulse = figure('Units', 'Normalized', 'OuterPosition', [0.5, 0.5, 0.5, 0.5]);
    vax = axes;
    plotraw = plot(timestamps,physio.data(:,pulse_col));
    hold;
    title(physio.colheader{pulse_col});
    xlabel('Seconds');
    startscan = plot([timestamps(trigind(1)) timestamps(trigind(1))],get(vax,'YLim'),'Color',[1 0 0]);
    uistack(startscan,'bottom')
    endscan = plot([timestamps(trigind(end)) timestamps(trigind(end))],get(vax,'YLim'),'Color',[1 0 0]);
    uistack(endscan,'bottom')
    
    
    
    %% SYSTOLIC PEAK DETECTION based on:
    % Elgendi M, Norton I, Brearley M, Abbott D, Schuurmans D. Systolic peak detection in acceleration photoplethysmograms measured from emergency responders in tropical conditions. PLoS ONE. 2013;8(10):76585. doi: 10.1371/journal.pone.0076585
    % Three-Stage method to get indices of systolic peaks:
    % 1. Preprocessing (bandpass filtering and squaring)
    % 2. Feature extraction (generating potential blocks using two moving averages)
    % 3. Classification (thresholding)
    
    % 1. Preprocessing -  zero-phase second-order Butterworth filter, with bandpass 0.5 - 8 Hz
    % to remove the baseline wander and high frequencies that do not contribute to the systolic peaks
    % and clipping the output by keeping the signal above zero
    % For digital filters, the cutoff frequencies must lie between 0 and 1,
    % where 1 corresponds to the Nyquist rate (half the sample rate)
    [b, a] = butter(2, [cardiac_low/nyq_freq cardiac_high/nyq_freq], 'bandpass'); % order = 2, normalized cut-off frequency between 0 & 1 (1 = nyquist freq), typ: bandpass
    pulse_prep = filtfilt(b,a,physio.data(:,pulse_col)); % filtfilt performs zero-phase digital filtering
    filt_pulse = pulse_prep;
    clear b a
    
    figurerawpulse;
    plotfilt =  plot(timestamps,filt_pulse+mean(physio.data(:,pulse_col)),'c');
    plotfilt.Color(4) = 0.4;
    
    % clip to ouput signal > 0
    pulse_prep(pulse_prep<0) = 0;
    % squaring the signal (Squaring emphasises the large differences resulting
    % from the systolic wave, which suppressing the small differences arising from the diastolic wave and noise)
    pulse_prep = pulse_prep.^2;
    
    % 2. Feature extraction
    % Blocks of interest are generated using two event-related moving averages that demarcate the systolic and heartbeat areas.
    w1 = 111; % in ms (window size of one systolic peak duration)
    w1_norm = round(w1/(1/physio.sampling*1000)); % number of data points in physio vector based on w1 (round to next integer)
    w2 = 667; % in ms (window size of one beat duration)
    w2_norm = round(w2/(1/physio.sampling*1000)); % number of data points in physio vector based on w2 (round to next odd integer)
    % 1st moving average - emphasizing the systolic peak area in the signal
    MApeak = movmean(pulse_prep,w1_norm);
    % 2nd moving average - emphasizing the beat area to be used as a threshold for the first moving average
    MAbeat = movmean(pulse_prep,w2_norm);
    
    % 3. Thresholding
    % The equation that determines the offset level beta is based on a brute force search
    % THR1 is equal to MAbeat + a small offset
    beta = 0.02; % offset level
    THR1 = MAbeat + beta*mean(pulse_prep); % thresholding
    % generate block variable with indices that contain possible peaks in
    % pulse_prep (1 = true), (0 = false)
    blocks = MApeak > THR1;
    % get onsets, offset and durations of blocks of interest
    onset = find(diff(blocks)== 1)+1;
    offset = find(diff(blocks)== -1);
    if onset(1) > offset(1) % if the onset of the peak was not recorded
        onset = [1;onset];
    end
    if length(onset) > length(offset) % if the offset of the peak was not recorded
        offset(end+1) = length(blocks);
    end
    duration = offset-onset+1;
    % set second Threshold to size of standard PEAK duration w1_norm
    THR2 = w1_norm;
    % get the indices of the pulse peaks as well as the pulse values
    peaks_ind = [];
    peaks_val = [];
    for j = 1 : length(duration)
        if duration(j) >= THR2
            [val,ind] = max(physio.data(onset(j) : offset(j),pulse_col));
            ind = ind + onset(j)-1;
            peaks_val = [peaks_val physio.data(ind,pulse_col)];
            peaks_ind = [peaks_ind ind];
        end
    end
    clear j
    physio.pulsepeaks_ind = peaks_ind; % save the indices (within the timestampsinmsec and the data vector) of the identified peaks in the physio structure
    % get the peaks within the functional scan
    peaks_ind_run = peaks_ind(peaks_ind>=trigind(1)& peaks_ind<=trigind(end));
    
    % plot the identified peaks in original raw data
    figurerawpulse;
    plotpeaks = plot(timestamps(peaks_ind),physio.data(peaks_ind,pulse_col),'r.', 'MarkerSize', 12);
    plotpeaksrun = plot(timestamps(peaks_ind_run),physio.data(peaks_ind_run,pulse_col),'g.', 'MarkerSize', 12);
    leg = legend([startscan plotraw plotfilt plotpeaks plotpeaksrun], 'run length', 'raw data', 'filtered data', 'peaks', 'peaks within run');
    set(leg, 'TextColor', [0 0 0],'Location','North', 'FontSize', 8,  'Orientation','horizontal');
    print(figurerawpulse,'-dpng','-r600',[fmridir, fmrifile(1:end-4),'_RawPulse.png']);
    savefig(figurerawpulse,[fmridir, fmrifile(1:end-4),'_RawPulse.fig']);
    
    %%% Cardiac Phase Based on Systolic Peaks
    cardiac_phase = zeros(length(physio.data),1);
    for t=1:length(physio.data)
        if t < peaks_ind(1) || t >= peaks_ind(end)
            cardiac_phase(t) = NaN;
        else
            prev_peak = find(peaks_ind <=t, 1, 'last');
            t1 = peaks_ind(prev_peak);
            t2 = peaks_ind(prev_peak+1);
            cardiac_phase(t) = 2*pi*(t - t1)/(t2-t1); % phase coded between 0 and 2pi (see Glover et al., 2000)
            clear t1 t2
        end
    end
    clear t
    
    %% Create SDM with Pulse Predictors
    % fit Xth order fourier series to estimate phase
    % generate Volume-Based Values
    % check whether slice-based or volume-based triggers are used in the
    % TSV.GZ file
    temp = physio.NoOfTriggerIntervals/physio.NoVols;
    if temp < 1
        disp('There is not for every recorded volume a trigger saved in the TSV file!')
        return
    elseif temp == 1 % only volume triggers saved in physio.data
        cardiac_phase_vol = cardiac_phase(trig_startsli_ind); % phase values
        filt_cardiac_vol = filt_pulse(trig_startsli_ind); % raw pulse values
    elseif temp > 1 % slice triggers saved in physio.data
        cardiac_phase_vol = cardiac_phase(trig_startsli_ind(1:temp:end)); % sample the start of the volume
        %cardiac_phase_vol = cardiac_phase(trig_startsli_ind(round(temp/2):temp:end)); % sample the middle of the volume
        filt_cardiac_vol = filt_pulse(trig_startsli_ind(1:temp:end)); % sample the start of the volume
        %filt_cardiac_vol = filt_pulse(trig_startsli_ind(round(temp/2):temp:end));
    end
    clear temp
    
    if order_c > 0
        for i = 1:order_c
            dm_phs_c(:,(i*2)-1) = cos(i*cardiac_phase_vol);
            dm_phs_c(:,i*2) = sin(i*cardiac_phase_vol);
        end
        clear i
        
        
        % Save Cardiac RETROICOR Predictors
        sdm = xff ('new:sdm');
        sdm.NrOfPredictors = (order_c*2)+1;
        sdm.NrOfDataPoints = physio.NoVols;
        sdm.FirstConfoundPredictor = (order_c*2)+1;
        counter = 1;
        for i = 1 : 2: sdm.NrOfPredictors-2
            sdm.PredictorNames{i} =['Pulse_Cos' num2str(counter)];
            sdm.PredictorNames{i+1} = ['Pulse_Sin' num2str(counter)];
            counter = counter +1;
        end
        clear i
        sdm.PredictorNames{end+1} = 'Constant';
        sdm.SDMMatrix(1:sdm.NrOfDataPoints,1:(order_c*2)) = dm_phs_c;
        sdm.SDMMatrix(1:sdm.NrOfDataPoints,sdm.NrOfPredictors) = ones(sdm.NrOfDataPoints,1);
        sdm.SaveAs([fmridir, fmrifile(1:end-4),'_pulse_RETROICOR.sdm']);
    end
    
    % Save Filtered Pulse Values (z-transformed)
    sdm2 = xff ('new:sdm');
    sdm2.NrOfPredictors = 2;
    sdm2.NrOfDataPoints = physio.NoVols;
    sdm2.FirstConfoundPredictor = 2;
    sdm2.PredictorNames{1} = physio.colheader{pulse_col};
    sdm2.PredictorNames{2} = 'Constant';
    sdm2.SDMMatrix(1:sdm2.NrOfDataPoints,1) = normalize(filt_cardiac_vol);
    sdm2.SDMMatrix(1:sdm2.NrOfDataPoints,sdm2.NrOfPredictors) = ones(sdm2.NrOfDataPoints,1);
    sdm2.SaveAs([fmridir, fmrifile(1:end-4),'_pulse_TBP', num2str(cardiac_low), '-', num2str(cardiac_high), 'Hz.sdm']);
    
    
    %% Saving Heart Rate Values
    physio.MeanHeartRate = mean((physio.sampling./diff(peaks_ind(1:end-1)))*60);
    physio.STDHeartRate = std((physio.sampling./diff(peaks_ind(1:end-1)))*60);
end



%% If Respiratory Data exists start to analyze it
if ~isempty(resp_col)
    % check input signal
    assert(~any(isnan(physio.data(:,resp_col))), 'Nan values in the respiratory signal');
    
    %% Plotting Respiratory Raw Data
    figurerawresp = figure('Units', 'Normalized', 'OuterPosition', [0.5, 0.5, 0.5, 0.5]);
    vax = axes;
    plotraw = plot(timestamps,physio.data(:,resp_col));
    hold;
    title(physio.colheader{resp_col});
    xlabel('Seconds');
    startscan = plot([timestamps(trigind(1)) timestamps(trigind(1))],get(vax,'YLim'),'Color',[1 0 0]);
    uistack(startscan,'bottom')
    endscan = plot([timestamps(trigind(end)) timestamps(trigind(end))],get(vax,'YLim'),'Color',[1 0 0]);
    uistack(endscan,'bottom')
    leg = legend([startscan plotraw], 'run length', 'raw data ');
    set(leg, 'TextColor', [0 0 0],'Location','North', 'FontSize', 8,  'Orientation','horizontal');
    
    
    %% The Respiratory phase needs to be calculated taking not only the times of peak inspiration into account (peak location), but also the amplitude of inspiration, since the depth of the
    %  breathing also influences the amount of head motion
    % 1. amplitude of the respiratory signal from the pneumatic belt, is
    %    normalized to the range (0, Rmax), i.e. find max and min amplitudes and normalize amplitude
    % 2. Calculate the histogram from the number of occurrences of specific respiratory
    %    amplitudes in bins 1:100 and the bth bin is accordingly centered at bRmax/100
    % 3. Calculate running integral of the histogram, creating an equalized transfer function between the breathing amplitude and respiratory phase,
    %    where end-expiration is assigned a phase of 0 and peak inspiration has a phase of +/-pi. While inhaling the phase spans 0 to pi and during expiration
    %    the phase is negated. The transfer function that relates fr(t) to R(t) is
    
    % one could set this to a specific max value when assuming clipping in
    % the signal, so all values above this threshold would be set to a new
    % max value
    resp_max = inf; %
    if isfinite(resp_max)
        clip = find(abs(physio.data(:,resp_col)) > resp_max);
        physio.data(clip,resp_col) = resp_max;
    end
    
    % Some Data Preparation: smoothing the signal for removing extreme
    % spikes in the data (normal respiratory frequency at rest between 0.2 and 0.4 Hz (respiratory rate between 12 and 24 breaths per minute)
    nyq_freq = physio.sampling/2;
    [b a] = butter(2, resp_high/nyq_freq, 'low'); % creates a Butterworth lowpass filter
    resp_filt = filtfilt(b,a,physio.data(:,resp_col));
    clear b a
    
    % Plot the filtered data in the original data plot
    figurerawresp;
    plotfilt = plot(timestamps,resp_filt,'c');
    plotfilt.Color(4) = 0.4;
    leg = legend([startscan plotraw plotfilt], 'run length', 'raw data ', 'filtered data');
    set(leg, 'TextColor', [0 0 0],'Location','North', 'FontSize', 8,  'Orientation','horizontal');
    print(figurerawresp,'-dpng','-r300',[fmridir, fmrifile(1:end-4),'_RawResp.png']);
    savefig(figurerawresp,[fmridir, fmrifile(1:end-4),'_RawResp.fig']);
    
    % 1. normalize amplitude of respiratory signal
    resp_norm = (resp_filt - min(resp_filt)) / (max(resp_filt) - min(resp_filt));
    
    % 2. Calculate the histogram
    nbins = 100;
    resp_hist = hist(resp_norm,nbins);
    
    % 3. Calculate transfer function and phase
    resp_transfer_func = [0 (cumsum(resp_hist) / sum(resp_hist))];
    kern_size = round(physio.sampling - 1);
    resp_smooth = conv(resp_norm,ones(kern_size,1),'same'); % smoothed version for taking derivative
    resp_diff = [diff(resp_smooth);0]; % derivative dR/dt
    resp_phase = pi*resp_transfer_func(round(resp_norm * nbins)+1)' .* sign(resp_diff); % respiratory phase between -pi to 0 to +pi
    
    
    %% Find peaks in filtered respiratory signal for computation of respiratory phase     
    [b a] = butter(2, 0.8/nyq_freq, 'low'); % creates a Butterworth lowpass filter that filters stronger than above
    resp_filt_forpeaks = filtfilt(b,a,physio.data(:,resp_col));
    clear b a
    
    % identify peaks in filtered signal
    resp_peaks_ind = [];
    for i = 2:length(resp_filt_forpeaks)-1
        if(resp_filt_forpeaks(i-1) < resp_filt_forpeaks(i) && resp_filt_forpeaks(i+1) < resp_filt_forpeaks(i))
            resp_peaks_ind = [resp_peaks_ind, i]; 
        end
    end
    
    % define minimum distance between neighbouring peaks:
    % based on the assumption that respiratory rate at rest is between 0.2 and 0.4 Hz, it is safe to assume that neighbouring peaks should not be closer than 1.66 sec (about 0.6 Hz)  
    % based on this time difference and the sampling frequency, one can
    % calculate the minimum number of datapoints between neighbouring
    % peaks:
    min_peak_diff = 1.66 * physio.sampling;
    % remove peaks that are too close in time
    resp_peaks_ind_new = resp_peaks_ind;
    rm_ind = [];
    for r = 1:numel(resp_peaks_ind)-1
        if resp_peaks_ind(r+1) - resp_peaks_ind(r) < min_peak_diff 
            [val, ind] = min([physio.data(resp_peaks_ind(r),resp_col), physio.data(resp_peaks_ind(r+1),resp_col)]);
            if ind == 1
                rm_ind = [rm_ind, r];
            else 
                rm_ind = [rm_ind, r+1];
            end
        end
        clear val ind
    end
    resp_peaks_ind_new(rm_ind) = [];
   
    % plot raw resp signal together with identified peak locations
    figurepeaksresp = figure('Units', 'Normalized', 'OuterPosition', [0.5, 0.5, 0.5, 0.5]);
    vax = axes;
    plotresp = plot(timestamps,physio.data(:,resp_col));
    hold;
    title([physio.colheader{resp_col} ' peaks, identified using low-pass filtered data']);
    xlabel('Seconds');
    plotfiltpeaks = plot(timestamps,resp_filt_forpeaks,'c');
    plotpeaksresp = plot(timestamps(resp_peaks_ind),physio.data(resp_peaks_ind,resp_col),'r.', 'MarkerSize', 12);
    plotpeaksrespnew = plot(timestamps(resp_peaks_ind_new),physio.data(resp_peaks_ind_new,resp_col),'g.', 'MarkerSize', 12);
    leg = legend([plotresp plotfiltpeaks plotpeaksresp plotpeaksrespnew], 'raw data ', 'filtered data', 'original peaks', 'cleaned peaks');
    set(leg, 'TextColor', [0 0 0],'Location','North', 'FontSize', 8,  'Orientation','horizontal');
    
    % let user decide to remove some lower-amplitude peaks using a
    % user-defined threshold
    prompt = input('Would you like to remove identified respiration peaks below a certain threshold? Y/N: ', 's');
    if strcmpi(prompt,'y')
        peakthresh = input('Please specify the peak threshold using the range of the y-axis in the plot "respiratory peaks, identified using low-pass filtered data" :   '); 
        resp_peaks_ind_new(physio.data(resp_peaks_ind_new,resp_col) < peakthresh) = []; % delete all peaks below user-defined threshold
        
        close
        figurepeaksresp = figure('Units', 'Normalized', 'OuterPosition', [0.5, 0.5, 0.5, 0.5]);
        vax = axes;
        plotresp = plot(timestamps,physio.data(:,resp_col));
        hold;
        title([physio.colheader{resp_col} ' peaks, identified using low-pass filtered data']);
        xlabel('Seconds');
        plotfiltpeaks = plot(timestamps,resp_filt_forpeaks,'c');
        plotpeaksresp = plot(timestamps(resp_peaks_ind),physio.data(resp_peaks_ind,resp_col),'r.', 'MarkerSize', 12);
        plotpeaksrespnew = plot(timestamps(resp_peaks_ind_new),physio.data(resp_peaks_ind_new,resp_col),'g.', 'MarkerSize', 12);
        plotpeakthresh = plot(get(vax,'XLim'),[peakthresh peakthresh],'Color',[1 0 0]);
        uistack(plotpeakthresh,'bottom')
        leg = legend([plotresp plotfiltpeaks plotpeaksresp plotpeaksrespnew plotpeakthresh], 'raw data ', 'filtered data', 'original peaks', 'cleaned peaks', 'user peak threshold');
        set(leg, 'TextColor', [0 0 0],'Location','North', 'FontSize', 8,  'Orientation','horizontal');
        physio.resppeaks_userthreshold = peakthresh;
        clear peakthresh
    end
    
    print(figurepeaksresp,'-dpng','-r300',[fmridir, fmrifile(1:end-4),'_RespPeaks.png']);
    savefig(figurepeaksresp,[fmridir, fmrifile(1:end-4),'_RespPeaks.fig']);
    
    physio.resppeaks_ind = resp_peaks_ind_new; % save the indices (within the timestampsinmsec and the data vector) of the identified peaks in the physio structure

    %% Saving Respiratory Rate Values
    physio.MeanRespiratoryRate = mean((physio.sampling./diff(resp_peaks_ind_new(1:end-1)))*60);
    physio.STDRespiratoryRate = std((physio.sampling./diff(resp_peaks_ind_new(1:end-1)))*60);

    %% Create SDM with Respiratory Predictors
    %fit Xth order fourier series to estimate phase
    % generate Volume-Based Values
    % check whether slice-based or volume-based triggers are used in the TSV
    % file
    temp = physio.NoOfTriggerIntervals/physio.NoVols;
    if temp < 1
        disp('There is not for every recorded volume a trigger saved in the TSV file!')
        return
    elseif temp == 1 % only volume triggers saved in physio.data
        resp_phase_vol = resp_phase(trig_startsli_ind); % phase values
        filt_resp_vol = resp_filt(trig_startsli_ind); % raw respiratory values
    elseif temp > 1 % slice triggers saved in physio.data
        resp_phase_vol = resp_phase(trig_startsli_ind(1:temp:end)); % sample the start of the volume
        %resp_phase_vol = resp_phase(trig_startsli_ind(round(temp/2):temp:end)); % sample the middle of the volume
        filt_resp_vol = resp_filt(trig_startsli_ind(1:temp:end)); % sample the start of the volume
        %filt_resp_vol = resp_filt(trig_startsli_ind(round(temp/2):temp:end));
    end
    clear temp
    
    if order_r > 0
        for i = 1:order_r
            dm_phs_r(:,(i*2)-1) = cos(i*resp_phase_vol);
            dm_phs_r(:,i*2) = sin(i*resp_phase_vol);
        end
        clear i
        
        % Save Respiratory RETROICOR Predictors
        sdm3 = xff ('new:sdm');
        sdm3.NrOfPredictors = (order_r*2)+1;
        sdm3.NrOfDataPoints = physio.NoVols;
        sdm3.FirstConfoundPredictor = (order_r*2)+1;
        counter = 1;
        for i = 1 : 2: sdm3.NrOfPredictors-2
            sdm3.PredictorNames{i} =['Resp_Cos' num2str(counter)];
            sdm3.PredictorNames{i+1} = ['Resp_Sin' num2str(counter)];
            counter = counter +1;
        end
        clear i
        sdm3.PredictorNames{end+1} = 'Constant';
        sdm3.SDMMatrix(1:sdm3.NrOfDataPoints,1:(order_r*2)) = dm_phs_r;
        sdm3.SDMMatrix(1:sdm3.NrOfDataPoints,sdm3.NrOfPredictors) = ones(sdm3.NrOfDataPoints,1);
        sdm3.SaveAs([fmridir, fmrifile(1:end-4),'_resp_RETROICOR.sdm']);
    end
    
    % Save Filtered Resp Values (z-transformed)
    sdm4 = xff ('new:sdm');
    sdm4.NrOfPredictors = 2;
    sdm4.NrOfDataPoints = physio.NoVols;
    sdm4.FirstConfoundPredictor = 2;
    sdm4.PredictorNames{1} = physio.colheader{resp_col};
    sdm4.PredictorNames{2} = 'Constant';
    sdm4.SDMMatrix(1:sdm4.NrOfDataPoints,1) = normalize(filt_resp_vol);
    sdm4.SDMMatrix(1:sdm4.NrOfDataPoints,sdm4.NrOfPredictors) = ones(sdm4.NrOfDataPoints,1);
    sdm4.SaveAs([fmridir, fmrifile(1:end-4),'_resp_TLP', num2str(resp_high), 'Hz.sdm']);
end



%% If Both Cardiac and Respiratory Signal is available add Multiplicative Term to SDM and save as new SDM
% see Harvey et al., 2008:
% interaction between cardiac and respiratory processes, giving rise to
% amplitude modulation of the cardiac signal by the respiratory waveform
% (1. heart rate varies with respiration - known as respiratory sinus
% arrhythmia, 2. venous return to the heart is facilitated during
% inspiration - known as intrathoracic pump)
% see also: Kasper, L., Bollmann, S., Diaconescu, A. O., Hutton, C., Heinzle, J., Iglesias, S., ? Stephan, K. E. (2017). The PhysIO Toolbox for Modeling Physiological Noise in fMRI Data. Journal of Neuroscience Methods, 276, 56?72. https://doi.org/10.1016/J.JNEUMETH.2016.10.019


% a first order interaction model results in 4 predictors
if ~isempty(pulse_col) && ~isempty(resp_col) && order_cr > 0
    counter =1;
    for i = 1:4:(order_cr*4)
        dm_phs_cr(:,i) = cos(counter*cardiac_phase_vol + counter*resp_phase_vol);
        dm_phs_cr(:,i+1) = sin(counter*cardiac_phase_vol + counter*resp_phase_vol);
        dm_phs_cr(:,i+2) = cos(counter*cardiac_phase_vol - counter*resp_phase_vol);
        dm_phs_cr(:,i+3) = sin(counter*cardiac_phase_vol - counter*resp_phase_vol);
    end
    clear i
    
    % Save Complete RETROICOR Model including multiplicative term
    
    sdm5 = sdm.CopyObject;
    sdm5.SDMMatrix(:,end : end+ sdm3.NrOfPredictors-1) = sdm3.SDMMatrix;
    sdm5.PredictorNames(end : end+sdm3.NrOfPredictors-1) = sdm3.PredictorNames(1:end);
    sdm5.SDMMatrix(:,end : end+ size(dm_phs_cr,2)-1) = dm_phs_cr;
    sdm5.PredictorNames(end) = [];
    
    for i = 1 : size(dm_phs_cr,2)
        sdm5.PredictorNames(end+1) ={['PulseResp_' num2str(i)]};
    end
    clear i
    sdm5.SDMMatrix(:,end+1) = ones(sdm.NrOfDataPoints,1);
    sdm5.PredictorNames{end+1} = 'Constant';
    sdm5.NrOfPredictors = size(sdm5.SDMMatrix,2);
    sdm5.FirstConfoundPredictor =  sdm5.NrOfPredictors-1;
    sdm5.SaveAs([fmridir, fmrifile(1:end-4),'_pulseresp_RETROICOR.sdm']);
end

% Save Physio Structure in Mat File
save([fmridir, fmrifile(1:end-4),'_',[physio.colheader{1:end-1}], '.mat'],'physio');