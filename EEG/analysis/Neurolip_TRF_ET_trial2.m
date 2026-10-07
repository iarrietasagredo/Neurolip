%% ================================================================
%  NeuroLip: Eye-tracking -> EEG forward TRF
%
%  Tobii X120 ET: 120 Hz
%  EEG:           200 Hz

%ET = double(ET(:));

% Convert the original 0-to-1 gaze-position scale to a
% centered eyes-to-mouth scale:
%
%   -0.5 = eyes
%    0   = midpoint/nose region
%   +0.5 = mouth
%
% NaNs remain NaNs and are used to identify invalid segments.

% ET = ET - 0.5;
%
%  MATLAB R2018b compatible
% ================================================================

clear
close all
clc

set(0,'DefaultFigureVisible','on');

%% ================================================================
%  PATHS
% ================================================================

addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/datasets
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/datasets/irene_trial_12_04
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/cnsp_utils/cnd
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/cnsp_utils
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/eeglab2026.0.0
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/code
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/mTRF-Toolbox_v2/mtrf
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/fieldtrip


%% ================================================================
%  DATA PATHS
% ================================================================

pathDataPrep = ...
    '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed';

pathDataEEG_NIRS_ET = ...
    '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/CND_data_format';

savePath = ...
    '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results';


%% ================================================================
%  SUBJECT FILES
% ================================================================

files = dir(fullfile(pathDataEEG_NIRS_ET,'CND*'));

out_peak = [];

selection = setdiff({files(:).name},out_peak);

nSubs = numel(selection);

fprintf('\nFound %d CND files.\n',nSubs);


%% ================================================================
%  GENERAL PARAMETERS
% ================================================================

condLabels = {'Clear','Vocoded'};

% EEG
fsEEG_expected = 200;

% Tobii X120
fsET = 120;

% mTRF
lambdas = 10.^(-3:6);

dirTRF = 1;

% Same lag window as your forward speech TRF
tmin = -100;
tmax = 500;

regMethod = 'Ridge';

% Number of SDs for EEG trial-level MAD rejection
nSD = 3;

% Minimum number of usable ET segments per condition
minSegments = 3;

% Minimum duration of an ET segment
%
% 1 second is preferable here because your TRF extends from
% -100 to +500 ms. Very short segments provide little information
% for estimating a TRF.
minSegDuration = 1.0;

minSegSamples = round(minSegDuration * fsET);


%% ================================================================
%  ET / EEG ELECTRODES
% ================================================================

avgElectrodes = true;

roiElec = {'F1','Fz','F2','C1','C2','Cz'};

Chan2Plot = 'ROIavg';


%% ================================================================
%  EEG BANDS
% ================================================================

% bandNames = {'broad','delta','theta'};
%
% bandRange = {
%     [1 8]
%     [1 4]
%     [4 8]
%     };
bandNames = {'broad'};
bandRange = {
    [1 8]
    };

%% ================================================================
%  LAMBDA SELECTION
% ================================================================

tolerancePercent = 0.05;

useToleranceLambda = true;

pickLambda = @(rl) local_pickLambda( ...
    rl,lambdas,tolerancePercent,useToleranceLambda);


%% ================================================================
%  STORAGE
% ================================================================

badTrial = cell(1,nSubs);

subMedRMS = nan(1,nSubs);

nC1 = zeros(1,nSubs);
nC2 = zeros(1,nSubs);

keepSub = false(1,nSubs);

eegGroup = cell(1,nSubs);
condGroup = cell(1,nSubs);
codeGroup = cell(1,nSubs);
etGroup = cell(1,nSubs);
stimGroup = cell(1,nSubs);
validSubs = [];


%% ================================================================
%  STEP 1
%  EEG QUALITY ASSESSMENT
%
%  This is kept the same as your working speech TRF code.
% ================================================================

fprintf('\n====================================================\n');
fprintf('STEP 1: EEG quality assessment\n');
fprintf('====================================================\n');

for sub = 1:nSubs
    
    fprintf('Subject %d/%d: %s\n', ...
        sub,nSubs,selection{sub});
    
    tmp = load(fullfile(pathDataEEG_NIRS_ET,selection{sub}));
    tmp = tmp.eeg;
    
    eegRows = tmp.data;
    
    nOriginalTrials = numel(eegRows);
    
    btOriginal = false(1,nOriginalTrials);
    
    idx_nonempty = find(~cellfun(@isempty,eegRows));
    
    data_nonempty = eegRows(idx_nonempty);
    
    nTrl = numel(data_nonempty);
    
    rms1 = nan(1,nTrl);
    
    for k = 1:nTrl
        
        E = data_nonempty{k};
        
        rms1(k) = sqrt(mean(E(:).^2));
        
    end
    
    med = median(rms1,'omitnan');
    
    madv = 1.4826 * ...
        median(abs(rms1-med),'omitnan');
    
    if madv == 0
        madv = eps;
    end
    
    bt = abs(rms1-med) > nSD*madv;
    
    btOriginal(idx_nonempty) = bt;
    
    badTrial{sub} = btOriginal;
    
    subMedRMS(sub) = ...
        median(rms1(~bt),'omitnan');
    
end


%% ================================================================
%  SUBJECT-LEVEL EEG QUALITY
% ================================================================

gMed = median(subMedRMS,'omitnan');

gMAD = 1.4826 * ...
    median(abs(subMedRMS-gMed),'omitnan');

if gMAD == 0
    gMAD = eps;
end

keepSub = ...
    abs(subMedRMS-gMed) <= nSD*gMAD & ...
    ~isnan(subMedRMS);


%% ================================================================
%  EEG CONDITION COUNTS
% ================================================================

for sub = 1:nSubs
    
    tmp = load(fullfile(pathDataEEG_NIRS_ET,selection{sub}));
    tmp = tmp.eeg;
    
    nOriginalTrials = numel(tmp.data);
    
    good = ~badTrial{sub};
    
    cond = tmp.cond(:)';
    
    if numel(cond) ~= nOriginalTrials
        
        error(['Condition vector does not have the same number ' ...
            'of trials as EEG data for %s.'], ...
            selection{sub});
        
    end
    
    nonemptyEEG = ~cellfun(@isempty,tmp.data);
    
    good = good & nonemptyEEG;
    
    nC1(sub) = sum(good & cond == 1);
    
    nC2(sub) = sum(good & cond == 2);
    
    keepSub(sub) = ...
        keepSub(sub) & ...
        (nC1(sub) >= 3) & ...
        (nC2(sub) >= 3);
    
end


fprintf('\nEEG-valid subjects: %d/%d\n', ...
    sum(keepSub),nSubs);


%% ================================================================
%  STEP 2
%  LOAD EEG + ET + SPEECH ENVELOPE
% ================================================================

fprintf('\n====================================================\n');
fprintf('STEP 2: Loading EEG, eye tracking and speech envelope\n');
fprintf('====================================================\n');

