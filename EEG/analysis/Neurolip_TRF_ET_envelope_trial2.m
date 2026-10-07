%% ================================================================
%  NeuroLip: Envelope / Eye-tracking / Envelope+Eye-tracking -> EEG
%  Forward TRF, WITHIN-SUBJECT (subject-specific TRFs)
%
%  Tobii X120 ET: 120 Hz   |   EEG + envelope: 200 Hz
%  MATLAB R2018b compatible
%
%  Design
%  - ET segments = contiguous runs of valid (non-NaN) gaze samples.
%    No interpolation, NO concatenation of segments before modelling.
%    Each segment is one cell for the mTRF toolbox.
%  - Per subject and condition, 3 models:
%        Env   : envelope -> EEG
%        ET    : gaze     -> EEG
%        Both  : [envelope gaze] -> EEG
%  - Lambda: cross-validation across segments (mTRFcrossval).
%  - Performance: leave-one-segment-out prediction; r computed on the
%    held-out predictions (concatenated AFTER prediction).
%  - Final TRF: trained on all segments with the selected lambda.
%  - ET contribution = rBoth - rEnv.
% ================================================================

clear
close all
clc

% ================================================================
%  PATHS
% ================================================================

root = ['/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/' ...
    'Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/' ...
    'CNSP-resources-main/CNSP'];

addpath(fullfile(root,'datasets'));
addpath(fullfile(root,'datasets','irene_trial_12_04'));
addpath(fullfile(root,'libs'));
addpath(fullfile(root,'libs','cnsp_utils'));
addpath(fullfile(root,'libs','cnsp_utils','cnd'));
addpath(fullfile(root,'eeglab2026.0.0'));
addpath(fullfile(root,'code'));
addpath(fullfile(root,'libs','mTRF-Toolbox_v2','mtrf'));
addpath(root);
addpath(fullfile(root,'libs','fieldtrip'));

pathCND  = ['/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/' ...
    'Projects/NEUROLIP/data_preprocessed/CND_data_format'];
savePath = ['/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/' ...
    'Projects/NEUROLIP/results'];

% ================================================================
%  PARAMETERS
% ================================================================

condLabels = {'Clear','Vocoded'};
nCond = 2;

fsEEG_expected = 200;
fsET = 120;

% mTRF
lambdas   = 10.^(-3:6);
dirTRF    = 1;                 % forward
tmin      = -100;              % ms
tmax      = 500;               % ms
regMethod = 'Ridge';

% Lambda choice: smallest lambda within tolerancePercent of the best r
tolerancePercent    = 0.05;
useToleranceLambda  = true;
pickLambda = @(rl) local_pickLambda(rl,lambdas,tolerancePercent,useToleranceLambda);

% Quality control
nSD            = 3;            % MAD criterion (trial and subject level)
minTrialsCond  = 3;            % good EEG trials per condition
minSegments    = 3;            % usable ET segments per condition
minSegDuration = 1.0;          % s
minSegSamples  = round(minSegDuration*fsET);

% ET handling
invalidOutsideRange = false;   % true: ET values outside [0 1] -> NaN (segment break)
normalizePredictors = true;    % z-score envelope and ET within subject

% EEG
avgElectrodes = true;          % average channels into one virtual channel
useROI        = false;         % true: average only roiElec (needs chanlocs labels)
roiElec       = {'F1','Fz','F2','C1','C2','Cz'};

% Bands (ET is NOT filtered for 'broad'; EEG is assumed already filtered)
bandNames = {'broad'};
bandRange = {[1 8]};

% ================================================================
%  SUBJECT FILES
% ================================================================

files = dir(fullfile(pathCND,'CND*'));
selection = {files(:).name};
nSubs = numel(selection);
fprintf('\nFound %d CND files.\n',nSubs);

% ================================================================
%  STEP 1: LOAD + EEG QUALITY
% ================================================================

fprintf('\n=== STEP 1: loading and EEG quality ===\n');

D          = cell(1,nSubs);        % eeg structure per subject
badTrial   = cell(1,nSubs);
subMedRMS  = nan(1,nSubs);

