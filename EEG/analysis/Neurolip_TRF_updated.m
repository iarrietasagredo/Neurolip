% This code was adapted by Irene Arrieta from that of
% Giorgio Piazza

clear
close all
clc

set(0,'DefaultFigureVisible','on')

%% ================================================================
% PATHS
% ================================================================

addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/datasets
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/datasets/irene_trial_12_04
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/cnsp_utils/cnd
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/cnsp_utils
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/eeglab2026.0.0
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/code
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/mTRF-Toolbox_v2/mtrf
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/fieldtrip

%% ================================================================
% DATA
% ================================================================

pathDataPrep = ...
    '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed';

pathDataEEG_NIRS_ET = ...
    '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/CND_data_format';

savePath = ...
    '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results';

files = dir(fullfile(pathDataEEG_NIRS_ET,'CND*'));

out_peak = [];

selection = setdiff({files(:).name},out_peak);

nSubs = numel(selection);

fprintf('Found %d NeuroLip files\n',nSubs);

%% ================================================================
% GENERAL PARAMETERS
% ================================================================

condLabels = {'Clear','Vocoded'};

audioName = 'Audio';

Chan2Plot = 'F2';

forceElec = 'auto';

nSD = 3;
minTrials = 3;
minContrib = 3;

%% ================================================================
% QUALITY ASSESSMENT
% ================================================================

% badTrial{sub} will now have the SAME number of entries as the
% original trial array. This is important because EEG, stimulus and
% monologue indices must remain aligned.

subMedRMS = nan(1,nSubs);
badTrial = cell(1,nSubs);

for sub = 1:nSubs
    
    tmp = load(fullfile(pathDataEEG_NIRS_ET,selection{sub}));
tmp = tmp.eeg;
eegRows = tmp.data;
    
    eegRows = tmp.data;
    
    % Number of ORIGINAL trials
    nOriginalTrials = numel(eegRows);
    
    % badTrial is indexed according to ORIGINAL trial number
    btOriginal = false(1,nOriginalTrials);
    
    % Find non-empty EEG trials
    idx_nonempty = find(~cellfun(@isempty,eegRows));
    data_nonempty = eegRows(idx_nonempty);
    
    nTrl = numel(data_nonempty);
    
    rms1 = nan(1,nTrl);
    
    for k = 1:nTrl
        
        E = data_nonempty{k};
        
        rms1(k) = sqrt(mean(E(:).^2));
        
    end
    
    % ------------------------------------------------------------
    % Trial-level rejection using MAD
    % ------------------------------------------------------------
    
    med = median(rms1,'omitnan');
    
    madv = 1.4826 * median(abs(rms1-med),'omitnan');
    
    if madv == 0
        madv = eps;
    end
    
    bt = abs(rms1-med) > nSD*madv;
    
    % Put rejection decisions back into ORIGINAL trial positions
    btOriginal(idx_nonempty) = bt;
    
    badTrial{sub} = btOriginal;
    
    subMedRMS(sub) = median(rms1(~bt),'omitnan');
    
    fprintf('sub %2d: medRMS=%.3g  trials rejected %d/%d %s\n', ...
        sub,...
        subMedRMS(sub),...
        sum(bt),...
        nTrl,...
        mat2str(idx_nonempty(bt)));
    
end

%% ================================================================
% SUBJECT-LEVEL REJECTION
% ================================================================

gMed = median(subMedRMS,'omitnan');

gMAD = 1.4826 * median(abs(subMedRMS-gMed),'omitnan');

if gMAD == 0
    gMAD = eps;
end

keepSub = ...
    abs(subMedRMS-gMed) <= nSD*gMAD & ...
    ~isnan(subMedRMS);

%% ================================================================
% CHECK NUMBER OF USABLE TRIALS PER CONDITION
% ================================================================

nC1 = nan(1,nSubs);
nC2 = nan(1,nSubs);

for sub = 1:nSubs
    
    tmp = load(fullfile(pathDataEEG_NIRS_ET,selection{sub}));
tmp = tmp.eeg;
eegRows = tmp.data;
    
    nOriginalTrials = numel(tmp.data);
    
    good = ~badTrial{sub};
    
    % Make sure cond has the same number of entries as trials
    cond = tmp.cond(:)';
    
    if numel(cond) ~= nOriginalTrials
        error('Subject %d: cond (%d entries) and data (%d trials) do not match.',...
            sub,numel(cond),nOriginalTrials);
    end
    
    % Only non-empty EEG trials count as usable
    nonemptyEEG = ~cellfun(@isempty,tmp.data);
    
    good = good & nonemptyEEG;
    
    nC1(sub) = sum(good & cond == 1);
    nC2(sub) = sum(good & cond == 2);
    
end

keepSub = ...
    keepSub & ...
    (nC1 >= minTrials) & ...
    (nC2 >= minTrials);

fprintf('\nGroup medRMS=%.3g MAD=%.3g | subjects kept %d/%d\n',...
    gMed,gMAD,sum(keepSub),nSubs);

fprintf('Dropped (amp or <%d trials): %s\n',...
    minTrials,mat2str(find(~keepSub)));

%% ================================================================
% TRF PARAMETERS
% ================================================================