for sub = 1:nSubs
    
    if ~keepSub(sub)
        continue
    end
    
    fprintf('Loading %s\n',selection{sub});
    
    %% ------------------------------------------------------------
    % LOAD COMPLETE CND FILE
    % ------------------------------------------------------------
    
    CND = load(fullfile(pathDataEEG_NIRS_ET,selection{sub}));
    
    
    %% ------------------------------------------------------------
    % KEEP STIM BEFORE ENTERING EEG STRUCTURE
    %
    % According to your CND organisation, stim is part of the
    % loaded CND file, whereas EEG is inside CND.eeg.
    % ------------------------------------------------------------
    
    CND = load(fullfile(pathDataEEG_NIRS_ET,selection{sub}));
    
    tmp = CND.eeg;
    
    % stim is stored inside CND.eeg
    stimRows = tmp.stim;
    
    
    %% ------------------------------------------------------------
    % ENTER EEG STRUCTURE
    %
    % This is exactly the hierarchy from your working code.
    % ------------------------------------------------------------
    
    tmp = CND.eeg;
    
    
    %% ------------------------------------------------------------
    % EEG
    % ------------------------------------------------------------
    
    eegRows = tmp.data;
    cond = tmp.cond(:)';
    codes = tmp.monologue(:)';
    
    
    %% ------------------------------------------------------------
    % EYE TRACKING
    %
    % Keep the extraction method from your existing code.
    % ------------------------------------------------------------
    
    eyeRows = extract_ET_from_CND(tmp);
    
    
    %% ------------------------------------------------------------
    % CHECK NUMBER OF TRIALS
    % ------------------------------------------------------------
    
    if numel(eyeRows) ~= numel(eegRows)
        
        error(['Number of ET trials (%d) does not match number ' ...
            'of EEG trials (%d) for %s.'], ...
            numel(eyeRows), ...
            numel(eegRows), ...
            selection{sub});
        
    end
    
    
    if numel(stimRows) ~= numel(eegRows)
        
        error(['Number of stim trials (%d) does not match number ' ...
            'of EEG trials (%d) for %s.'], ...
            numel(stimRows), ...
            numel(eegRows), ...
            selection{sub});
        
    end
    
    
    %% ------------------------------------------------------------
    % REMOVE EEG-BAD TRIALS
    % ------------------------------------------------------------
    
    rm = badTrial{sub};
    
    eegRows(rm) = {[]};
    eyeRows(rm) = {[]};
    stimRows(rm) = [];
    
    cond(rm) = [];
    codes(rm) = [];
    
    
    %% ------------------------------------------------------------
    % STORE
    % ------------------------------------------------------------
    
    eegGroup{sub} = tmp;
    
    eegGroup{sub}.data = eegRows;
    
    condGroup{sub} = cond;
    codeGroup{sub} = codes;
    etGroup{sub} = eyeRows;
    stimGroup{sub} = stimRows;
    
end


%% ================================================================
%  EEG SAMPLING RATE
% ================================================================

validEEGSubjects = find(keepSub);

if isempty(validEEGSubjects)
    
    error('No EEG-valid subjects remain.');
    
end

fsEEG = eegGroup{validEEGSubjects(1)}.fs;

fprintf('\nEEG sampling rate: %.3f Hz\n',fsEEG);

if abs(fsEEG-fsEEG_expected) > 0.1
    
    warning(['Expected EEG sampling rate of %.1f Hz, but found %.3f Hz.'], ...
        fsEEG_expected,fsEEG);
    
end


%% ================================================================
%  CHECK ET SAMPLING RATE
% ================================================================

fprintf('ET sampling rate assumed: %.1f Hz\n',fsET);

if fsET ~= 120
    
    error('This script assumes Tobii X120 sampling at 120 Hz.');
    
end


%% ================================================================
%  STEP 3
%  PREPARE EEG
%
%  Same ROI averaging strategy as your speech TRF:
%  available EEG channels are averaged to one virtual channel.
% ================================================================

fprintf('\n====================================================\n');
fprintf('STEP 3: Preparing EEG\n');
fprintf('====================================================\n');

for sub = validEEGSubjects
    
    %% ------------------------------------------------------------
    %  Determine available EEG channels
    % ------------------------------------------------------------
    
    idx = find(~cellfun(@isempty,eegGroup{sub}.data),1);
    
    if isempty(idx)
        continue
    end
    
    nChan = size(eegGroup{sub}.data{idx},2);
    
    fprintf('%s: %d EEG channels\n', ...
        selection{sub},nChan);
    
    
    %% ------------------------------------------------------------
    %  Average available EEG channels
    % ------------------------------------------------------------
    
    if avgElectrodes
        
        for tr = 1:numel(eegGroup{sub}.data)
            
            if isempty(eegGroup{sub}.data{tr})
                continue
            end
            
            E = eegGroup{sub}.data{tr};
            
            eegGroup{sub}.data{tr} = ...
                mean(E,2,'omitnan');
            
        end
        
        eegGroup{sub}.chanlocs = ...
            struct('labels','ROIavg');
        
    end
    
    
    %% ------------------------------------------------------------
    %  Normalize EEG within subject
    %
    % Same normalization used in your speech TRF.
    % ------------------------------------------------------------
    
    nonempty = ~cellfun(@isempty,eegGroup{sub}.data);
    
    allE = vertcat(eegGroup{sub}.data{nonempty});
    
    nf = std(allE(:));
    
    if nf == 0 || isnan(nf)
        nf = 1;
    end
    
    for tr = 1:numel(eegGroup{sub}.data)
        
        if ~isempty(eegGroup{sub}.data{tr})
            
            eegGroup{sub}.data{tr} = ...
                eegGroup{sub}.data{tr} ./ nf;
            
        end
        
    end
    
end


%% ================================================================
%  STEP 4
%  BUILD ET -> EEG SEGMENTS
% ================================================================

fprintf('\n====================================================\n');
fprintf('STEP 4: Building ET/EEG segments\n');
fprintf('====================================================\n');

% Structure:
%
% ETsegments{sub,condition}{segment}
% EEGsegments{sub,condition}{segment}

ETsegments = cell(nSubs,2);
EEGsegments = cell(nSubs,2);
ENVsegments = cell(nSubs,2);
segmentInfo = cell(nSubs,2);

nSegments = zeros(nSubs,2);


%% ================================================================
%  LOOP OVER SUBJECTS AND CONDITIONS
% ================================================================