for sub = 1:nSubs
    
    fprintf('Subject %d/%d: %s\n',sub,nSubs,selection{sub});
    
    tmp = load(fullfile(pathCND,selection{sub}));
    tmp = tmp.eeg;
    D{sub} = tmp;
    
    nTr = numel(tmp.data);
    
    if numel(tmp.cond) ~= nTr
        error('cond and data have different numbers of trials in %s',selection{sub});
    end
    if numel(tmp.stim) ~= nTr
        error('stim and data have different numbers of trials in %s',selection{sub});
    end
    
    bad = false(1,nTr);
    idx = find(~cellfun(@isempty,tmp.data));
    
    rms1 = nan(1,numel(idx));
    for k = 1:numel(idx)
        E = tmp.data{idx(k)};
        rms1(k) = sqrt(mean(E(:).^2,'omitnan'));
    end
    
    med  = median(rms1,'omitnan');
    madv = 1.4826*median(abs(rms1-med),'omitnan');
    if madv == 0, madv = eps; end
    
    bt = abs(rms1-med) > nSD*madv | isnan(rms1);
    bad(idx(bt)) = true;
    bad(cellfun(@isempty,tmp.data)) = true;     % empty trials are bad too
    
    badTrial{sub}  = bad;
    subMedRMS(sub) = median(rms1(~bt),'omitnan');
end

% Subject-level quality
gMed = median(subMedRMS,'omitnan');
gMAD = 1.4826*median(abs(subMedRMS-gMed),'omitnan');
if gMAD == 0, gMAD = eps; end

keepSub = abs(subMedRMS-gMed) <= nSD*gMAD & ~isnan(subMedRMS);

% Condition counts
nGood = zeros(nSubs,nCond);
for sub = 1:nSubs
    cnd = D{sub}.cond(:)';
    for c = 1:nCond
        nGood(sub,c) = sum(~badTrial{sub} & cnd == c);
    end
    keepSub(sub) = keepSub(sub) && all(nGood(sub,:) >= minTrialsCond);
end

fprintf('\nEEG-valid subjects: %d/%d\n',sum(keepSub),nSubs);
fprintf('Excluded: %s\n',mat2str(find(~keepSub)));

validEEGSubjects = find(keepSub);
if isempty(validEEGSubjects)
    error('No EEG-valid subjects remain.');
end

fsEEG = D{validEEGSubjects(1)}.fs;
fprintf('EEG sampling rate: %.3f Hz\n',fsEEG);
if abs(fsEEG-fsEEG_expected) > 0.1
    warning('Expected %.1f Hz EEG, found %.3f Hz.',fsEEG_expected,fsEEG);
end

% ================================================================
%  STEP 2: BUILD TRIAL CELLS (alignment preserved)
%
%  Bad trials are replaced by [] (never deleted), so that cond(k),
%  eegRows{k}, eyeRows{k} and stimRows{k} always refer to the same trial.
% ================================================================

fprintf('\n=== STEP 2: EEG / ET / envelope per trial ===\n');

eegGroup  = cell(1,nSubs);
etGroup   = cell(1,nSubs);
stimGroup = cell(1,nSubs);
condGroup = cell(1,nSubs);