for iiStim = 1
    
    lambdas = 10.^(-3:6);
    
    dirTRF = 1;
    
    tmin = -100;
    tmax = 500;
    
    plotXlim = [-50 400];
    
    regMethod = 'Ridge';
    
    lambdaTune = 'own';
    
    avgElectrodes = true;
    
    roiElec = {'F1','Fz','F2','C1','C2','Cz'};
    
    tolerancePercent = 0.05;
    
    useToleranceLambda = true;
    
    nPerm = 500;
    
    bandNames = {'broad','delta','theta'};
    
    bandRange = {
        [1 8],...
        [1 4],...
        [4 8]
        };
    
    nB = numel(bandNames);
    
    bBroad = 1;
    
    broadUsesNative = true;
    
    filterPred = false;
    
    nullType = 'mismatch';
    
    pickLambda = @(rl) local_pickLambda(...
        rl,...
        lambdas,...
        tolerancePercent,...
        useToleranceLambda);
    
    figure(...
        'Position',[100,100,1050,820],...
        'Color','white',...
        'Name','NeuroLip forward TRF v3');
    
    RESp = struct();
    
    %% ============================================================
    % CONDITIONS
    % =============================================================
    
    for iicond = 1:2
        
        condVal = iicond;
        condName = condLabels{iicond};
        
        clear eegGroup stimGroup codeGroup labGroup
        
        validSubs = [];
        
        %% --------------------------------------------------------
        % LOAD
        % --------------------------------------------------------
        
        for sub = 1:nSubs
            
            if ~keepSub(sub)
                continue
            end
            
            tmp = load(fullfile(...
                pathDataEEG_NIRS_ET,...
                selection{sub}));
            
            tmp = tmp.eeg;
            
            % Trials to remove: other condition, or rejected in the quality assessment
            rm = (tmp.cond(:)' ~= condVal) | badTrial{sub};   % NaN cond (empty slot) also counts as removed
            
            eeg  = tmp;
            stim = cellfun(@(x) x(:, 1:min(1,size(x,2))), tmp.stim, 'UniformOutput', false);
            
            eeg.data(rm) = {[]};
            stim(rm)     = {[]};
            
            codes = tmp.monologue(:)';
            codes(rm) = NaN;          % so the GT search cannot land on a removed slot
            
            labs = {tmp.chanlocs.labels};
            
            eegGroup{sub}  = eeg;
            stimGroup{sub} = stim;
            labGroup{sub}  = labs;
            codeGroup{sub} = codes;
            
            validSubs(end+1) = sub;
            
        end
        
        validSubs = unique(validSubs);
        
        fprintf('\n[%s] valid subs: %d\n',...
            condName,numel(validSubs));
        
        %% --------------------------------------------------------
        % SAMPLING FREQUENCY
        % --------------------------------------------------------
        
        % All subjects are assumed to have the same sampling rate.
        % Get it explicitly rather than relying on tmp from the
        % previous loop.
        
        if isempty(validSubs)
            error('No valid subjects for condition %s.',condName);
        end
        
        fs = eegGroup{validSubs(1)}.fs;
        
        fprintf('[%s] sampling frequency = %.2f Hz\n',...
            condName,fs);
        
        %% --------------------------------------------------------
        % ELECTRODE HANDLING
        % --------------------------------------------------------
        
        if avgElectrodes
            
            commonLab = {'ROIavg'};
            nCh = 1;
            
            for si = 1:numel(validSubs)
                
                s = validSubs(si);
                
                nChan = size(eegGroup{s}.data{find(~cellfun(@isempty, eegGroup{s}.data), 1)}, 2);
                
                fprintf('Subject %d: averaging all %d channels\n', s, nChan);
                
                for tr = 1:numel(eegGroup{s}.data)
                    
                    if isempty(eegGroup{s}.data{tr})
                        continue
                    end
                    
                    % time x channels -> time x 1
                    eegGroup{s}.data{tr} = mean(eegGroup{s}.data{tr}, 2, 'omitnan');
                    
                end
                
                % Virtual channel
                eegGroup{s}.chanlocs = struct('labels', 'ROIavg');
                
            end
            
        end
        
        %% --------------------------------------------------------
        % NORMALISE EEG
        % --------------------------------------------------------
        
        for s = validSubs
            
            nonempty = ...
                ~cellfun(@isempty,eegGroup{s}.data);
            
            if ~any(nonempty)
                continue
            end
            
            allE = vertcat(...
                eegGroup{s}.data{nonempty});
            
            nf = std(allE(:));
            
            if nf == 0 || isnan(nf)
                nf = 1;
            end
            
            for tr = 1:length(eegGroup{s}.data)
                
                if ~isempty(eegGroup{s}.data{tr})
                    
                    eegGroup{s}.data{tr} = ...
                        eegGroup{s}.data{tr} ./ nf;
                    
                end
                
            end
            
        end
        
        %% --------------------------------------------------------
        % BAND-FILTERED EEG
        % --------------------------------------------------------
        
        eegBand = cell(1,nB);
        
        for b = 1:nB
            
            eegBand{b} = cell(1,nSubs);
            
            for s = validSubs
                
                eegBand{b}{s} = struct();
                
                if broadUsesNative && b == bBroad
                    
                    % Broadband data are already in the native
                    % 1-8 Hz band.
                    
                    eegBand{b}{s}.data = ...
                        eegGroup{s}.data;
                    
                else
                    
                    eegBand{b}{s}.data = ...
                        cellfun(...
                        @(x)local_bp(...
                        x,...
                        bandRange{b}(1),...
                        bandRange{b}(2),...
                        fs),...
                        eegGroup{s}.data,...
                        'UniformOutput',false);
                    
                end
                
            end
            
        end
        
        %% ========================================================
        % GROUND TRUTH
        %
        % IMPORTANT:
        %
        % stimGroup{s}       = cell array
        % stimGroup{s}{t}    = stimulus trial
        %
        % eegGroup{s}.data   = cell array
        % eegGroup{s}.data{t}= EEG trial
        %
        % Empty stimulus trials are NOT deleted.
        % They are simply skipped.
        % ========================================================
        
        stimGTcell = cell(1,numel(validSubs));
        
        gtBand = cell(1,nB);
        
        for b = 1:nB
            gtBand{b} = cell(1,numel(validSubs));
        end
        
        nContribS = cell(1,numel(validSubs));
        
        for si = 1:numel(validSubs)
            
            % si = position in validSubs
            % s  = actual subject index
            
            s = validSubs(si);
            
            codes = codeGroup{s};
            
            other = setdiff(validSubs,s);
            
            % Number of ORIGINAL trials
            nTr = numel(stimGroup{s});
            
            stimGTcell{si} = cell(1,nTr);
            
            nContribS{si} = nan(1,nTr);
            
            for b = 1:nB
                gtBand{b}{si} = cell(1,nTr);
            end
            
            for t = 1:nTr
                
                % ------------------------------------------------
                % SKIP EMPTY STIMULUS TRIALS
                % ------------------------------------------------
                
                if isempty(stimGroup{s}{t})
                    continue
                end
                
                % Also make sure EEG and monologue exist
                if t > numel(eegGroup{s}.data)
                    continue
                end
                
                if isempty(eegGroup{s}.data{t})
                    continue
                end
                
                if t > numel(codes) || isnan(codes(t))
                    continue
                end
                
                c = codes(t);
                
                idxOther = [];
                
                % ------------------------------------------------
                % Find same monologue in OTHER subjects
                % ------------------------------------------------
                
                for os = other
                    
                    if isempty(codeGroup{os})
                        continue
                    end
                    
                    jj = find(...
                        codeGroup{os} == c,...
                        1);
                    
                    if isempty(jj)
                        continue
                    end
                    
                    % Make sure the corresponding stimulus and EEG
                    % trial are actually present.
                    
                    if jj > numel(stimGroup{os})
                        continue
                    end
                    
                    if isempty(stimGroup{os}{jj})
                        continue
                    end
                    
                    if jj > numel(eegGroup{os}.data)
                        continue
                    end
                    
                    if isempty(eegGroup{os}.data{jj})
                        continue
                    end
                    
                    idxOther(end+1,:) = [os jj]; %#ok<AGROW>
                    
                end
                
                nContribS{si}(t) = size(idxOther,1);
                
                if size(idxOther,1) < minContrib
                    continue
                end
                
                % ------------------------------------------------
                % Determine common trial length
                % ------------------------------------------------
                
                Lc = inf;
                
                for r = 1:size(idxOther,1)
                    
                    os = idxOther(r,1);
                    jj = idxOther(r,2);
                    
                    Lc = min(...
                        Lc,...
                        size(eegGroup{os}.data{jj},1));
                    
                end
                
                L = min(...
                    size(stimGroup{s}{t},1),...
                    Lc);
                
                if L <= 0
                    continue
                end
                
                % ------------------------------------------------
                % Store stimulus
                % ------------------------------------------------
                
                stimGTcell{si}{t} = ...
                    stimGroup{s}{t}(1:L,:);
                
                % ------------------------------------------------
                % Build GT for each band
                % ------------------------------------------------
                
                for b = 1:nB
                    
                    gt = zeros(L,nCh);
                    
                    for r = 1:size(idxOther,1)
                        
                        os = idxOther(r,1);
                        jj = idxOther(r,2);
                        
                        gt = gt + ...
                            eegBand{b}{os}.data{jj}(1:L,:);
                        
                    end
                    
                    gtBand{b}{si}{t} = ...
                        gt ./ size(idxOther,1);
                    
                end
                
            end
            
        end
        
        %% ========================================================
        % PER-SUBJECT PIPELINE
        % ========================================================
        
        nS = numel(validSubs);
        
        rGT = nan(nS,nB);
        rOwn = nan(nS,nB);
        rCeil = nan(nS,nB);
        
        pPerm = nan(nS,nB);
        zGT = nan(nS,nB);
        
        rNullMean = nan(nS,nB);
        rN95G = nan(nS,nB);
        
        pPermOwn = nan(nS,nB);
        zOwn = nan(nS,nB);
        
        rNullOwnMean = nan(nS,nB);
        rN95O = nan(nS,nB);
        
        allNullG = nan(nPerm,nB,nS);
        allNullO = nan(nPerm,nB,nS);
        
        lamSub = nan(1,nS);
        
        nValidGT = zeros(1,nS);
        
        nLag = round((tmax-tmin)/1000*fs)+1;
        
        WsubOwn = nan(nS,nLag,nCh);
        
        tAxis = [];
        
        for si = 1:nS
            
            s = validSubs(si);
            
            %% ----------------------------------------------------
            % IMPORTANT:
            % Keep ONLY trials that have:
            % 1. stimulus
            % 2. EEG
            % 3. monologue code
            % 4. GT
            %
            % We preserve the original trial indices in trialIdx.
            %% ----------------------------------------------------
            
            nTrOriginal = numel(stimGroup{s});
            
            trialIdx = [];
            
            for t = 1:nTrOriginal
                
                if isempty(stimGroup{s}{t})
                    continue
                end
                
                if t > numel(eegGroup{s}.data)
                    continue
                end
                
                if isempty(eegGroup{s}.data{t})
                    continue
                end
                
                if t > numel(codeGroup{s}) || ...
                        isnan(codeGroup{s}(t))
                    continue
                end
                
                if isempty(gtBand{bBroad}{si}{t})
                    continue
                end
                
                trialIdx(end+1) = t; %#ok<AGROW>
                
            end
            
            nTr = numel(trialIdx);
            
            if nTr < minTrials
                
                fprintf(...
                    'sub %2d: only %d usable TRF trials -- skipped\n',...
                    s,nTr);
                
                continue
                
            end
            
            % ----------------------------------------------------
            % Create compact trial arrays for mTRF
            % ----------------------------------------------------
            
            S = cell(1,nTr);
            Rb = cell(1,nTr);
            
            for k = 1:nTr
                
                t = trialIdx(k);
                
                S{k} = stimGroup{s}{t};
                
                Rb{k} = eegBand{bBroad}{s}.data{t};
                
            end
            
            % ----------------------------------------------------
            % GT corresponding to compact trial list
            % ----------------------------------------------------
            
            gtb0 = cell(1,nTr);
            
            for k = 1:nTr
                
                t = trialIdx(k);
                
                gtb0{k} = gtBand{bBroad}{si}{t};
                
            end
            
            %% ----------------------------------------------------
            % LAMBDA
            % ----------------------------------------------------
            
            if strcmp(lambdaTune,'own')
                
                cv = mTRFcrossval(...
                    S,...
                    Rb,...
                    fs,...
                    dirTRF,...
                    tmin,...
                    tmax,...
                    lambdas,...
                    'method',regMethod,...
                    'verbose',0);
                
                lamSub(si) = pickLambda(...
                    squeeze(mean(mean(cv.r,1),3)));
                
            else
                
                lamSub(si) = tune_lambda_gt(...
                    S,...
                    Rb,...
                    gtb0,...
                    1:nTr,...
                    fs,...
                    dirTRF,...
                    tmin,...
                    tmax,...
                    lambdas,...
                    regMethod,...
                    pickLambda);
                
            end
            
            %% ----------------------------------------------------
            % LOO PREDICTION
            % ----------------------------------------------------
            
            predBandStore = cell(nB,nTr);
            
            rt_gt = nan(nTr,nB);
            rt_own = nan(nTr,nB);
            rt_cl = nan(nTr,nB);
            
            for k = 1:nTr
                
                % Original trial number
                t = trialIdx(k);
                
                if isempty(gtBand{bBroad}{si}{t})
                    continue
                end
                
                trn = setdiff(1:nTr,k);
                
                if numel(trn) < 2
                    continue
                end
                
                L = size(gtBand{bBroad}{si}{t},1);
                
                %% Lambda for this fold
                
                if strcmp(lambdaTune,'gt')
                    
                    lamUse = tune_lambda_gt(...
                        S,...
                        Rb,...
                        gtb0,...
                        trn,...
                        fs,...
                        dirTRF,...
                        tmin,...
                        tmax,...
                        lambdas,...
                        regMethod,...
                        pickLambda);
                    
                else
                    
                    lamUse = lamSub(si);
                    
                end
                
                %% Train
                
                m = mTRFtrain(...
                    S(trn),...
                    Rb(trn),...
                    fs,...
                    dirTRF,...
                    tmin,...
                    tmax,...
                    lamUse,...
                    'method',regMethod,...
                    'verbose',0);
                
                %% Predict
                
                [pg,~] = mTRFpredict(...
                    {S{k}(1:L,:)},...
                    {Rb{k}(1:L,:)},...
                    m,...
                    'verbose',0);
                
                if iscell(pg)
                    pg = pg{1};
                end
                
                %% ------------------------------------------------
                % Score each band
                %% ------------------------------------------------
                
                for b = 1:nB
                    
                    if filterPred && ...
                            ~(broadUsesNative && b==bBroad)
                        
                        pgB = local_bp(...
                            pg,...
                            bandRange{b}(1),...
                            bandRange{b}(2),...
                            fs);
                        
                    else
                        
                        pgB = pg;
                        
                    end
                    
                    predBandStore{b,k} = pgB;
                    
                    gtb = gtBand{b}{si}{t};
                    
                    Lg = min(size(pgB,1),size(gtb,1));
                    
                    gtb = gtb(1:Lg,:);
                    
                    ownb = ...
                        eegBand{b}{s}.data{t}(1:Lg,:);
                    
                    rg = nan(1,nCh);
                    rr = nan(1,nCh);
                    rc = nan(1,nCh);
                    
                    for ch = 1:nCh
                        
                        if ...
                                std(pgB(1:Lg,ch)) > eps && ...
                                std(gtb(:,ch)) > eps
                            
                            rg(ch) = corr(...
                                pgB(1:Lg,ch),...
                                gtb(:,ch));
                            
                        end
                        
                        if ...
                                std(pgB(1:Lg,ch)) > eps && ...
                                std(ownb(:,ch)) > eps
                            
                            rr(ch) = corr(...
                                pgB(1:Lg,ch),...
                                ownb(:,ch));
                            
                        end
                        
                        if ...
                                std(ownb(:,ch)) > eps && ...
                                std(gtb(:,ch)) > eps
                            
                            rc(ch) = corr(...
                                ownb(:,ch),...
                                gtb(:,ch));
                            
                        end
                        
                    end
                    
                    rt_gt(k,b) = mean(rg,'omitnan');
                    rt_own(k,b) = mean(rr,'omitnan');
                    rt_cl(k,b) = mean(rc,'omitnan');
                    
                end
                
            end
            
            %% ----------------------------------------------------
            % Subject-level averages
            % ----------------------------------------------------
            
            nValidGT(si) = ...
                sum(~isnan(rt_gt(:,bBroad)));
            
            rGT(si,:) = ...
                mean(rt_gt,1,'omitnan');
            
            rOwn(si,:) = ...
                mean(rt_own,1,'omitnan');
            
            rCeil(si,:) = ...
                mean(rt_cl,1,'omitnan');
            
            %% ====================================================
            % NULL
            % ====================================================
            
            validK = find(...
                ~cellfun(@isempty,predBandStore(bBroad,:)) & ...
                ~cellfun(@isempty,gtb0));
            
            codesV = codeGroup{s};
            
            if ~isempty(validK)
                
                rNullG = nan(nPerm,nB);
                rNullO = nan(nPerm,nB);
                
                minShift = round(0.5*fs);
                
                if strcmp(nullType,'randseg')
                    
                    catG = cell(1,nB);
                    catO = cell(1,nB);
                    
                    for b = 1:nB
                        
                        tmpG = {};
                        tmpO = {};
                        
                        for kk = validK
                            
                            t = trialIdx(kk);
                            
                            tmpG{end+1} = ...
                                gtBand{b}{si}{t}; %#ok<AGROW>
                            
                            tmpO{end+1} = ...
                                eegBand{b}{s}.data{t}; %#ok<AGROW>
                            
                        end
                        
                        catG{b} = vertcat(tmpG{:});
                        catO{b} = vertcat(tmpO{:});
                        
                    end
                    
                end
                
                %% ------------------------------------------------
                % Permutations
                %% ------------------------------------------------
                
                for p = 1:nPerm
                    
                    rg = nan(numel(validK),nB);
                    ro = nan(numel(validK),nB);
                    
                    for ti = 1:numel(validK)
                        
                        k = validK(ti);
                        
                        t = trialIdx(k);
                        
                        L = size(...
                            gtBand{bBroad}{si}{t},1);
                        
                        %% Select null target
                        
                        if strcmp(nullType,'mismatch')
                            
                            candidateK = [];
                            
                            for kk = validK
                                
                                if kk == k
                                    continue
                                end
                                
                                tt = trialIdx(kk);
                                
                                if codesV(tt) ~= codesV(t)
                                    
                                    candidateK(end+1) = kk; %#ok<AGROW>
                                    
                                end
                                
                            end
                            
                            if isempty(candidateK)
                                continue
                            end
                            
                            wK = candidateK(...
                                randi(numel(candidateK)));
                            
                            w = trialIdx(wK);
                            
                        elseif strcmp(nullType,'circshift')
                            
                            maxSh = L-minShift;
                            
                            if maxSh <= minShift
                                
                                sh = randi(max(1,L-1));
                                
                            else
                                
                                sh = randi([minShift,maxSh]);
                                
                            end
                            
                        end
                        
                        %% ------------------------------------------------
                        % Score null
                        %% ------------------------------------------------
                        
                        for b = 1:nB
                            
                            pgB = predBandStore{b,k};
                            
                            switch nullType
                                
                                case 'mismatch'
                                    
                                    src = pgB;
                                    
                                    tgtG = gtBand{b}{si}{w};
                                    
                                    tgtO = ...
                                        eegBand{b}{s}.data{w};
                                    
                                case 'circshift'
                                    
                                    src = circshift(...
                                        pgB(1:L,:),...
                                        sh,...
                                        1);
                                    
                                    tgtG = ...
                                        gtBand{b}{si}{t}(1:L,:);
                                    
                                    tgtO = ...
                                        eegBand{b}{s}.data{t}(1:L,:);
                                    
                                case 'randseg'
                                    
                                    src = pgB(1:L,:);
                                    
                                    ng = ...
                                        max(1,size(catG{b},1)-L+1);
                                    
                                    no = ...
                                        max(1,size(catO{b},1)-L+1);
                                    
                                    sg = randi(ng);
                                    so = randi(no);
                                    
                                    tgtG = ...
                                        catG{b}(sg:sg+L-1,:);
                                    
                                    tgtO = ...
                                        catO{b}(so:so+L-1,:);
                                    
                            end
                            
                            Lg = min(...
                                size(src,1),...
                                size(tgtG,1));
                            
                            Lo = min(...
                                size(src,1),...
                                size(tgtO,1));
                            
                            vg = nan(1,nCh);
                            vo = nan(1,nCh);
                            
                            for ch = 1:nCh
                                
                                a1 = src(1:Lg,ch);
                                b1 = tgtG(1:Lg,ch);
                                
                                if ...
                                        std(a1)>eps && ...
                                        std(b1)>eps
                                    
                                    vg(ch) = corr(a1,b1);
                                    
                                end
                                
                                a2 = src(1:Lo,ch);
                                b2 = tgtO(1:Lo,ch);
                                
                                if ...
                                        std(a2)>eps && ...
                                        std(b2)>eps
                                    
                                    vo(ch) = corr(a2,b2);
                                    
                                end
                                
                            end
                            
                            rg(ti,b) = ...
                                mean(vg,'omitnan');
                            
                            ro(ti,b) = ...
                                mean(vo,'omitnan');
                            
                        end
                        
                    end
                    
                    rNullG(p,:) = ...
                        mean(rg,1,'omitnan');
                    
                    rNullO(p,:) = ...
                        mean(ro,1,'omitnan');
                    
                end
                
                %% ------------------------------------------------
                % Permutation statistics
                %% ------------------------------------------------
                
                for b = 1:nB
                    
                    pPerm(si,b) = ...
                        (sum(rNullG(:,b)>=rGT(si,b))+1) / ...
                        (nPerm+1);
                    
                    rNullMean(si,b) = ...
                        mean(rNullG(:,b),'omitnan');
                    
                    rN95G(si,b) = ...
                        prctile(rNullG(:,b),95);
                    
                    zGT(si,b) = ...
                        (rGT(si,b)-rNullMean(si,b)) / ...
                        std(rNullG(:,b),'omitnan');
                    
                    pPermOwn(si,b) = ...
                        (sum(rNullO(:,b)>=rOwn(si,b))+1) / ...
                        (nPerm+1);
                    
                    rNullOwnMean(si,b) = ...
                        mean(rNullO(:,b),'omitnan');
                    
                    rN95O(si,b) = ...
                        prctile(rNullO(:,b),95);
                    
                    zOwn(si,b) = ...
                        (rOwn(si,b)-rNullOwnMean(si,b)) / ...
                        std(rNullO(:,b),'omitnan');
                    
                end
                
                allNullG(:,:,si) = rNullG;
                allNullO(:,:,si) = rNullO;
                
            end
            
            %% ====================================================
            % OWN-BASED BROADBAND TRF WEIGHTS
            % ====================================================
            
            mF = mTRFtrain(...
                S,...
                Rb,...
                fs,...
                dirTRF,...
                tmin,...
                tmax,...
                lamSub(si),...
                'method',regMethod,...
                'verbose',0);
            
            wO = squeeze(mF.w);
            
            if ndims(mF.w) == 3
                wO = squeeze(mF.w(1,:,:));
            end
            
            WsubOwn(si,:,:) = wO;
            
            tAxis = mF.t;
            
            fprintf(...
                ['sub %2d: lambda=%-6g GTtr=%d | ' ...
                'broad GT=%.3f(p=%.3f) ' ...
                'delta GT=%.3f(p=%.3f) ' ...
                'theta GT=%.3f(p=%.3f)\n'],...
                s,...
                lamSub(si),...
                nValidGT(si),...
                rGT(si,1),pPerm(si,1),...
                rGT(si,2),pPerm(si,2),...
                rGT(si,3),pPerm(si,3));
            
        end
        
        %% ========================================================
        % GROUP-LEVEL TESTS
        % ========================================================
        
        for b = 1:nB
            
            vv = ~isnan(rGT(:,b));
            
            [~,pG] = ttest(rGT(vv,b));
            
            [~,pO] = ttest(rOwn(vv,b));
            
            fprintf(...
                ['[%s | %-5s] GT r=%.4f (t p=%.3g, ' ...
                'perm<.05=%.2f) | Own r=%.4f (t p=%.3g, ' ...
                'perm<.05=%.2f) | Ceil r=%.4f | median lambda=%g\n'],...
                condName,...
                bandNames{b},...
                mean(rGT(vv,b)),...
                pG,...
                mean(pPerm(vv,b)<0.05,'omitnan'),...
                mean(rOwn(vv,b)),...
                pO,...
                mean(pPermOwn(vv,b)<0.05,'omitnan'),...
                mean(rCeil(vv,b),'omitnan'),...
                median(lamSub,'omitnan'));
            
        end
        
        %% ========================================================
        % GROUP PLOT
        % ========================================================
        
        subplot(2,2,iicond);
        hold on
        
        M = [...
            mean(rGT,1,'omitnan');...
            mean(rOwn,1,'omitnan')]';
        
        hbar = bar(M,'EdgeColor','none');
        
        cols = [...
            0.4 0.6 0.9;...
            0.5 0.8 0.5];
        
        for k = 1:2
            hbar(k).FaceColor = cols(k,:);
        end
        
        %% Group permutation thresholds
        
        grpNullG = ...
            squeeze(mean(allNullG,3,'omitnan'));
        
        grpNullO = ...
            squeeze(mean(allNullO,3,'omitnan'));
        
        grpThrG = ...
            prctile(grpNullG,95,1);
        
        grpThrO = ...
            prctile(grpNullO,95,1);
        
        meas = {rGT,rOwn};
        
        thr95 = {grpThrG,grpThrO};
        
        hThr = [];
        
        nBars = numel(hbar);
        
        x0 = hbar(1).XData(:)';
        
        gw = min(0.8,nBars/(nBars+1.5));
        
        for k = 1:nBars
            
            xe = ...
                x0 - gw/2 + ...
                (2*k-1)*gw/(2*nBars);
            
            v = meas{k};
            
            se = ...
                std(v,0,1,'omitnan') ./ ...
                sqrt(sum(~isnan(v),1));
            
            errorbar(...
                xe,...
                mean(v,1,'omitnan'),...
                se,...
                'k',...
                'LineStyle','none',...
                'LineWidth',1);
            
            th = thr95{k};
            
            for bb = 1:nB
                
                h = plot(...
                    xe(bb)+[-0.13 0.13],...
                    [th(bb) th(bb)],...
                    '-',...
                    'Color',[0.15 0.15 0.15],...
                    'LineWidth',1.8);
                
            end
            
            hThr = h;
            
        end
        
        yline(0,'k-');
        
        xticks(1:nB);
        xticklabels(bandNames);
        
        ylabel('Prediction r');
        
        lh = [hbar(1) hbar(2)];
        
        lt = {'GT','Own'};
        
        if ~isempty(hThr)
            
            lh(end+1) = hThr;
            lt{end+1} = 'group null p95';
            
        end
        
        legend(lh,lt,...
            'Location','northwest',...
            'FontSize',8);
        
        legend boxoff
        
        title(sprintf('%s (n=%d)',condName,nS));
        
        grid on
        
        ylim([-0.01 0.08]);
        
        box off
        
        %% ========================================================
        % STORE
        % ========================================================
        
        RESp(iicond).cond = condName;
        
        RESp(iicond).validSubs = validSubs;
        
        RESp(iicond).bandNames = bandNames;
        
        RESp(iicond).rGT = rGT;
        
        RESp(iicond).rOwn = rOwn;
        
        RESp(iicond).rCeil = rCeil;
        
        RESp(iicond).pPerm = pPerm;
        
        RESp(iicond).zGT = zGT;
        
        RESp(iicond).rNullMean = rNullMean;
        
        RESp(iicond).rN95G = rN95G;
        
        RESp(iicond).pPermOwn = pPermOwn;
        
        RESp(iicond).zOwn = zOwn;
        
        RESp(iicond).rNullOwnMean = rNullOwnMean;
        
        RESp(iicond).rN95O = rN95O;
        
        RESp(iicond).nullType = nullType;
        
        RESp(iicond).grpThrG = grpThrG;
        
        RESp(iicond).grpThrO = grpThrO;
        
        RESp(iicond).lambda = lamSub;
        
        RESp(iicond).nValidGT = nValidGT;
        
        RESp(iicond).regMethod = regMethod;
        
        RESp(iicond).WsubOwn = WsubOwn;
        
        RESp(iicond).tAxis = tAxis;
        
        RESp(iicond).commonLab = commonLab;
        RESp(iicond).allNullG = allNullG;
        RESp(iicond).allNullO = allNullO;
        
    end % iicond
    
    %% ============================================================
    % PLOT OWN-BASED TRF WEIGHTS
    % ============================================================
    
    subplot(2,2,[3 4]);
    hold on
    
    condCols = [...
        0.20 0.45 0.80;...
        0.85 0.33 0.10];
    
    hh = gobjects(1,2);
    nm = cell(1,2);
    
    for ic = 1:2
        
        W = RESp(ic).WsubOwn;
        
        tA = RESp(ic).tAxis;
        
        cl = RESp(ic).commonLab{1};
        
        cz = find(strcmpi(cl,Chan2Plot),1);
        
        if isempty(cz)
            cz = 1;
        end
        
        w = squeeze(W(:,:,cz));
        
        wn = ...
            w ./ sqrt(mean(w.^2,2,'omitnan'));
        
        mu = mean(wn,1,'omitnan');
        
        se = ...
            std(wn,0,1,'omitnan') ./ ...
            sqrt(sum(~isnan(wn(:,1))));
        
        inX = ...
            tA >= plotXlim(1) & ...
            tA <= plotXlim(2);
        
        c = condCols(ic,:);
        
        fill(...
            [tA(inX) fliplr(tA(inX))],...
            [mu(inX)+se(inX) ...
            fliplr(mu(inX)-se(inX))],...
            c,...
            'FaceAlpha',0.15,...
            'EdgeColor','none');
        
        hh(ic) = plot(...
            tA(inX),...
            mu(inX),...
            'Color',c,...
            'LineWidth',1.8);
        
        nm{ic} = RESp(ic).cond;
        
    end
    
    yline(0,'-','Color',[.7 .7 .7]);
    
    xline(0,'--k');
    
    xlim(plotXlim);
    
    xlabel('Latency (ms)');
    
    ylabel('norm. a.u.');
    
    legend(hh,nm,...
        'Location','best',...
        'FontSize',8);
    
    legend boxoff
    
    if avgElectrodes
        chLbl = ['ROI(' strjoin(roiElec,',') ')'];
    else
        chLbl = Chan2Plot;
    end
    
    title(sprintf(...
        'Own-based TRF @ %s (%s, broadband)',...
        chLbl,regMethod));
    
    box off
    
    hold off
    
    %% ============================================================
    % SAVE
    % ============================================================
    
    saveName = sprintf(...
        '%s/TRF_NeuroLip_v3bands_%s_stim%d.mat',...
        savePath,...
        regMethod,...
        iiStim);
    
    save(saveName,'RESp');
    
    fprintf('Saved: %s\n',saveName);
    
end % iiStim


%% ================================================================
% COMBINED TRF + BROADBAND R FIGURE
% ================================================================

Color_clear = [222,161,147]./255;

Color_vocoded = [206,12,12]./255;

figure(...
    'Position',[100,100,900,1000],...
    'Color','white',...
    'Name','TRF + broadband r');

%% TOP: TRF

subplot(2,1,1);
hold on

condCols = [...
    Color_clear;...
    Color_vocoded];

hh = gobjects(1,2);
nm = cell(1,2);

for ic = 1:2
    
    W = RESp(ic).WsubOwn;
    
    tA = RESp(ic).tAxis;
    
    w = squeeze(W(:,:,1));
    
    wn = ...
        w ./ sqrt(mean(w.^2,2,'omitnan'));
    
    wn = smoothdata(wn,2,'movmean',5);
    
    mu = mean(wn,1,'omitnan');
    
    se = ...
        std(wn,0,1,'omitnan') ./ ...
        sqrt(sum(~isnan(wn(:,1))));
    
    inX = ...
        tA >= plotXlim(1) & ...
        tA <= plotXlim(2);
    
    c = condCols(ic,:);
    
    fill(...
        [tA(inX) fliplr(tA(inX))],...
        [mu(inX)+se(inX) ...
        fliplr(mu(inX)-se(inX))],...
        c,...
        'FaceAlpha',0.15,...
        'EdgeColor','none');
    
    hh(ic) = plot(...
        tA(inX),...
        mu(inX),...
        'Color',c,...
        'LineWidth',1.8);
    
    nm{ic} = RESp(ic).cond;
    
end

yline(0,'-','Color',[.7 .7 .7]);

xline(0,'--k');

xlim(plotXlim);

xlabel('Latency (ms)');

ylabel('norm. a.u.');

legend(hh,nm,...
    'Location','best',...
    'FontSize',8);

legend boxoff

if avgElectrodes
    chLbl = ['ROI(' strjoin(roiElec,',') ')'];
else
    chLbl = Chan2Plot;
end

title(sprintf(...
    'Own-based TRF @ %s',...
    chLbl));

box off

hold off

%% BOTTOM: BROADBAND R

subplot(2,1,2);
hold on

b = 1;

vals = [...
    mean(RESp(1).rGT(:,b),'omitnan'),...
    mean(RESp(1).rOwn(:,b),'omitnan'),...
    mean(RESp(2).rGT(:,b),'omitnan'),...
    mean(RESp(2).rOwn(:,b),'omitnan')];

SEs = [...
    std(RESp(1).rGT(:,b),'omitnan') / ...
    sqrt(sum(~isnan(RESp(1).rGT(:,b)))),...
    
    std(RESp(1).rOwn(:,b),'omitnan') / ...
    sqrt(sum(~isnan(RESp(1).rOwn(:,b)))),...
    
    std(RESp(2).rGT(:,b),'omitnan') / ...
    sqrt(sum(~isnan(RESp(2).rGT(:,b)))),...
    
    std(RESp(2).rOwn(:,b),'omitnan') / ...
    sqrt(sum(~isnan(RESp(2).rOwn(:,b))))];

x = [1 2 3.5 4.5];

cols = [...
    Color_clear;...
    Color_clear;...
    Color_vocoded;...
    Color_vocoded];

for i = 1:4
    
    bar(...
        x(i),...
        vals(i),...
        0.7,...
        'FaceColor',cols(i,:),...
        'FaceAlpha',0.5,...
        'EdgeColor','none');
    
end

errorbar(...
    x,...
    vals,...
    SEs,...
    'k',...
    'LineStyle','none',...
    'LineWidth',1);

yline(0,'k-');

xlim([0.3 5.2]);

xticks(x);

xticklabels({'GT','Own','GT','Own'});

ylabel('Prediction r (broadband)');

title('Broadband prediction r: Clear vs Vocoded');

grid on

box off

h1 = bar(nan,nan,...
    'FaceColor',cols(1,:));

h2 = bar(nan,nan,...
    'FaceColor',cols(3,:));

legend([h1 h2],...
    {'Clear','Vocoded'},...
    'Location','northwest');

legend boxoff

set(findall(gcf,'-property','FontSize'),'FontSize',30);


%% ================================================================
% INDIVIDUAL TRF RESPONSES
% ================================================================

for ic = 1:2
    
    figure(...
        'Position',[100 100 1100 700],...
        'Color','white');
    
    hold on
    
    W = RESp(ic).WsubOwn;
    
    tA = RESp(ic).tAxis;
    
    w = squeeze(W(:,:,1));
    
    wn = ...
        w ./ sqrt(mean(w.^2,2,'omitnan'));
    
    for si = 1:size(wn,1)
        
        plot(...
            tA,...
            wn(si,:),...
            'LineWidth',0.8,...
            'Color',[0.5 0.5 0.5]);
        
    end
    
    xline(0,'--k');
    
    yline(0,'Color',[0.7 0.7 0.7]);
    
    xlim([-50 350]);
    
    xlabel('Latency (ms)');
    
    ylabel('Normalised TRF weight');
    
    title(sprintf(...
        '%s — individual TRFs around 0 ms',...
        RESp(ic).cond));
    
    box off
    
end


%% ================================================================
% ARRAY WITH ID AND R VALUES
% ================================================================

ids_clear = RESp(1).validSubs;

ids_vocoded = RESp(2).validSubs;

commonSubs = intersect(...
    ids_clear,...
    ids_vocoded);

[~,idx_clear] = ismember(...
    commonSubs,...
    ids_clear);

[~,idx_vocoded] = ismember(...
    commonSubs,...
    ids_vocoded);

r_table = table();

r_table.ID = ...
    selection(commonSubs(:))';

r_table.r_Clear = ...
    RESp(1).rGT(idx_clear,1);

r_table.r_Vocoded = ...
    RESp(2).rGT(idx_vocoded,1);

writetable(...
    r_table,...
    fullfile(...
    '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/EEG',...
    'r_values.csv'));

%% BROADBAND-ONLY GROUP STATISTICS FOR TRF PREDICTION ACCURACY
% Run AFTER the main TRF script. Needs:
%   - RESp in the workspace (or the saved .mat file), including the fields
%     allNullG and allNullO (see the two "store" lines in the main script)
%   - bh_fdr.m on the path
%
% Output (in savePath):
%   TRF_broadband_within_condition.csv   r above chance, per measure x condition
%   TRF_broadband_clear_vs_vocoded.csv   paired clear vs vocoded, per measure

if ~exist('savePath','var')
    savePath = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results';
end
if ~exist('RESp','var')
    load(fullfile(savePath, 'TRF_NeuroLip_v3bands_Ridge_stim1.mat'), 'RESp');
end
assert(isfield(RESp,'allNullG') && ~isempty(RESp(1).allNullG), ...
    'RESp.allNullG is missing: add the store lines to the main script and rerun it.');

% ---- settings ----
b = find(strcmp(RESp(1).bandNames, 'broad'));   % broadband index
condNames = {RESp(1).cond, RESp(2).cond};

measF     = {'rGT',      'rOwn'};       % observed r (nSubs x nBands)
nullF     = {'allNullG', 'allNullO'};   % nPerm x nBands x nSubs
pSubjF    = {'pPerm',    'pPermOwn'};   % subject-level permutation p
measNames = {'GT', 'Own'};

%% ------------------------------------------------------------
% 1. WITHIN CONDITION: is broadband r above chance at group level?
% ------------------------------------------------------------
rows = {};

for m = 1:2
    for ic = 1:2

        R  = RESp(ic).(measF{m})(:, b);          % nSubs x 1
        N  = RESp(ic).(nullF{m});                % nPerm x nBands x nSubs
        Ps = RESp(ic).(pSubjF{m})(:, b);
        nPerm = size(N, 1);

        % subjects with a valid r AND a valid null
        hasNull = squeeze(~isnan(N(1, b, :)));
        v = ~isnan(R) & hasNull(:);
        n = sum(v);

        % Fisher z so that averaging is valid
        z       = atanh(R(v));
        nullSub = atanh(reshape(N(:, b, v), nPerm, []));   % nPerm x n

        % (a) group permutation test (one-sided):
        %     observed group mean vs null distribution of group means
        obs      = mean(z);
        nullGrp  = mean(nullSub, 2);
        p_perm   = (sum(nullGrp >= obs) + 1) / (nPerm + 1);

        % (b) paired test of r vs each subject's own null mean (one-sided)
        d = z - mean(nullSub, 1)';
        [~, p_ttest] = ttest(d, 0, 'Tail', 'right');
        p_wilcoxon   = signrank(d, 0, 'tail', 'right');

        % (c) subjects individually significant (p < .05) vs 5% expected
        nSig   = sum(Ps(v) < 0.05);
        p_binom = 1 - binocdf(nSig - 1, n, 0.05);

        rows(end+1, :) = {measNames{m}, condNames{ic}, n, tanh(obs), ...
            p_perm, p_ttest, p_wilcoxon, nSig, p_binom}; %#ok<SAGROW>
    end
end

Twithin = cell2table(rows, 'VariableNames', ...
    {'Measure','Condition','N','MeanR','p_perm','p_ttest','p_wilcoxon', ...
     'nSigSubj','p_binom'});

% FDR within each measure, across the 2 conditions (broadband only)
Twithin.q_perm  = nan(height(Twithin), 1);
Twithin.q_ttest = nan(height(Twithin), 1);
for m = 1:2
    idx = strcmp(Twithin.Measure, measNames{m});
    Twithin.q_perm(idx)  = bh_fdr(Twithin.p_perm(idx));
    Twithin.q_ttest(idx) = bh_fdr(Twithin.p_ttest(idx));
end

disp('=== Broadband, within condition ===')
disp(Twithin)
writetable(Twithin, fullfile(savePath, 'TRF_broadband_within_condition.csv'));

%% ------------------------------------------------------------
% 2. BETWEEN CONDITIONS: vocoded vs clear (paired, same subjects)
% ------------------------------------------------------------
common = intersect(RESp(1).validSubs, RESp(2).validSubs);
[~, i1] = ismember(common, RESp(1).validSubs);
[~, i2] = ismember(common, RESp(2).validSubs);

rows = {};
for m = 1:2
    rc = RESp(1).(measF{m})(i1, b);     % clear
    rv = RESp(2).(measF{m})(i2, b);     % vocoded
    ok = ~isnan(rc) & ~isnan(rv);
    n  = sum(ok);

    zc = atanh(rc(ok));
    zv = atanh(rv(ok));
    d  = zv - zc;

    [~, p_ttest, ci, st] = ttest(d);        % two-sided
    p_wilcoxon = signrank(zv, zc);
    dz = mean(d) / std(d);

    rows(end+1, :) = {measNames{m}, n, mean(rc(ok)), mean(rv(ok)), mean(d), ...
        ci(1), ci(2), st.tstat, p_ttest, p_wilcoxon, dz}; %#ok<SAGROW>
end

Tbetween = cell2table(rows, 'VariableNames', ...
    {'Measure','N','MeanR_clear','MeanR_vocoded','Diff_z','CI_low','CI_high', ...
     't','p_ttest','p_wilcoxon','dz'});

disp('=== Broadband, clear vs vocoded ===')
disp(Tbetween)
writetable(Tbetween, fullfile(savePath, 'TRF_broadband_clear_vs_vocoded.csv'));

% Lme model
b = find(strcmp(RESp(1).bandNames,'broad'));
common = intersect(RESp(1).validSubs, RESp(2).validSubs);
[~,i1] = ismember(common, RESp(1).validSubs);
[~,i2] = ismember(common, RESp(2).validSubs);

tbl = table();
tbl.subj = categorical([common(:); common(:)]);
tbl.cond = categorical([repmat({'clear'},numel(common),1); repmat({'vocoded'},numel(common),1)]);
tbl.r    = [RESp(1).rGT(i1,b); RESp(2).rGT(i2,b)];
% tbl.PTLT = [...];   % mean mouth PTLT per subject and condition, same order

lme0 = fitlme(tbl, 'r ~ cond + (1|subj)');
% lme1 = fitlme(tbl, 'r ~ cond*PTLT + (1|subj)');   % after centring PTLT
disp(lme0)

%% ================================================================
% FUNCTIONS
% ================================================================



function lam = tune_lambda_gt(...
    S,Rb,gtb0,trn,fs,dirTRF,tmin,tmax,...
    lambdas,regMethod,pickLambda)

% Nested lambda tuning by the GT criterion.
%
% Inner leave-one-out over the TRAINING trials.
%
% Only training trials are used for lambda selection.

trnGT = trn(...
    ~cellfun(@isempty,gtb0(trn)));

if numel(trnGT) < 3
    
    lam = ...
        lambdas(max(1,ceil(numel(lambdas)/2)));
    
    return
    
end

rL = nan(1,numel(lambdas));

for li = 1:numel(lambdas)
    
    rr = nan(1,numel(trnGT));
    
    c = 0;
    
    for j = trnGT
        
        inTr = setdiff(trn,j);
        
        mm = mTRFtrain(...
            S(inTr),...
            Rb(inTr),...
            fs,...
            dirTRF,...
            tmin,...
            tmax,...
            lambdas(li),...
            'method',regMethod,...
            'verbose',0);
        
        Lj = size(gtb0{j},1);
        
        [pj,~] = mTRFpredict(...
            {S{j}(1:Lj,:)},...
            {gtb0{j}},...
            mm,...
            'verbose',0);
        
        if iscell(pj)
            pj = pj{1};
        end
        
        Lp = size(pj,1);
        
        g = gtb0{j}(1:Lp,:);
        
        c = c+1;
        
        C = corr(pj,g);
        
        rr(c) = mean(diag(C),'omitnan');
        
    end
    
    rL(li) = mean(rr,'omitnan');
    
end

lam = pickLambda(rL);

end


function y = local_bp(x,lo,hi,fs)

% Zero-phase Butterworth filtering.
%
% x  = samples x channels
% lo = lower cutoff in Hz
% hi = upper cutoff in Hz
% fs = sampling frequency

ny = fs/2;

if lo <= 0
    
    [b,a] = butter(3,hi/ny);
    
elseif hi >= ny
    
    [b,a] = butter(3,lo/ny,'high');
    
else
    
    [b,a] = butter(...
        3,...
        [lo hi]/ny,...
        'bandpass');
    
end

y = filtfilt(b,a,x);

end