for sub = validEEGSubjects
    
    fprintf('\n%s\n',selection{sub});
    
    for icond = 1:2
        
        fprintf('  %s\n',condLabels{icond});
        
        ETsegments{sub,icond} = {};
        EEGsegments{sub,icond} = {};
        segmentInfo{sub,icond} = [];
        ENVsegments{sub,icond} = {};
        
        %% --------------------------------------------------------
        % Select trials belonging to this condition
        % --------------------------------------------------------
        
        trIdx = find(condGroup{sub} == icond);
        
        segCounter = 0;
        
        
        %% --------------------------------------------------------
        % LOOP THROUGH TRIALS
        % --------------------------------------------------------
        
        for itr = 1:numel(trIdx)
            
            tr = trIdx(itr);
            
            EEG = eegGroup{sub}.data{tr};
            ET = etGroup{sub}{tr};
            STIM = stimGroup{sub}{tr};
            
            if isempty(STIM)
                continue
            end
            
            % Column 1 = speech envelope
            % Column 2 = raw audio (not used)
            ENV = STIM(:,1);
            
            if isempty(EEG) || isempty(ET)
                continue
            end
            
            
            %% ----------------------------------------------------
            % Make vectors
            % ----------------------------------------------------
            
            EEG = double(EEG);
            
            if size(EEG,2) > 1
                EEG = mean(EEG,2,'omitnan');
            end
            
            ET = double(ET(:));
            
            ENV = double(ENV(:));
            
            
            %% ----------------------------------------------------
            % Centre ET
            %
            % Original:
            %   0   = eyes
            %   0.5 = midpoint/nose
            %   1   = mouth
            %
            % After centering:
            %  -0.5 = eyes
            %   0   = midpoint/nose
            %  +0.5 = mouth
            % ----------------------------------------------------
            
            ET = ET - 0.5;
            
            %% ----------------------------------------------------
            % Check EEG
            % ----------------------------------------------------
            
            if any(~isfinite(EEG))
                
                goodEEG = isfinite(EEG);
                
                if ~all(goodEEG)
                    
                    warning(['Non-finite EEG samples found in %s, ' ...
                        'trial %d. Trial skipped.'], ...
                        selection{sub},tr);
                    
                    continue
                    
                end
                
            end
            
            
            %% ----------------------------------------------------
            % Determine common time range
            %
            % EEG and ET trials do not necessarily have exactly the
            % same duration. We therefore work only within their
            % temporal overlap.
            % ----------------------------------------------------
            
            T_EEG = (length(EEG)-1) / fsEEG;
            T_ET = (length(ET)-1) / fsET;
            
            % Speech envelope is already aligned to the 200-Hz EEG
            T_ENV = (length(ENV)-1) / fsEEG;
            
            Tcommon = min([T_EEG T_ET T_ENV]);
            
            if Tcommon <= minSegDuration
                continue
            end
            
            
            %% ----------------------------------------------------
            % ET samples inside common duration
            % ----------------------------------------------------
            
            nETcommon = floor(Tcommon*fsET) + 1;
            
            nETcommon = min(nETcommon,length(ET));
            
            ETcommon = ET(1:nETcommon);
            
            
            %% ----------------------------------------------------
            % Identify contiguous valid ET segments
            %
            % NO interpolation is performed.
            % ----------------------------------------------------
            
            valid = isfinite(ETcommon);
            
            d = diff([false; valid; false]);
            
            startValid = find(d == 1);
            
            endValid = find(d == -1)-1;
            
            
            %% ----------------------------------------------------
            % Loop through valid ET segments
            % ----------------------------------------------------
            
            for iseg = 1:numel(startValid)
                
                a = startValid(iseg);
                b = endValid(iseg);
                
                nSeg = b-a+1;
                
                
                %% ------------------------------------------------
                % Reject very short segments
                % ------------------------------------------------
                
                if nSeg < minSegSamples
                    continue
                end
                
                
                %% ------------------------------------------------
                % ET segment at 120 Hz
                % ------------------------------------------------
                
                etSeg120 = ETcommon(a:b);
                
                
                %% ------------------------------------------------
                % Segment start/end times
                % ------------------------------------------------
                
                tStart = (a-1)/fsET;
                
                tEnd = (b-1)/fsET;
                
                
                %% ------------------------------------------------
                % Corresponding EEG samples
                % ------------------------------------------------
                
                eegStart = floor(tStart*fsEEG) + 1;
                
                eegEnd = floor(tEnd*fsEEG) + 1;
                
                eegStart = max(1,eegStart);
                
                eegEnd = min(length(EEG),eegEnd);
                
                
                if eegEnd <= eegStart
                    continue
                end
                
                
                %% ------------------------------------------------
                % EEG segment
                % ------------------------------------------------
                
                eegSeg = EEG(eegStart:eegEnd);
                
                %% ------------------------------------------------
                % Speech envelope segment
                %
                % Envelope is already at the EEG sampling rate
                % and already temporally aligned with EEG.
                % ------------------------------------------------
                
                envStart = eegStart;
                envEnd = min(length(ENV),eegEnd);
                
                if envEnd <= envStart
                    continue
                end
                
                envSeg = ENV(envStart:envEnd);
                %% ------------------------------------------------
                % Upsample ET 120 -> 200 Hz
                %
                % resample performs anti-alias filtering internally.
                % ------------------------------------------------
                
                etSeg200 = resample( ...
                    etSeg120, ...
                    fsEEG, ...
                    fsET);
                
                
                etSeg200 = etSeg200(:);
                
                
                %% ------------------------------------------------
                % Make ET, envelope and EEG exactly the same length
                % ------------------------------------------------
                
                L = min([ ...
                    length(etSeg200), ...
                    length(envSeg), ...
                    length(eegSeg)]);
                
                if L < round(minSegDuration*fsEEG)
                    continue
                end
                
                etSeg200 = etSeg200(1:L);
                envSeg = envSeg(1:L);
                eegSeg = eegSeg(1:L);
                
                %% ------------------------------------------------
                % Final finite-value check
                % ------------------------------------------------
                
                if any(~isfinite(etSeg200))
                    continue
                end
                
                if any(~isfinite(eegSeg))
                    continue
                end
                
                
                %% ------------------------------------------------
                % Store segment
                % ------------------------------------------------
                
                segCounter = segCounter + 1;
                
                
                ETsegments{sub,icond}{segCounter} = etSeg200;
                ENVsegments{sub,icond}{segCounter} = envSeg;
                EEGsegments{sub,icond}{segCounter} = eegSeg;
                
                segmentInfo{sub,icond}(segCounter).trial = tr;
                segmentInfo{sub,icond}(segCounter).segment = iseg;
                segmentInfo{sub,icond}(segCounter).startET = a;
                segmentInfo{sub,icond}(segCounter).endET = b;
                segmentInfo{sub,icond}(segCounter).duration = L/fsEEG;
                
            end
            
        end
        
        
        nSegments(sub,icond) = segCounter;
        
        fprintf('    usable ET segments: %d\n',segCounter);
        
    end
    
end


%% ================================================================
%  SUBJECTS WITH ENOUGH ET DATA
% ================================================================

validSubBand = false(nSubs,2);

for sub = validEEGSubjects
    
    validSubBand(sub,1) = ...
        nSegments(sub,1) >= minSegments;
    
    validSubBand(sub,2) = ...
        nSegments(sub,2) >= minSegments;
    
end

validSubsET = find( ...
    keepSub & ...
    any(validSubBand,2) );

fprintf('\n====================================================\n');
fprintf('ET-valid subjects\n');
fprintf('====================================================\n');

for icond = 1:2
    
    fprintf('%s: %d subjects\n', ...
        condLabels{icond}, ...
        sum(validSubBand(:,icond)));
    
end


%% ================================================================
%  STEP 5
%  FILTER ET INTO BANDS
% ================================================================

fprintf('\n====================================================\n');
fprintf('STEP 5: Preparing ET bands\n');
fprintf('====================================================\n');

% ETband{sub,condition,band}{segment}

ETband = cell(nSubs,2,numel(bandNames));

for sub = validEEGSubjects
    
    for icond = 1:2
        
        if isempty(ETsegments{sub,icond})
            continue
        end
        
        for iband = 1:numel(bandNames)
            
            ETband{sub,icond,iband} = cell( ...
                size(ETsegments{sub,icond}));
            
            
            for iseg = 1:numel(ETsegments{sub,icond})
                
                x = ETsegments{sub,icond}{iseg};
                
                
                %% ------------------------------------------------
                % Broadband
                %
                % Keep the original continuous ET signal.
                %
                % 0   = eyes
                % 0.5 = nose/midpoint
                % 1   = mouth
                if iband == 1
                    
                    ETband{sub,icond,iband}{iseg} = x;
                    
                    
                    %% ------------------------------------------------
                    % Delta / theta
                    % ------------------------------------------------
                    
                else
                    
                    range = bandRange{iband};
                    
                    % Avoid attempting to filter segments that are
                    % too short for stable filtfilt operation.
                    
                    minFilterSamples = ...
                        max(100,round(1.5*fsEEG));
                    
                    if length(x) < minFilterSamples
                        
                        ETband{sub,icond,iband}{iseg} = [];
                        
                    else
                        
                        ETband{sub,icond,iband}{iseg} = ...
                            local_bp( ...
                            x, ...
                            range(1), ...
                            range(2), ...
                            fsEEG);
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end