for sub = validEEGSubjects
    
    tmp = D{sub};
    
    eegRows  = tmp.data;
    stimRows = tmp.stim;
    eyeRows  = extract_ET_from_CND(tmp);
    
    if numel(eyeRows) ~= numel(eegRows)
        error('ET trials (%d) ~= EEG trials (%d) for %s', ...
            numel(eyeRows),numel(eegRows),selection{sub});
    end
    
    rm = badTrial{sub};
    eegRows(rm)  = {[]};
    eyeRows(rm)  = {[]};
    stimRows(rm) = {[]};
    
    % EEG channel handling
    for tr = 1:numel(eegRows)
        if isempty(eegRows{tr}), continue, end
        E = eegRows{tr};
        
        if useROI && isfield(tmp,'chanlocs') && isfield(tmp.chanlocs,'labels')
            labs = {tmp.chanlocs.labels};
            ix = find(ismember(labs,roiElec));
            if ~isempty(ix), E = E(:,ix); end
        end
        
        if avgElectrodes
            E = mean(E,2,'omitnan');
        end
        eegRows{tr} = E;
    end
    
    % Normalise EEG within subject
    ne = ~cellfun(@isempty,eegRows);
    allE = vertcat(eegRows{ne});
    nf = std(allE(:),'omitnan');
    if nf == 0 || isnan(nf), nf = 1; end
    for tr = find(ne)
        eegRows{tr} = eegRows{tr}./nf;
    end
    
    eegGroup{sub}  = eegRows;
    etGroup{sub}   = eyeRows;
    stimGroup{sub} = stimRows;
    condGroup{sub} = tmp.cond(:)';
end

clear D    % free memory

% ================================================================
%  STEP 3: ET SEGMENTS (valid runs, no interpolation)
% ================================================================

fprintf('\n=== STEP 3: building ET/EEG/envelope segments ===\n');

ETseg   = cell(nSubs,nCond);
ENVseg  = cell(nSubs,nCond);
EEGseg  = cell(nSubs,nCond);
segInfo = cell(nSubs,nCond);
nSegments = zeros(nSubs,nCond);

for sub = validEEGSubjects
    
    fprintf('%s: ',selection{sub});
    
    for icond = 1:nCond
        
        ETseg{sub,icond}  = {};
        ENVseg{sub,icond} = {};
        EEGseg{sub,icond} = {};
        segInfo{sub,icond} = struct('trial',{},'segment',{},'duration',{});
        
        trIdx = find(condGroup{sub} == icond);
        c = 0;
        
        for tr = trIdx
            
            EEG  = eegGroup{sub}{tr};
            ET   = etGroup{sub}{tr};
            STIM = stimGroup{sub}{tr};
            
            if isempty(EEG) || isempty(ET) || isempty(STIM), continue, end
            
            EEG = double(EEG(:));
            ET  = double(ET(:));
            ENV = double(STIM(:,1));        % column 1 = envelope (200 Hz)
            
            if any(~isfinite(EEG)) || any(~isfinite(ENV))
                warning('Non-finite EEG/ENV in %s trial %d. Skipped.',selection{sub},tr);
                continue
            end
            
            if invalidOutsideRange
                ET(ET < 0 | ET > 1) = NaN;
            end
            
            ET = ET - 0.5;      % -0.5 eyes | 0 nose | +0.5 mouth
            
            % Common duration
            Tcommon = min([(length(EEG)-1)/fsEEG, ...
                (length(ET)-1)/fsET, ...
                (length(ENV)-1)/fsEEG]);
            if Tcommon <= minSegDuration, continue, end
            
            nET = min(floor(Tcommon*fsET)+1,length(ET));
            ETc = ET(1:nET);
            
            % Contiguous valid runs
            valid = isfinite(ETc);
            d = diff([false; valid; false]);
            sV = find(d == 1);
            eV = find(d == -1)-1;
            
            for iseg = 1:numel(sV)
                
                a = sV(iseg);
                b = eV(iseg);
                
                if (b-a+1) < minSegSamples, continue, end
                
                etSeg120 = ETc(a:b);
                
                tStart = (a-1)/fsET;
                tEnd   = (b-1)/fsET;
                
                i1 = max(1,floor(tStart*fsEEG)+1);
                i2 = min([length(EEG),length(ENV),floor(tEnd*fsEEG)+1]);
                if i2 <= i1, continue, end
                
                eegSeg = EEG(i1:i2);
                envSeg = ENV(i1:i2);
                
                % ET 120 -> 200 Hz
                etSeg200 = resample(etSeg120,fsEEG,fsET);
                etSeg200 = etSeg200(:);
                
                L = min([length(etSeg200),length(envSeg),length(eegSeg)]);
                if L < round(minSegDuration*fsEEG), continue, end
                
                etSeg200 = etSeg200(1:L);
                envSeg   = envSeg(1:L);
                eegSeg   = eegSeg(1:L);
                
                if any(~isfinite(etSeg200)) || any(~isfinite(eegSeg)) || ...
                        any(~isfinite(envSeg))
                    continue
                end
                
                c = c+1;
                ETseg{sub,icond}{c}  = etSeg200;
                ENVseg{sub,icond}{c} = envSeg;
                EEGseg{sub,icond}{c} = eegSeg;
                segInfo{sub,icond}(c).trial    = tr;
                segInfo{sub,icond}(c).segment  = iseg;
                segInfo{sub,icond}(c).duration = L/fsEEG;
            end
        end
        
        nSegments(sub,icond) = c;
        fprintf('%s=%d  ',condLabels{icond},c);
    end
    fprintf('\n');