% %% ================================================================
% %  STEP 6
% %  FORWARD ET -> EEG TRF
% %
% %  For each subject:
% %
% %       ET predictor -> EEG response
% %
% %  Lambda:
% %       selected by cross-validation across ET segments.
% %
% %  Final prediction:
% %       leave-one-segment-out.
% %
% %  This avoids calculating prediction on the same segment that was
% %  used to train the TRF.
% % ================================================================
% 
% fprintf('\n====================================================\n');
% fprintf('STEP 6: ET -> EEG forward TRF\n');
% fprintf('====================================================\n');
% 
% 
% % ---------------------------------------------------------------
% % Result structure
% % ---------------------------------------------------------------
% 
% RES_ENV_ET = struct();
% 
% 
% for iband = 1:numel(bandNames)
%     
%     fprintf('\n\n############################################\n');
%     fprintf('BAND: %s\n',bandNames{iband});
%     fprintf('############################################\n');
%     
%     
%     for icond = 1:2
%         
%         fprintf('\n--------------------------------------------\n');
%         fprintf('%s\n',condLabels{icond});
%         fprintf('--------------------------------------------\n');
%         
%         
%         %% --------------------------------------------------------
%         % Subjects with enough segments
%         % --------------------------------------------------------
%         
%         validSubs = find(validSubBand(:,icond));
%         
%         nValid = numel(validSubs);
%         
%         fprintf('Subjects: %d\n',nValid);
%         
%         
%         if nValid == 0
%             
%             RES_ENV_ET(iband,icond).cond = condLabels{icond};
%             
%             RES_ENV_ET(iband,icond).band = bandNames{iband};
%             
%             RES_ENV_ET(iband,icond).validSubs = [];
%             
%             continue
%             
%         end
%         
%         
%         %% --------------------------------------------------------
%         % Storage
%         % --------------------------------------------------------
%         
%         rOwn = nan(nValid,1);
%         
%         lambdaSub = nan(nValid,1);
%         
%         Wsub = cell(nValid,1);
%         
%         nSegSub = zeros(nValid,1);
%         
%         validSubjectResult = false(nValid,1);
%         
%         
%         %% --------------------------------------------------------
%         % Subject loop
%         % --------------------------------------------------------
%         
%         for si = 1:nValid
%             
%             sub = validSubs(si);
%             
%             fprintf('\n%s | %s | %s\n', ...
%                 selection{sub}, ...
%                 condLabels{icond}, ...
%                 bandNames{iband});
%             
%             
%             %% ----------------------------------------------------
%             % Get predictor segments
%             % ----------------------------------------------------
%             
%             ETall = ETband{sub,icond,iband};
%             ENVall = ENVsegments{sub,icond};
%             Yall = EEGsegments{sub,icond};
%             
%             % Construct the multivariate predictor
%             Xall = cell(size(Yall));
%             
%             for k = 1:numel(Yall)
%                 
%                 Xall{k} = [ ...
%                     ENVall{k}(:), ...
%                     ETall{k}(:) ...
%                     ];
%                 
%             end
%             
%             
%             %% ----------------------------------------------------
%             % Remove empty segments
%             % ----------------------------------------------------
%             
%             keep = true(1,numel(Xall));
%             
%             for k = 1:numel(Xall)
%                 
%                 if isempty(Xall{k}) || isempty(Yall{k})
%                     keep(k) = false;
%                 end
%                 
%             end
%             
%             Xall = Xall(keep);
%             Yall = Yall(keep);
%             
%             
%             %% ----------------------------------------------------
%             % Check segment number
%             % ----------------------------------------------------
%             
%             if numel(Xall) < minSegments
%                 
%                 fprintf('  Not enough usable segments.\n');
%                 
%                 continue
%                 
%             end
%             
%             nSegSub(si) = numel(Xall);
%             
%             
%             %% ----------------------------------------------------
%             % Check all segments
%             % ----------------------------------------------------
%             
%             keepSeg = true(1,numel(Xall));
%             
%             for k = 1:numel(Xall)
%                 
%                 L = min(size(Xall{k},1),length(Yall{k}));
%                 
%                 Xall{k} = Xall{k}(1:L,:);
%                 Yall{k} = Yall{k}(1:L);
%                 
%                 if any(~isfinite(Xall{k}(:))) || ...
%                         any(~isfinite(Yall{k}))
%                     
%                     keepSeg(k) = false;
%                     
%                 end
%                 
%             end
%             
%             Xall = Xall(keepSeg);
%             Yall = Yall(keepSeg);
%             
%             
%             if numel(Xall) < minSegments
%                 
%                 fprintf('  Not enough finite segments.\n');
%                 
%                 continue
%                 
%             end
%             %% ----------------------------------------------------
%             % Lambda selection
%             %
%             % mTRFcrossval performs cross-validation across the
%             % available segments.
%             % ----------------------------------------------------
%             
%             fprintf('  Cross-validating lambda...\n');
%             
%             cv = mTRFcrossval( ...
%                 Xall, ...
%                 Yall, ...
%                 fsEEG, ...
%                 dirTRF, ...
%                 tmin, ...
%                 tmax, ...
%                 lambdas, ...
%                 'method',regMethod, ...
%                 'verbose',0);
%             
%             
%             %% ----------------------------------------------------
%             % Average r across folds
%             %
%             % cv.r dimensions are toolbox-dependent. The same
%             % squeeze/mean strategy as your speech code is used.
%             % ----------------------------------------------------
%             
%             rLambda = squeeze( ...
%                 mean(mean(cv.r,1),3));
%             
%             
%             %% ----------------------------------------------------
%             % Select lambda
%             % ----------------------------------------------------
%             
%             lamUse = pickLambda(rLambda);
%             
%             lambdaSub(si) = lamUse;
%             
%             fprintf('  Selected lambda = %g\n',lamUse);
%             
%             
%             %% ----------------------------------------------------
%             % Leave-one-segment-out prediction
%             % ----------------------------------------------------
%             
%             predAll = cell(1,numel(Xall));
%             
%             obsAll = cell(1,numel(Xall));
%             
%             Wtmp = cell(1,numel(Xall));
%             
%             
%             for k = 1:numel(Xall)
%                 
%                 trainIdx = setdiff(1:numel(Xall),k);
%                 
%                 testIdx = k;
%                 
%                 
%                 %% ------------------------------------------------
%                 % Train
%                 % ------------------------------------------------
%                 
%                 m = mTRFtrain( ...
%                     Xall(trainIdx), ...
%                     Yall(trainIdx), ...
%                     fsEEG, ...
%                     dirTRF, ...
%                     tmin, ...
%                     tmax, ...
%                     lamUse, ...
%                     'method',regMethod, ...
%                     'verbose',0);
%                 
%                 
%                 %% ------------------------------------------------
%                 % Predict held-out segment
%                 % ------------------------------------------------
%                 
%                 [pred,~] = mTRFpredict( ...
%                     {Xall{testIdx}}, ...
%                     {Yall{testIdx}}, ...
%                     m, ...
%                     'verbose',0);
%                 
%                 
%                 % mTRFpredict can return either a numeric array or a cell array
%                 % depending on the toolbox version / input format.
%                 
%                 if iscell(pred)
%                     
%                     predAll{k} = pred{1};
%                     
%                 else
%                     
%                     predAll{k} = pred;
%                     
%                 end
%                 
%                 
%                 predAll{k} = predAll{k}(:);
%                 
%                 obsAll{k} = Yall{testIdx}(:);
%                 
%                 Wtmp{k} = m;
%                 
%                 
%             end
%             
%             
%             %% ----------------------------------------------------
%             % Concatenate held-out predictions
%             %
%             % IMPORTANT:
%             % These are only concatenated AFTER prediction.
%             % We never concatenate the original ET segments before
%             % model estimation.
%             % ----------------------------------------------------
%             
%             predConcat = [];
%             
%             obsConcat = [];
%             
%             for k = 1:numel(predAll)
%                 
%                 predConcat = ...
%                     [predConcat; predAll{k}(:)];
%                 
%                 obsConcat = ...
%                     [obsConcat; obsAll{k}(:)];
%                 
%             end
%             
%             
%             %% ----------------------------------------------------
%             % Prediction correlation
%             % ----------------------------------------------------
%             
%             good = ...
%                 isfinite(predConcat) & ...
%                 isfinite(obsConcat);
%             
%             
%             if sum(good) >= 3
%                 
%                 rOwn(si) = corr( ...
%                     predConcat(good), ...
%                     obsConcat(good), ...
%                     'type','Pearson');
%                 
%                 validSubjectResult(si) = true;
%                 
%             end
%             
%             
%             %% ----------------------------------------------------
%             % Final TRF
%             %
%             % Train on ALL available segments using the selected
%             % lambda. This TRF is stored for plotting/interpreting
%             % the subject-level model.
%             % ----------------------------------------------------
%             
%             mFinal = mTRFtrain( ...
%                 Xall, ...
%                 Yall, ...
%                 fsEEG, ...
%                 dirTRF, ...
%                 tmin, ...
%                 tmax, ...
%                 lamUse, ...
%                 'method',regMethod, ...
%                 'verbose',0);
%             
%             
%             Wsub{si} = mFinal;
%             
%             
%             fprintf('  rOwn = %.4f\n',rOwn(si));
%             
%         end
%         
%         
%         %% ========================================================
%         % STORE RESULTS
%         % ========================================================
%         
%         %         RES_ET(iband,icond).cond = condLabels{icond};
%         %
%         %         RES_ET(iband,icond).band = bandNames{iband};
%         %
%         %         RES_ET(iband,icond).validSubs = validSubs;
%         %
%         %         RES_ET(iband,icond).validSubjectResult = ...
%         %             validSubjectResult;
%         %
%         %         RES_ET(iband,icond).rOwn = rOwn;
%         %
%         %         RES_ET(iband,icond).lambda = lambdaSub;
%         %
%         %         RES_ET(iband,icond).WsubOwn = Wsub;
%         %
%         %         RES_ET(iband,icond).nSegments = nSegSub;
%         %
%         %         RES_ET(iband,icond).fs = fsEEG;
%         %
%         %         RES_ET(iband,icond).tmin = tmin;
%         %
%         %         RES_ET(iband,icond).tmax = tmax;
%         %
%         %         RES_ET(iband,icond).bandRange = ...
%         %             bandRange{iband};
%         %
%         %         RES_ET(iband,icond).regMethod = ...
%         %             regMethod;
%         
%         RES_ENV_ET(iband,icond).cond = condLabels{icond};
%         RES_ENV_ET(iband,icond).band = bandNames{iband};
%         RES_ENV_ET(iband,icond).validSubs = validSubs;
%         RES_ENV_ET(iband,icond).validSubjectResult = validSubjectResult;
%         RES_ENV_ET(iband,icond).rOwn = rOwn;
%         RES_ENV_ET(iband,icond).lambda = lambdaSub;
%         RES_ENV_ET(iband,icond).WsubOwn = Wsub;
%         RES_ENV_ET(iband,icond).nSegments = nSegSub;
%         RES_ENV_ET(iband,icond).fs = fsEEG;
%         RES_ENV_ET(iband,icond).tmin = tmin;
%         RES_ENV_ET(iband,icond).tmax = tmax;
%         RES_ENV_ET(iband,icond).bandRange = bandRange{iband};
%         RES_ENV_ET(iband,icond).regMethod = regMethod;
%         RES_ENV_ET(iband,icond).predictors = {'Envelope','ET'};
%         
%         %% ========================================================
%         % TRF TIME AXIS
%         % ========================================================
%         
%         if ~isempty(Wsub)
%             
%             firstValid = find(~cellfun(@isempty,Wsub),1);
%             
%             if ~isempty(firstValid)
%                 
%                 if isfield(Wsub{firstValid},'t')
%                     
%                     RES_ENV_ET(iband,icond).tAxis = ...
%                         Wsub{firstValid}.t;
%                     
%                 elseif isfield(Wsub{firstValid},'time')
%                     
%                     RES_ENV_ET(iband,icond).tAxis = ...
%                         Wsub{firstValid}.time;
%                     
%                 end
%                 
%             end
%             
%         end
%         
%         
%         %% ========================================================
%         % SAVE SUBJECT-LEVEL RESULTS
%         % ========================================================
%         
%         fprintf('\nSummary: %s / %s\n', ...
%             bandNames{iband},condLabels{icond});
%         
%         goodR = isfinite(rOwn);
%         
%         if any(goodR)
%             
%             fprintf('  N = %d\n',sum(goodR));
%             
%             fprintf('  Mean r = %.4f\n', ...
%                 mean(rOwn(goodR)));
%             
%             fprintf('  Median r = %.4f\n', ...
%                 median(rOwn(goodR)));
%             
%             fprintf('  SD r = %.4f\n', ...
%                 std(rOwn(goodR)));
%             
%         else
%             
%             fprintf('  No valid prediction correlations.\n');
%             
%         end
%         
%     end
%     
% end

%% ================================================================
% STEP 6
% PREPARE DATA FOR THE THREE TRF MODELS
%
% Model 1: Envelope only
% Model 2: Eye tracking only
% Model 3: Envelope + Eye tracking
% ================================================================

% ---------------------------------------------------------------
% Collect all valid segments for each subject
% ---------------------------------------------------------------

ENVall = cell(1,nSubs);
ETall  = cell(1,nSubs);
Yall  = cell(1,nSubs);

for sub = 1:nSubs

    % -----------------------------------------------------------
    % Envelope
    % -----------------------------------------------------------

    envSegs = ENVsegments{sub,icond};

    if isempty(envSegs)
        continue
    end

    envSegs = envSegs(~cellfun(@isempty,envSegs));

    % -----------------------------------------------------------
    % Eye tracking
    % -----------------------------------------------------------

    etSegs = ETsegments{sub,icond};

    if isempty(etSegs)
        continue
    end

    etSegs = etSegs(~cellfun(@isempty,etSegs));

    % -----------------------------------------------------------
    % EEG
    % -----------------------------------------------------------

    eegSegs = EEGsegments{sub,icond};

    if isempty(eegSegs)
        continue
    end

    eegSegs = eegSegs(~cellfun(@isempty,eegSegs));


    % -----------------------------------------------------------
    % Make sure the number of segments agrees
    % -----------------------------------------------------------

    if numel(envSegs) ~= numel(etSegs) || ...
       numel(envSegs) ~= numel(eegSegs)

        error(['Subject %d: different numbers of ENV, ET ' ...
               'and EEG segments.'],sub);

    end


    % -----------------------------------------------------------
    % Concatenate segments within subject
    % -----------------------------------------------------------

    ENVall{sub} = vertcat(envSegs{:});
    ETall{sub}  = vertcat(etSegs{:});
    Yall{sub}   = vertcat(eegSegs{:});


    % -----------------------------------------------------------
    % Check lengths
    % -----------------------------------------------------------

    if length(ENVall{sub}) ~= length(ETall{sub}) || ...
       length(ENVall{sub}) ~= length(Yall{sub})

        error(['Subject %d: ENV, ET and EEG have different ' ...
               'numbers of samples after concatenation.'],sub);

    end


    % -----------------------------------------------------------
    % Check finite values
    % -----------------------------------------------------------

    if any(~isfinite(ENVall{sub})) || ...
       any(~isfinite(ETall{sub})) || ...
       any(~isfinite(Yall{sub}))

        error(['Subject %d contains NaN or Inf after ' ...
               'concatenation.'],sub);

    end

end
% ================================================================
% THREE PREDICTOR MATRICES
% ================================================================

XEnv  = cell(1,nSubs);
XET   = cell(1,nSubs);
XBoth = cell(1,nSubs);

for sub = 1:nSubs

    if isempty(Yall{sub})
        continue
    end

    % Envelope only
    XEnv{sub} = ENVall{sub}(:);

    % ET only
    XET{sub} = ETall{sub}(:);

    % Envelope + ET
    XBoth{sub} = [ ...
        ENVall{sub}(:), ...
        ETall{sub}(:) ...
        ];

end

% ================================================================
% MODEL 1
% ENVELOPE ONLY
% ================================================================

fprintf('\n');
fprintf('================================================\n');
fprintf('MODEL 1: ENVELOPE ONLY\n');
fprintf('================================================\n');

Xall = XEnv;

% ---------------------------------------------------------------
% Lambda selection
% ---------------------------------------------------------------
fprintf('\n========== XEnv structure ==========\n');

fprintf('Number of cells: %d\n',numel(XEnv));