end

clear eegGroup etGroup stimGroup

validSubBand = nSegments >= minSegments;      % nSubs x nCond

for icond = 1:nCond
    fprintf('%s: %d subjects with >= %d segments\n', ...
        condLabels{icond},sum(validSubBand(:,icond)),minSegments);
end

% ================================================================
%  STEP 4: NORMALISE PREDICTORS (within subject, pooled over conditions)
% ================================================================

if normalizePredictors
    for sub = validEEGSubjects
        
        allEnv = []; allEt = [];
        for icond = 1:nCond
            if ~isempty(ENVseg{sub,icond}), allEnv = [allEnv; vertcat(ENVseg{sub,icond}{:})]; end %#ok<AGROW>
            if ~isempty(ETseg{sub,icond}),  allEt  = [allEt;  vertcat(ETseg{sub,icond}{:})];  end %#ok<AGROW>
        end
        if isempty(allEnv), continue, end
        
        mE = mean(allEnv);  sE = std(allEnv);  if sE == 0, sE = 1; end
        mT = mean(allEt);   sT = std(allEt);   if sT == 0, sT = 1; end
        
        for icond = 1:nCond
            for k = 1:numel(ENVseg{sub,icond})
                ENVseg{sub,icond}{k} = (ENVseg{sub,icond}{k}-mE)./sE;
                ETseg{sub,icond}{k}  = (ETseg{sub,icond}{k}-mT)./sT;
            end
        end
    end
end

% ================================================================
%  STEP 5: ET BANDS
% ================================================================

ETband = cell(nSubs,nCond,numel(bandNames));

for sub = validEEGSubjects
    for icond = 1:nCond
        for iband = 1:numel(bandNames)
            ETband{sub,icond,iband} = cell(size(ETseg{sub,icond}));
            for k = 1:numel(ETseg{sub,icond})
                x = ETseg{sub,icond}{k};
                if iband == 1
                    ETband{sub,icond,iband}{k} = x;
                else
                    if length(x) < max(100,round(1.5*fsEEG))
                        ETband{sub,icond,iband}{k} = [];
                    else
                        ETband{sub,icond,iband}{k} = ...
                            local_bp(x,bandRange{iband}(1),bandRange{iband}(2),fsEEG);
                    end
                end
            end
        end
    end
end

% ================================================================
%  STEP 6: THREE TRF MODELS PER SUBJECT AND CONDITION
% ================================================================

fprintf('\n=== STEP 6: TRF models ===\n');

modelNames = {'Env','ET','Both'};
nModel = numel(modelNames);

RES = struct();