for k = 1:min(10,numel(XEnv))

    if isempty(XEnv{k})
        fprintf('XEnv{%d}: EMPTY\n',k);
    else
        fprintf('XEnv{%d}: [%d x %d]\n', ...
            k,size(XEnv{k},1),size(XEnv{k},2));
    end

end

fprintf('\n========== Yall structure ==========\n');

fprintf('Number of cells: %d\n',numel(Yall));

for k = 1:min(10,numel(Yall))

    if isempty(Yall{k})
        fprintf('Yall{%d}: EMPTY\n',k);
    else
        fprintf('Yall{%d}: [%d x %d]\n', ...
            k,size(Yall{k},1),size(Yall{k},2));
    end

end
disp(validSubs)
whos validSubs Xall
cv = mTRFcrossval( ...
    Xall(validSubs), ...
    Yall(validSubs), ...
    fsEEG, ...
    dirTRF, ...
    tmin, ...
    tmax, ...
    lambdas, ...
    'method',regMethod, ...
    'verbose',0);

rLambda = squeeze(mean(mean(cv.r,1),3));

lamUse = pickLambda(rLambda);

fprintf('Selected lambda = %.6g\n',lamUse);


% ---------------------------------------------------------------
% LOSO prediction
% ---------------------------------------------------------------

for si = 1:numel(validSubs)

    testSub = validSubs(si);

    trainSubs = validSubs;
    trainSubs(si) = [];

    fprintf('Envelope: testing subject %d (%d/%d)\n', ...
        testSub,si,numel(validSubs));

    % Train
    m = mTRFtrain( ...
        Xall(trainSubs), ...
        Yall(trainSubs), ...
        fsEEG, ...
        dirTRF, ...
        tmin, ...
        tmax, ...
        lamUse, ...
        'method',regMethod, ...
        'verbose',0);

    % Predict held-out subject
    [pred,~] = mTRFpredict( ...
        {Xall{testSub}}, ...
        {Yall{testSub}}, ...
        m, ...
        'verbose',0);

    if iscell(pred)
        pred = pred{1};
    end

    obs = Yall{testSub};

    pred = pred(:);
    obs  = obs(:);

    good = isfinite(pred) & isfinite(obs);

    if sum(good) < 3
        warning('Subject %d: not enough valid samples for correlation.', ...
            testSub);
        continue
    end

    rEnv(testSub) = corr( ...
        pred(good), ...
        obs(good), ...
        'type','Pearson');

    lambdaEnv(testSub) = lamUse;

    WsubEnv{testSub} = m;

end


% ================================================================
% MODEL 2
% EYE TRACKING ONLY
% ================================================================

fprintf('\n');
fprintf('================================================\n');
fprintf('MODEL 2: EYE TRACKING ONLY\n');
fprintf('================================================\n');

Xall = XET;

% ---------------------------------------------------------------
% Lambda selection
% ---------------------------------------------------------------

cv = mTRFcrossval( ...
    Xall(validSubs), ...
    Yall(validSubs), ...
    fsEEG, ...
    dirTRF, ...
    tmin, ...
    tmax, ...
    lambdas, ...
    'method',regMethod, ...
    'verbose',0);

rLambda = squeeze(mean(mean(cv.r,1),3));

lamUse = pickLambda(rLambda);

fprintf('Selected lambda = %.6g\n',lamUse);


% ---------------------------------------------------------------
% LOSO prediction
% ---------------------------------------------------------------

for si = 1:numel(validSubs)

    testSub = validSubs(si);

    trainSubs = validSubs;
    trainSubs(si) = [];

    fprintf('ET: testing subject %d (%d/%d)\n', ...
        testSub,si,numel(validSubs));

    % Train
    m = mTRFtrain( ...
        Xall(trainSubs), ...
        Yall(trainSubs), ...
        fsEEG, ...
        dirTRF, ...
        tmin, ...
        tmax, ...
        lamUse, ...
        'method',regMethod, ...
        'verbose',0);

    % Predict held-out subject
    [pred,~] = mTRFpredict( ...
        {Xall{testSub}}, ...
        {Yall{testSub}}, ...
        m, ...
        'verbose',0);

    if iscell(pred)
        pred = pred{1};
    end

    obs = Yall{testSub};

    pred = pred(:);
    obs  = obs(:);

    good = isfinite(pred) & isfinite(obs);

    if sum(good) < 3
        warning('Subject %d: not enough valid samples for correlation.', ...
            testSub);
        continue
    end

    rET(testSub) = corr( ...
        pred(good), ...
        obs(good), ...
        'type','Pearson');

    lambdaET(testSub) = lamUse;

    WsubET{testSub} = m;

end


% ================================================================
% MODEL 3
% ENVELOPE + EYE TRACKING
% ================================================================

fprintf('\n');
fprintf('================================================\n');
fprintf('MODEL 3: ENVELOPE + ET\n');
fprintf('================================================\n');

Xall = XBoth;

% ---------------------------------------------------------------
% Lambda selection
% ---------------------------------------------------------------

cv = mTRFcrossval( ...
    Xall(validSubs), ...
    Yall(validSubs), ...
    fsEEG, ...
    dirTRF, ...
    tmin, ...
    tmax, ...
    lambdas, ...
    'method',regMethod, ...
    'verbose',0);

rLambda = squeeze(mean(mean(cv.r,1),3));

lamUse = pickLambda(rLambda);

fprintf('Selected lambda = %.6g\n',lamUse);


% ---------------------------------------------------------------
% LOSO prediction
% ---------------------------------------------------------------

for si = 1:numel(validSubs)

    testSub = validSubs(si);

    trainSubs = validSubs;
    trainSubs(si) = [];

    fprintf('Envelope + ET: testing subject %d (%d/%d)\n', ...
        testSub,si,numel(validSubs));

    % Train
    m = mTRFtrain( ...
        Xall(trainSubs), ...
        Yall(trainSubs), ...
        fsEEG, ...
        dirTRF, ...
        tmin, ...
        tmax, ...
        lamUse, ...
        'method',regMethod, ...
        'verbose',0);

    % Predict held-out subject
    [pred,~] = mTRFpredict( ...
        {Xall{testSub}}, ...
        {Yall{testSub}}, ...
        m, ...
        'verbose',0);

    if iscell(pred)
        pred = pred{1};
    end

    obs = Yall{testSub};

    pred = pred(:);
    obs  = obs(:);

    good = isfinite(pred) & isfinite(obs);

    if sum(good) < 3
        warning('Subject %d: not enough valid samples for correlation.', ...
            testSub);
        continue
    end

    rBoth(testSub) = corr( ...
        pred(good), ...
        obs(good), ...
        'type','Pearson');

    lambdaBoth(testSub) = lamUse;

    WsubBoth{testSub} = m;

end

%% ================================================================
% STORE RESULTS
% ================================================================

RESULTS_R(iband,icond).condition = condLabels{icond};

RESULTS_R(iband,icond).rEnv = rEnv;
RESULTS_R(iband,icond).rET = rET;
RESULTS_R(iband,icond).rBoth = rBoth;

RESULTS_R(iband,icond).lambdaEnv = lambdaEnv;
RESULTS_R(iband,icond).lambdaET = lambdaET;
RESULTS_R(iband,icond).lambdaBoth = lambdaBoth;

RESULTS_R(iband,icond).validSubs = validSubs;

RESULTS_R(iband,icond).WsubEnv = WsubEnv;
RESULTS_R(iband,icond).WsubET = WsubET;
RESULTS_R(iband,icond).WsubBoth = WsubBoth;

RESULTS_R(iband,icond).predictors = ...
    {'Envelope','ET','Envelope + ET'};