for iband = 1:numel(bandNames)
    for icond = 1:nCond
        
        fprintf('\n##### %s | %s #####\n',bandNames{iband},condLabels{icond});
        
        r      = nan(nSubs,nModel);
        lam    = nan(nSubs,nModel);
        W      = cell(nSubs,nModel);
        nSegUsed = zeros(nSubs,1);
        
        for sub = find(validSubBand(:,icond))'
            
            env = ENVseg{sub,icond};
            et  = ETband{sub,icond,iband};
            y   = EEGseg{sub,icond};
            
            keep = ~cellfun(@isempty,env) & ~cellfun(@isempty,et) & ~cellfun(@isempty,y);
            env = env(keep);  et = et(keep);  y = y(keep);
            
            if numel(y) < minSegments
                fprintf('  %s: not enough segments after filtering\n',selection{sub});
                continue
            end
            nSegUsed(sub) = numel(y);
            
            Xenv  = cellfun(@(e) e(:),env,'UniformOutput',false);
            Xet   = cellfun(@(t) t(:),et, 'UniformOutput',false);
            Xboth = cellfun(@(e,t) [e(:) t(:)],env,et,'UniformOutput',false);
            Xs = {Xenv,Xet,Xboth};
            
            fprintf('  %s (%d segments): ',selection{sub},numel(y));
            
            for im = 1:nModel
                try
                    [r(sub,im),lam(sub,im),W{sub,im}] = local_fit( ...
                        Xs{im},y,fsEEG,dirTRF,tmin,tmax,lambdas,regMethod,pickLambda);
                    fprintf('%s r=%.3f  ',modelNames{im},r(sub,im));
                catch ME
                    fprintf('\n    %s FAILED: %s\n',modelNames{im},ME.message);
                end
            end
            fprintf('\n');
        end
        
        RES(iband,icond).condition  = condLabels{icond};
        RES(iband,icond).band       = bandNames{iband};
        RES(iband,icond).models     = modelNames;
        RES(iband,icond).r          = r;            % nSubs x 3 (Env, ET, Both)
        RES(iband,icond).deltaR     = r(:,3)-r(:,1);% Both - Env
        RES(iband,icond).lambda     = lam;
        RES(iband,icond).W          = W;
        RES(iband,icond).nSegments  = nSegUsed;
        RES(iband,icond).validSubs  = find(isfinite(r(:,3)))';
    end
end

% ================================================================
%  STEP 7: SAVE
% ================================================================

if ~exist(savePath,'dir'), mkdir(savePath); end

saveFile = fullfile(savePath,'NeuroLip_ET_ENV_forwardTRF.mat');
save(saveFile,'RES','selection','condLabels','bandNames','bandRange', ...
    'modelNames','fsEEG','fsET','lambdas','tmin','tmax','minSegDuration', ...
    'minSegments','segInfo','nSegments','-v7.3');
fprintf('\nSaved: %s\n',saveFile);

% ================================================================
%  STEP 8: SUMMARY + STATS
% ================================================================

iband = 1;

fprintf('\n=== SUMMARY (%s) ===\n',bandNames{iband});
for icond = 1:nCond
    for im = 1:nModel
        x = RES(iband,icond).r(:,im);
        x = x(isfinite(x));
        fprintf('%-8s %-5s N=%2d  mean r=%.4f  median=%.4f  SD=%.4f\n', ...
            condLabels{icond},modelNames{im},numel(x),mean(x),median(x),std(x));
    end
    dR = RES(iband,icond).deltaR;  dR = dR(isfinite(dR));
    msg = '';
    try
        p = signrank(dR);
        msg = sprintf('  signrank p=%.4f',p);
    catch
    end
    fprintf('%-8s dR(Both-Env) N=%2d  mean=%.4f%s\n',condLabels{icond},numel(dR),mean(dR),msg);
end

% Clear vs Vocoded, same participants
for im = 1:nModel
    a = RES(iband,1).r(:,im);  b = RES(iband,2).r(:,im);
    ok = isfinite(a) & isfinite(b);
    msg = '';
    try
        p = signrank(a(ok),b(ok));
        msg = sprintf('  signrank p=%.4f',p);
    catch
    end
    fprintf('Clear vs Vocoded, %-5s N=%d  mean diff=%.4f%s\n', ...
        modelNames{im},sum(ok),mean(a(ok)-b(ok)),msg);
end

%% ================================================================
%  STEP 9: PLOTS
% ================================================================

Color_clear   = [222,161,147]./255;
Color_vocoded = [206,12,12]./255;