% %% ================================================================
% %  STEP 7
% %  SAVE RESULTS
% % ================================================================
% 
% if ~exist(savePath,'dir')
%     mkdir(savePath);
% end
% 
% saveFile = fullfile( ...
%     savePath, ...
%     'NeuroLip_ET_EEG_forwardTRF.mat');
% 
% save( ...
%     saveFile, ...
%     'RES_ENV_ET', ...
%     'selection', ...
%     'condLabels', ...
%     'bandNames', ...
%     'bandRange', ...
%     'fsEEG', ...
%     'fsET', ...
%     'lambdas', ...
%     'tmin', ...
%     'tmax', ...
%     'minSegDuration', ...
%     'minSegments', ...
%     'segmentInfo', ...
%     'nSegments', ...
%     '-v7.3');
% 
% 
% fprintf('\n====================================================\n');
% fprintf('DONE\n');
% fprintf('Results saved to:\n%s\n',saveFile);
% fprintf('====================================================\n');


%% ================================================================
%  STEP 8
%  BASIC PLOT: rOwn CLEAR VS VOCODED
% ================================================================

Color_clear = [222,161,147]./255;

Color_vocoded = [206,12,12]./255;


for iband = 1:numel(bandNames)
    
    rClear = RES_ENV_ET(iband,1).rOwn;
    
    rVoc = RES_ENV_ET(iband,2).rOwn;
    
    subClear = RES_ENV_ET(iband,1).validSubs;
    
    subVoc = RES_ENV_ET(iband,2).validSubs;
    
    
    figure( ...
        'Position',[100 100 900 650], ...
        'Color','white');
    
    hold on;
    
    %% ------------------------------------------------------------
    % Connect Clear and Vocoded values for the same participant
    % ------------------------------------------------------------
    
    commonSubs = intersect(subClear, subVoc);
    
    for i = 1:numel(commonSubs)
        
        thisSub = commonSubs(i);
        
        idxClear = find(subClear == thisSub);
        idxVoc = find(subVoc == thisSub);
        
        if isfinite(rClear(idxClear)) && isfinite(rVoc(idxVoc))
            
            plot( ...
                [1 2], ...
                [rClear(idxClear) rVoc(idxVoc)], ...
                '-', ...
                'Color',[0.6 0.6 0.6], ...
                'LineWidth',0.8);
            
        end
        
    end
    %% ------------------------------------------------------------
    % Clear individual values
    % ------------------------------------------------------------
    
    good = isfinite(rClear);
    
    rClearGood = rClear(good);
    
    % Positions of the valid values within rClear
    idxClear = find(good);
    
    % Corresponding participant indices in the original selection
    subClearGood = subClear(idxClear);
    
    x1 = 1;
    jitter1 = 0.08*(rand(numel(rClearGood),1)-0.5);
    
    plot( ...
        x1+jitter1, ...
        rClearGood, ...
        'o', ...
        'MarkerSize',7, ...
        'MarkerFaceColor',Color_clear, ...
        'MarkerEdgeColor','k');
    
    
    % Add the correct ID to each point
    for i = 1:numel(rClearGood)
        
        thisSub = subClearGood(i);
        
        id = strrep(selection{thisSub}, 'CND_', '');
        id = strrep(id, '.mat', '');
        
        text( ...
            x1+jitter1(i), ...
            rClearGood(i), ...
            id, ...
            'VerticalAlignment','bottom', ...
            'HorizontalAlignment','center', ...
            'FontSize',11);
        
    end
    
    %% ------------------------------------------------------------
    % Vocoded individual values
    % ------------------------------------------------------------
    
    good = isfinite(rVoc);
    
    rVocGood = rVoc(good);
    
    % Positions of the valid values within rVoc
    idxVoc = find(good);
    
    % Corresponding participant indices in the original selection
    subVocGood = subVoc(idxVoc);
    
    x2 = 2;
    jitter2 = 0.08*(rand(numel(rVocGood),1)-0.5);
    
    plot( ...
        x2+jitter2, ...
        rVocGood, ...
        'o', ...
        'MarkerSize',7, ...
        'MarkerFaceColor',Color_vocoded, ...
        'MarkerEdgeColor','k');
    
    
    % Add the correct ID to each point
    for i = 1:numel(rVocGood)
        
        thisSub = subVocGood(i);
        id = strrep(selection{thisSub}, 'CND_', '');
        id = strrep(id, '.mat', '');
        text( ...
            x2+jitter2(i), ...
            rVocGood(i), ...
            id, ...
            'VerticalAlignment','bottom', ...
            'HorizontalAlignment','center', ...
            'FontSize',11);
        
    end
    %% ------------------------------------------------------------
    % Means
    % ------------------------------------------------------------
    
    if any(isfinite(rClear))
        
        plot( ...
            x1, ...
            mean(rClear,'omitnan'), ...
            'ks', ...
            'MarkerSize',10, ...
            'MarkerFaceColor','k');
        
    end
    
    
    if any(isfinite(rVoc))
        
        plot( ...
            x2, ...
            mean(rVoc,'omitnan'), ...
            'ks', ...
            'MarkerSize',10, ...
            'MarkerFaceColor','k');
        
    end
    
    
    %% ------------------------------------------------------------
    % Zero line
    % ------------------------------------------------------------
    
    yline(0,'k--');
    
    
    xlim([0.7 2.3]);
    
    set(gca, ...
        'XTick',[1 2], ...
        'XTickLabel',condLabels, ...
        'FontSize',13);
    
    ylabel('Prediction correlation (r)');
    
    title(['Envelope + ET \rightarrow EEG: ' bandNames{iband}]);
    
    box off;
    
end
%% ================================================================
% STEP 8B
% COMBINED ENVELOPE + ET TRFs
%
% Row 1 = speech envelope
% Row 2 = eye tracking
%
% Condition 1 = Clear
% Condition 2 = Vocoded
% ================================================================

iband = 1;

Color_clear   = [222,161,147]./255;
Color_vocoded = [206,12,12]./255;


% ---------------------------------------------------------------
% CLEAR
% ---------------------------------------------------------------

Wsub = RES_ENV_ET(iband,1).WsubOwn;

firstValid = find(~cellfun(@isempty,Wsub),1);

if isempty(firstValid)
    error('No valid Clear TRF models found.');
end

tClear = Wsub{firstValid}.t;

WenvClear = [];
WetClear  = [];

for si = 1:numel(Wsub)

    if isempty(Wsub{si})
        continue
    end

    w = squeeze(Wsub{si}.w);

    fprintf('Clear - subject %d: [%d x %d]\n', ...
        si,size(w,1),size(w,2));

    if size(w,1) ~= 2
        error(['Clear subject %d: expected 2 x lags, ' ...
               'but obtained [%d x %d].'], ...
               si,size(w,1),size(w,2));
    end

    % Row 1 = envelope
    % Row 2 = eye tracking

    wEnv = w(1,:);
    wET  = w(2,:);

    WenvClear(si,1:length(wEnv)) = wEnv;
    WetClear(si,1:length(wET))   = wET;

end


% ---------------------------------------------------------------
% VOCODED
% ---------------------------------------------------------------

Wsub = RES_ENV_ET(iband,2).WsubOwn;

firstValid = find(~cellfun(@isempty,Wsub),1);

if isempty(firstValid)
    error('No valid Vocoded TRF models found.');
end

tVoc = Wsub{firstValid}.t;

WenvVoc = [];
WetVoc  = [];

for si = 1:numel(Wsub)

    if isempty(Wsub{si})
        continue
    end

    w = squeeze(Wsub{si}.w);

    fprintf('Vocoded - subject %d: [%d x %d]\n', ...
        si,size(w,1),size(w,2));

    if size(w,1) ~= 2
        error(['Vocoded subject %d: expected 2 x lags, ' ...
               'but obtained [%d x %d].'], ...
               si,size(w,1),size(w,2));
    end

    % Row 1 = envelope
    % Row 2 = eye tracking

    wEnv = w(1,:);
    wET  = w(2,:);

    WenvVoc(si,1:length(wEnv)) = wEnv;
    WetVoc(si,1:length(wET))   = wET;

end


% ================================================================
% SPEECH ENVELOPE TRF
% ================================================================