% ---- 9A. Prediction r, Clear vs Vocoded, one panel per model ----
figure('Position',[50 100 1300 480],'Color','white');
for im = 1:nModel
    subplot(1,nModel,im); hold on
    a = RES(iband,1).r(:,im);  b = RES(iband,2).r(:,im);
    ok = isfinite(a) & isfinite(b);
    for s = find(ok)'
        plot([1 2],[a(s) b(s)],'-o','Color',[0.7 0.7 0.7], ...
            'MarkerFaceColor',[0.7 0.7 0.7],'MarkerSize',4);
    end
    plot(1,mean(a(ok)),'o','MarkerSize',11,'MarkerFaceColor',Color_clear,'MarkerEdgeColor','k');
    plot(2,mean(b(ok)),'o','MarkerSize',11,'MarkerFaceColor',Color_vocoded,'MarkerEdgeColor','k');
    plot([1 2],[mean(a(ok)) mean(b(ok))],'k-','LineWidth',2);
    yline(0,'k--');
    xlim([0.6 2.4]); set(gca,'XTick',[1 2],'XTickLabel',condLabels,'FontSize',12);
    ylabel('Prediction r'); title(sprintf('%s (N=%d)',modelNames{im},sum(ok)));
    box off
end

% ---- 9B. Gain from ET: Both - Env ----
figure('Position',[100 100 600 500],'Color','white'); hold on
dC = RES(iband,1).deltaR;  dV = RES(iband,2).deltaR;
ok = isfinite(dC) & isfinite(dV);
for s = find(ok)'
    plot([1 2],[dC(s) dV(s)],'-o','Color',[0.7 0.7 0.7], ...
        'MarkerFaceColor',[0.7 0.7 0.7],'MarkerSize',4);
end
plot(1,mean(dC(ok)),'o','MarkerSize',11,'MarkerFaceColor',Color_clear,'MarkerEdgeColor','k');
plot(2,mean(dV(ok)),'o','MarkerSize',11,'MarkerFaceColor',Color_vocoded,'MarkerEdgeColor','k');
yline(0,'k--');
xlim([0.6 2.4]); set(gca,'XTick',[1 2],'XTickLabel',condLabels,'FontSize',12);
ylabel('\Delta r  (Envelope+ET  -  Envelope)'); title('Added value of eye tracking');
box off

% ---- 9C. TRFs: Env (Both model), ET (Both model), ET-only ----
trfSpec = { 'Envelope TRF (Env+ET model)', 3, 1;
    'ET TRF (Env+ET model)',       3, 2;
    'ET TRF (ET-only model)',      2, 1 };

figure('Position',[50 100 1400 480],'Color','white');
for p = 1:size(trfSpec,1)
    subplot(1,3,p); hold on
    im = trfSpec{p,2};  ix = trfSpec{p,3};
    smoothMs = 60;     % try 40-100 ms
    
    [Wc,tC] = local_collectW(RES(iband,1).W(:,im),ix,smoothMs);
    [Wv,tV] = local_collectW(RES(iband,2).W(:,im),ix,smoothMs);
    
    
    local_shade(tC,Wc,Color_clear);
    local_shade(tV,Wv,Color_vocoded);
    
    xline(0,'k--'); yline(0,'k--');
    xlim([-50 400]); xlabel('Lag (ms)'); ylabel('TRF weight');
    title(trfSpec{p,1}); box off; set(gca,'FontSize',12);
    if p == 1, legend({'Clear (SEM)','Clear','Vocoded (SEM)','Vocoded'},'Location','best'); end
end

fprintf('\nDONE\n');

% ================================================================
%  LOCAL FUNCTIONS  (must stay at the end of the script)
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
    error('Number of lambdas does not match number of CV values.');
end

good = isfinite(rLambda);
if ~any(good)
    error('No valid cross-validation correlations for lambda selection.');
end

rGood = rLambda(good);
lGood = lambdas(good);

[maxR,idxMax] = max(rGood);
lam = lGood(idxMax);

if useTolerance
    idx = find(rGood >= maxR*(1-tolerancePercent));
    if ~isempty(idx)
        lam = lGood(idx(1));
    end
end
end