figure('Position',[100 100 1000 650],'Color','white');
hold on;

% Individual Clear
for si = 1:size(WenvClear,1)

    if all(isnan(WenvClear(si,:)))
        continue
    end

    plot(tClear,WenvClear(si,:), ...
        'Color',[0.75 0.75 0.75], ...
        'LineWidth',0.7);

end

% Individual Vocoded
for si = 1:size(WenvVoc,1)

    if all(isnan(WenvVoc(si,:)))
        continue
    end

    plot(tVoc,WenvVoc(si,:), ...
        'Color',[0.85 0.65 0.65], ...
        'LineWidth',0.7);

end

% Group means
plot(tClear,mean(WenvClear,1,'omitnan'), ...
    'Color',Color_clear, ...
    'LineWidth',3);

plot(tVoc,mean(WenvVoc,1,'omitnan'), ...
    'Color',Color_vocoded, ...
    'LineWidth',3);

xline(0,'k--');
yline(0,'k--');

xlim([-50 400]);

xlabel('Lag (ms)');
ylabel('TRF weight');

title('Speech envelope \rightarrow EEG');

legend({'Clear individual', ...
        'Vocoded individual', ...
        'Clear mean', ...
        'Vocoded mean'}, ...
        'Location','best');

box off;
set(gca,'FontSize',13);

hold off;

%------- ET TRF 
figure('Position',[100 100 1000 650],'Color','white');
hold on;

% ---------------------------------------------------------------
% Individual Clear
% ---------------------------------------------------------------

for si = 1:size(WetClear,1)

    if all(isnan(WetClear(si,:)))
        continue
    end

    plot(tClear,WetClear(si,:), ...
        'Color',[0.65 0.65 0.65], ...
        'LineWidth',0.8);
end


% ---------------------------------------------------------------
% Individual Vocoded
% ---------------------------------------------------------------

for si = 1:size(WetVoc,1)

    if all(isnan(WetVoc(si,:)))
        continue
    end

    plot(tVoc,WetVoc(si,:), ...
        'Color',[0.95 0.55 0.55], ...
        'LineWidth',0.8);
end


% ---------------------------------------------------------------
% Group means
% ---------------------------------------------------------------

plot(tClear,mean(WetClear,1,'omitnan'), ...
    'Color',Color_clear, ...
    'LineWidth',3);

plot(tVoc,mean(WetVoc,1,'omitnan'), ...
    'Color',Color_vocoded, ...
    'LineWidth',3);


% ---------------------------------------------------------------
% Reference lines
% ---------------------------------------------------------------

xline(0,'k--');
yline(0,'k--');

xlim([-50 400]);

xlabel('Lag (ms)');
ylabel('TRF weight');

title('Eye tracking \rightarrow EEG');

legend({'Clear individual', ...
        'Vocoded individual', ...
        'Clear mean', ...
        'Vocoded mean'}, ...
        'Location','best');

box off;
set(gca,'FontSize',13);

hold off;

%% ================================================================
% Prediction correlation r: Clear vs Vocoded
% Combined Envelope + Eye-tracking model
% ================================================================

iband = 1;

rClear  = RES_ENV_ET(iband,1).rOwn;
rVoc    = RES_ENV_ET(iband,2).rOwn;

subClear = RES_ENV_ET(iband,1).validSubs;
subVoc   = RES_ENV_ET(iband,2).validSubs;


%%Find participants present in both conditions

[commonSubs,idxClear,idxVoc] = intersect(subClear,subVoc);

rClearPaired = rClear(idxClear);
rVocPaired   = rVoc(idxVoc);


% Figure

figure('Position',[100 100 700 650],'Color','white');
hold on;


% Individual paired lines

for si = 1:length(commonSubs)

    plot([1 2], ...
         [rClearPaired(si) rVocPaired(si)], ...
         '-o', ...
         'Color',[0.65 0.65 0.65], ...
         'MarkerFaceColor',[0.65 0.65 0.65], ...
         'MarkerEdgeColor',[0.65 0.65 0.65], ...
         'LineWidth',0.8, ...
         'MarkerSize',5);

end


% Group means

meanClear = mean(rClearPaired,'omitnan');
meanVoc   = mean(rVocPaired,'omitnan');

plot(1,meanClear, ...
    'o', ...
    'Color',Color_clear, ...
    'MarkerFaceColor',Color_clear, ...
    'MarkerSize',10, ...
    'LineWidth',2);

plot(2,meanVoc, ...
    'o', ...
    'Color',Color_vocoded, ...
    'MarkerFaceColor',Color_vocoded, ...
    'MarkerSize',10, ...
    'LineWidth',2);


% Connect means

plot([1 2], ...
     [meanClear meanVoc], ...
     'k-', ...
     'LineWidth',2);


% Axes

xlim([0.7 2.3]);

xticks([1 2]);
xticklabels({'Clear','Vocoded'});

ylabel('Prediction correlation (r)');

title('Combined Envelope + Eye-tracking model');

box off;
set(gca,'FontSize',13);

hold off;


%%

iband = 1;      % broad
icond = 1;      % Clear

Wsub = RES_ENV_ET(iband,icond).WsubOwn;
validSubs = RES_ENV_ET(iband,icond).validSubs;

t = RES_ENV_ET(iband,icond).tAxis;

figure('Position',[100 100 1000 650],'Color','white');
hold on;

W = [];

for si = 1:numel(Wsub)
    
    if isempty(Wsub{si})
        continue
    end
    
    w = Wsub{si}.w;
    
    w = w(:);
    
    W(si,1:length(w)) = w';
    
    plot(t,w,'Color',[0.7 0.7 0.7], ...
        'LineWidth',0.8);
    
end

% Group mean
groupMean = mean(W,1,'omitnan');

plot(t,groupMean,'k','LineWidth',3);

xline(0,'k--');
yline(0,'k--');

xlim([-50 400]);

xlabel('Lag (ms)');
ylabel('TRF weight');

title(sprintf('ET \rightarrow EEG TRF: %s | %s', ...
    RES_ENV_ET(iband,icond).cond, ...
    RES_ENV_ET(iband,icond).band));

box off;
set(gca,'FontSize',13);

hold off;

%% ================================================================
%  LOCAL FUNCTIONS
% ================================================================


function y = local_bp(x,lo,hi,fs)

ny = fs/2;

if lo <= 0
    
    [b,a] = butter(3,hi/ny);
    
elseif hi >= ny
    
    [b,a] = butter(3,lo/ny,'high');
    
else
    
    [b,a] = butter(3,[lo hi]/ny,'bandpass');
    
end

y = filtfilt(b,a,x);

end



function lam = local_pickLambda(rLambda,lambdas,tolerancePercent,useTolerance)

rLambda = rLambda(:);

lambdas = lambdas(:);

if numel(rLambda) ~= numel(lambdas)
    
    error(['Number of lambda values does not match number ' ...
        'of cross-validation values.']);
    
end


%% ---------------------------------------------------------------
% Remove invalid values
% ---------------------------------------------------------------

good = isfinite(rLambda);

if ~any(good)
    
    error('No valid cross-validation correlations for lambda selection.');
    
end

rGood = rLambda(good);

lGood = lambdas(good);


%% ---------------------------------------------------------------
% Maximum CV correlation
% ---------------------------------------------------------------

[maxR,idxMax] = max(rGood);


%% ---------------------------------------------------------------
% Standard choice:
% lambda with highest CV correlation
% ---------------------------------------------------------------

lam = lGood(idxMax);


%% ---------------------------------------------------------------
% Optional tolerance rule
%
% Choose the smallest lambda whose performance is within
% tolerancePercent of the maximum.
% ---------------------------------------------------------------

if useTolerance
    
    threshold = maxR*(1-tolerancePercent);
    
    idx = find(rGood >= threshold);
    
    if ~isempty(idx)
        
        lam = lGood(idx(1));
        
    end
    
end

end

