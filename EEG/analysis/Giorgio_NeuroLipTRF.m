
% This code was adapted by Irene Arrieta from that of
% Giorgio Piazza

clear
close all
clc

set(0,'DefaultFigureVisible','on')
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/datasets
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/datasets/irene_trial_12_04
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/cnsp_utils/cnd
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/cnsp_utils
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/eeglab2026.0.0
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/code
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/mTRF-Toolbox_v2/mtrf
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP
addpath /Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/CNSP-resources-main/CNSP/libs/fieldtrip;

%% Set Parameters for TRF (whether it is across conditions or all together)
%**************************************************
set(0,'DefaultFigureVisible','on')

%tmin = -100;
%tmax = 400;
%lambdas = 10.^(-2:8); % larger set of lambdas (slower)
%dirTRF = 1; % Forward TRF model
pathDataPrep = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed';
files = dir(fullfile(pathDataPrep, 'clean_not_epoched_prep*'));

% dataMainFolder2 = './datasets/BabySign/';
% dataMainFolder = './datasets/BabySign/raw/parent_infant';
% allContents = dir(dataMainFolder);
%
% % Keep only entries that are directories and not '.' or '..'
% isSubfolder = [allContents.isdir] & ~ismember({allContents.name}, {'.', '..'});
% isSub = contains({allContents.name}, 'eeg');
%
% participantFolders = allContents(isSubfolder);
% [~, idx] = natsortfiles({participantFolders.name});
% participantFolders = participantFolders(idx);
nSub = length(files);

% Parameters - Natural speech listening experiment
% dataMainFolder = './datasets/BabySign/';
% dataCNDSubfolder = 'ParentInf_CND/';
% plotfolder = 'H:\CNSP\datasets\fdSpeechPiazza\trf_plot\';
% hp = 1; %highpass
% lp = 8; %low pass
% band = [hp, lp];
% downFsAud = 200;
% fs = 200;

% bandpassFilterRange = [hp,lp]; % Hz (indicate 0 to avoid running the low-pass
% or high-pass filters or both)
% e.g., [0,8] will apply only a low-pass filter
% at 8 Hz
%
% eegFilenames = dir([dataMainFolder,dataCNDSubfolder,'pre_dataSub_*.mat']);
% eegFilenames = natsortfiles(eegFilenames);
% %
% if downFs < bandpassFilterRange(2)*2
%     disp('Warning: Be careful. The low-pass filter should use a cut-off frequency smaller than downFs/2')
% end

%% ===== NeuroLip forward TRF — single group, two conditions =====
% Selecting good particiapnts and trials
Chan2Plot = 'F2';
forceElec = 'auto';   % '' = auto (max subjects, then max electrodes)

% loadDir  = 'C:\Users\giorg\OneDrive\Documenti\MATLAB\CNSP\datasets\NeuroLip\drive-download-20260913T153559Z-1-001\';
savePath = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results';
% if ~exist(savePath,'dir'); mkdir(savePath); end
%
% fileList = dir(fullfile(loadDir,'not_epoched_prep_NLP*.mat'));
%selection = {'clean_not_epoched_prep_NLP01.mat',  ...
%    'clean_not_epoched_prep_NLP11.mat', 'clean_not_epoched_prep_NLP13.mat', 'clean_not_epoched_prep_NLP14.mat', ...
%    'clean_not_epoched_prep_NLP15.mat', 'clean_not_epoched_prep_NLP16.mat', 'clean_not_epoched_prep_NLP17.mat', ...
%    'clean_not_epoched_prep_NLP18.mat', 'clean_not_epoched_prep_NLP19.mat', ...
%    'clean_not_epoched_prep_NLP22.mat', 'clean_not_epoched_prep_NLP23.mat', 'clean_not_epoched_prep_NLP24.mat', ...
%    'clean_not_epoched_prep_NLP25.mat', 'clean_not_epoched_prep_NLP30.mat', ...
%    'clean_not_epoched_prep_NLP33.mat'};

% Too strange zero values:
% sub03   -0.657  -0.192   4.292  -3.465   0.774
% sub12   -0.367  -0.154  -3.445   2.304  -0.660
% sub18   -0.636   1.041  -1.758   0.947   0.097
% sub22    0.285   0.910  -1.754   0.877   1.133
% sub33   -0.838   1.329  -0.587  -1.426   0.858

% files(3).name = clean_not_epoched_prep_NLP04
% files(12).name = clean_not_epoched_prep_NLP14
% files(18).name = clean_not_epoched_prep_NLP20
% files(22).name = clean_not_epoched_prep_NLP25
% files(33).name = clean_not_epoched_prep_NLP36

% If i do not want to take out anybody, out_peak = [];
out_peak = [];

% out_peak = {'clean_not_epoched_prep_NLP04.mat', 'clean_not_epoched_prep_NLP14.mat', 'clean_not_epoched_prep_NLP20.mat', ...
%    'clean_not_epoched_prep_NLP25.mat', 'clean_not_epoched_prep_NLP36.mat'};

selection = setdiff({files(:).name}, out_peak);

nSubs    = numel(selection);
fprintf('Found %d NeuroLip files\n', nSubs);

condLabels = {'Clear','Vocoded'};
bands      = 'prep';
audioName  = 'Audio';        % envelope channel label

% analysis params
nSD        = 3;             % robust (MAD) rejection threshold, trial & subject
minTrials  = 3;             % min usable trials per condition to keep a subject
minContrib = 3;             % min other-subjects sharing a monologue to build a GT

% metric for preprocessing particiapnts/trials: per-trial RMS of RAW EEG (Audio row excluded), before normalization
% robust rejection via MAD (median absolute deviation)

subMedRMS = nan(1, nSubs);
badTrial  = cell(1, nSubs);

for sub = 1:nSubs
    % If I want to only look at the selection:
    % tmp = load(fullfile(pathDataPrep, selection{sub}));
    % If I look at all participants
    tmp = load(fullfile(pathDataPrep, selection{sub}));
    if isfield(tmp,'data_epoched_clean'); dp = tmp.data_epoched_clean;
    else, fn = fieldnames(tmp); dp = tmp.(fn{1}); end
    lab  = dp.label(:)';
    audRow  = find(strcmpi(lab, audioName), 1);
    eegRows = setdiff(1:numel(lab), audRow);
    
    nTrl = numel(dp.trial);
    rms1 = nan(1, nTrl);
    for k = 1:nTrl
        E = dp.trial{k}(eegRows,:);                 % EEG only
        rms1(k) = sqrt(mean(E(:).^2));
    end
    
    % trial-level rejection (MAD)
    med  = median(rms1,'omitnan');
    madv = 1.4826 * median(abs(rms1 - med),'omitnan'); if madv==0; madv = eps; end
    bt   = abs(rms1 - med) > nSD*madv;
    
    badTrial{sub}  = bt;
    subMedRMS(sub) = median(rms1(~bt),'omitnan');
    fprintf('sub %2d: medRMS=%.3g  trials rejected %d/%d %s\n', ...
        sub, subMedRMS(sub), sum(bt), nTrl, mat2str(find(bt)));
end

% subject-level rejection (MAD across subjects)
gMed = median(subMedRMS,'omitnan');
gMAD = 1.4826 * median(abs(subMedRMS - gMed),'omitnan'); if gMAD==0; gMAD = eps; end
keepSub = abs(subMedRMS - gMed) <= nSD*gMAD & ~isnan(subMedRMS);



% subject-level rejection: too few usable trials in either condition
nC1 = nan(1,nSubs); nC2 = nan(1,nSubs);
for sub = 1:nSubs
    % tmp = load(fullfile(pathDataPrep, selection{sub}));
    % Commented when selection ON
    tmp = load(fullfile(pathDataPrep, selection{sub}));
    if isfield(tmp,'data_epoched_clean'); dp=tmp.data_epoched_clean; else, fn=fieldnames(tmp); dp=tmp.(fn{1}); end
    good = ~badTrial{sub};
    nC1(sub) = sum(good & dp.cond(:)'==1);
    nC2(sub) = sum(good & dp.cond(:)'==2);
end
keepSub = keepSub & (nC1 >= minTrials) & (nC2 >= minTrials);
fprintf('\nGroup medRMS=%.3g MAD=%.3g | subjects kept %d/%d\n', gMed, gMAD, sum(keepSub), nSubs);
fprintf('dropped (amp or <%d trials): %s\n', minTrials, mat2str(find(~keepSub)));

%% ===== NeuroLip forward TRF — =====
%   - ONE model per subject: lambda + weights fit on the subject's OWN data (stim->own EEG),
%     Ridge, per-subject tolerance-tuned lambda, broadband (1-8 Hz).
%   - That model is the object under test. Its generalization is measured by predicting the
%     group GROUND TRUTH (mean of the OTHER subjects' EEG for the same monologue, self excluded).
%   - The SAME broadband model is evaluated against band-limited targets:
%         broad = 1-8 Hz, delta = 1-4 Hz, theta = 4-8 Hz   (Di Liberto: fit broadband, score in-band).
%   - Trial-mismatch PERMUTATION NULL for BOTH GT and Own predictions, per band.
%   - TRF weights shown for the OWN-BASED (broadband) model only  — that is the model
%     that produces the GT bar. (The separate stim->GT "GT-based" TRF was removed: it is a
%     different object and is not what is being evaluated.)
%
% ---------------------------------------------------------------------------------

for iiStim = 1
    lambdas   = 10.^(-3:6);
    dirTRF    = 1;
    tmin = -100; tmax = 500;
    plotXlim  = [-50 400];
    regMethod = 'Ridge';               % mTRF default
    lambdaTune = 'own';                % 'own': tune lambda on own-EEG crossval (standard TRF)
    % 'gt' : tune lambda so the own-trained model best predicts the GT
    %        (Di Liberto style; NESTED inside the LOO to stay unbiased)
    avgElectrodes = true;              % true: collapse each subject's frontocentral ROI to ONE virtual
    %       channel (higher SNR). false: shared-electrode block + Chan2Plot
    roiElec = {'F1','Fz','F2','C1','C2','Cz'};   % ROI to average when avgElectrodes=true
    tolerancePercent = 0.05;
    useToleranceLambda = true;
    nPerm     = 500;
    
    % evaluation bands: model is fit on the BROAD band, prediction scored against band-limited GT/own
    bandNames  = {'broad','delta','theta'};
    bandRange  = {[1 8],   [1 4],   [4 8]};
    nB         = numel(bandNames);
    bBroad     = 1;                     % index of the band the MODEL is trained on
    broadUsesNative = true;            % true: 'broad' = your loaded band as-is; othewise we need refilter)
    % false: 'broad' = explicit bandRange{bBroad} refilter
    filterPred      = false;           % true: band-filter the PREDICTION too before scoring (clean in-band r)
    % false: Di Liberto style (broadband prediction vs band-limited target)
    nullType        = 'mismatch';      % 'mismatch' : pred(t) vs a DIFFERENT-monologue trial   (stimulus specificity)
    % 'circshift': pred(t) time-shifted vs matched target    (temporal specificity)
    % 'randseg'  : pred(t) vs a random L-segment of the      (temporal specificity,
    %              concatenated target                        larger surrogate pool)
    
    
    pickLambda = @(rl) local_pickLambda(rl, lambdas, tolerancePercent, useToleranceLambda);
    
    figure('Position',[100,100,1050,820],'Color','white','Name','NeuroLip forward TRF v3 (band-resolved)');
    RESp = struct();
    
    for iicond = 1:2
        condVal = iicond; condName = condLabels{iicond};
        clear eegGroup stimGroup codeGroup labGroup
        validSubs = [];
        
        % ---------- LOAD ----------
        for sub = 1:nSubs
            if ~keepSub(sub); continue; end
            % Comment when selection not ON
            % tmp = load(fullfile(pathDataPrep, selection{sub}));
            tmp = load(fullfile(pathDataPrep, selection{sub}));
            if isfield(tmp,'data_preprocessed'); dp = tmp.data_preprocessed;
            else, fn = fieldnames(tmp); dp = tmp.(fn{1}); end
            fs = dp.fsample;
            sel = find(dp.cond == condVal); sel = sel(~badTrial{sub}(sel));
            if isempty(sel); continue; end
            lab     = dp.label(:)';
            audRow  = find(strcmpi(lab, audioName), 1);
            eegRows = setdiff(1:numel(lab), audRow);
            eeg.fs = fs; stim.fs = fs;
            eeg.data = cell(1,numel(sel)); stim.data = cell(1,numel(sel));
            for k = 1:numel(sel)
                tr = dp.trial{sel(k)};
                eeg.data{k}  = tr(eegRows,:)';
                stim.data{k} = tr(audRow,:)';
            end
            eegGroup{sub}=eeg; stimGroup{sub}=stim; labGroup{sub}=lab(eegRows);
            codeGroup{sub}=dp.monologue(sel); validSubs(end+1)=sub; clear eeg stim
        end
        validSubs = unique(validSubs);
        fprintf('[%s] valid subs: %d\n', condName, numel(validSubs));
        
        % ---------- ELECTRODE HANDLING ----------
        if avgElectrodes
            % collapse each subject's available ROI electrodes to one virtual channel (mean)
            keep=[];
            for s=validSubs
                [tf,ic]=ismember(roiElec, labGroup{s}); ic=ic(tf);
                if isempty(ic); continue; end
                eegGroup{s}.data=cellfun(@(x) mean(x(:,ic),2), eegGroup{s}.data,'UniformOutput',false);
                keep(end+1)=s; %#ok<AGROW>
            end
            validSubs=keep; commonLab={'ROIavg'}; nCh=1;
            fprintf('[%s] ROI-average over {%s}: %d subs kept\n',condName,strjoin(roiElec,','),numel(validSubs));
        else
            % ---------- LARGEST SHARED ELECTRODE BLOCK ----------
            allLab = unique([labGroup{validSubs}],'stable');
            if ~strcmp(forceElec,'auto')
                if ~ismember(forceElec,allLab); error('channel not present'); end
                S=validSubs(cellfun(@(L)any(strcmp(L,forceElec)),labGroup(validSubs)));
                E=labGroup{S(1)}; for s=S(2:end); E=intersect(E,labGroup{s},'stable'); end
                best=struct('subs',S,'lab',{E});
            else
                best=struct('subs',[],'lab',{{}},'nS',0,'nE',0);
                for e=1:numel(allLab)
                    S=validSubs(cellfun(@(L)any(strcmp(L,allLab{e})),labGroup(validSubs)));
                    if isempty(S); continue; end
                    E=labGroup{S(1)}; for s=S(2:end); E=intersect(E,labGroup{s},'stable'); end
                    if numel(S)>best.nS || (numel(S)==best.nS && numel(E)>best.nE)
                        best.subs=S; best.lab=E; best.nS=numel(S); best.nE=numel(E);
                    end
                end
            end
            commonLab=best.lab; validSubs=best.subs; nCh=numel(commonLab);
            fprintf('[%s] kept %d subs on %d electrode(s): %s\n',condName,numel(validSubs),nCh,strjoin(commonLab,','));
            if nCh==0; error('No shared electrode'); end
            for s=validSubs
                [~,ic]=ismember(commonLab,labGroup{s});
                eegGroup{s}.data=cellfun(@(x)x(:,ic),eegGroup{s}.data,'UniformOutput',false);
            end
        end   % avgElectrodes
        
        % ---------- normalise EEG (global std factor) ----------
        for s=validSubs
            allE=vertcat(eegGroup{s}.data{:}); nf=std(allE(:)); if nf==0; nf=1; end
            eegGroup{s}.data=cellfun(@(x)x./nf,eegGroup{s}.data,'UniformOutput',false);
        end
        
        % ---------- band-filtered EEG copies (one set per eval band) ----------
        % eegBand{b}{s}.data{t} : subject s, trial t, filtered into band b
        eegBand = cell(1,nB);
        for b=1:nB
            for s=validSubs
                if broadUsesNative && b==bBroad
                    eegBand{b}{s}.data = eegGroup{s}.data;   % native band, no refilter (data already 1-8)
                else
                    eegBand{b}{s}.data = cellfun(@(x) local_bp(x, bandRange{b}(1), bandRange{b}(2), fs), ...
                        eegGroup{s}.data, 'UniformOutput',false);
                end
            end
        end
        
        % ---------- GROUND TRUTH per band (self excluded; stim shared across bands) ----------
        stimGTcell = cell(1,numel(validSubs));           % stim per test trial (band-independent)
        gtBand     = cell(1,nB);                         % gtBand{b}{si}{t}
        for b=1:nB; gtBand{b}=cell(1,numel(validSubs)); end
        nContribS  = cell(1,numel(validSubs));
        for si=1:numel(validSubs)
            s=validSubs(si); codes=codeGroup{s}; other=setdiff(validSubs,s);
            nTr=numel(stimGroup{s}.data);
            stimGTcell{si}=cell(1,nTr); nContribS{si}=nan(1,nTr);
            for b=1:nB; gtBand{b}{si}=cell(1,nTr); end
            for t=1:nTr
                c=codes(t); idxOther=[];
                for os=other
                    jj=find(codeGroup{os}==c,1);
                    if ~isempty(jj); idxOther(end+1,:)=[os jj]; end %#ok<AGROW>
                end
                nContribS{si}(t)=size(idxOther,1);
                if size(idxOther,1)<minContrib; continue; end
                Lc=inf; for r=1:size(idxOther,1); Lc=min(Lc,size(eegGroup{idxOther(r,1)}.data{idxOther(r,2)},1)); end
                L=min(size(stimGroup{s}.data{t},1),Lc);
                stimGTcell{si}{t}=stimGroup{s}.data{t}(1:L,:);
                for b=1:nB
                    gt=zeros(L,nCh);
                    for r=1:size(idxOther,1)
                        gt=gt+eegBand{b}{idxOther(r,1)}.data{idxOther(r,2)}(1:L,:);
                    end
                    gtBand{b}{si}{t}=gt/size(idxOther,1);
                end
            end
        end
        
        % ================================================================
        % PER-SUBJECT PIPELINE  (arrays are [nSub x nB], weights broadband)
        % ================================================================
        nS = numel(validSubs);
        rGT=nan(nS,nB); rOwn=nan(nS,nB); rCeil=nan(nS,nB);
        pPerm=nan(nS,nB); zGT=nan(nS,nB); rNullMean=nan(nS,nB); rN95G=nan(nS,nB);
        pPermOwn=nan(nS,nB); zOwn=nan(nS,nB); rNullOwnMean=nan(nS,nB); rN95O=nan(nS,nB);
        allNullG=nan(nPerm,nB,nS); allNullO=nan(nPerm,nB,nS);   % full per-subject nulls (for GROUP threshold)
        lamSub=nan(1,nS); nValidGT=zeros(1,nS);
        nLag=round((tmax-tmin)/1000*fs)+1; WsubOwn=nan(nS,nLag,nCh); tAxis=[];
        
        for si=1:nS
            s=validSubs(si);
            S=stimGroup{s}.data; Rb=eegBand{bBroad}{s}.data; nTr=numel(S);
            
            % (1) lambda for the OWN-based model (broadband)
            gtb0=gtBand{bBroad}{si};                     % broadband GT per trial (tuning criterion for 'gt')
            if strcmp(lambdaTune,'own')
                % Commented
                % cv=mTRFcrossval(S,Rb,fs,dirTRF,tmin,tmax,lambdas,'method',regMethod,'verbose',0,'banded',0);
                cv=mTRFcrossval(S,Rb,fs,dirTRF,tmin,tmax,lambdas,'method',regMethod,'verbose',0);
                
                lamSub(si)=pickLambda(squeeze(mean(mean(cv.r,1),3)));
            else % 'gt' — full-data GT tuning (used only for the displayed weights)
                lamSub(si)=tune_lambda_gt(S,Rb,gtb0,1:nTr,fs,dirTRF,tmin,tmax,lambdas,regMethod,pickLambda);
            end
            
            % (2) LOO broadband model -> predict; score against band-limited targets.
            % Prediction covers the FIRST L samples of the trial, so ALL targets are aligned to 1:L.
            predBandStore=cell(nB,nTr);   % band-filtered prediction per trial (for the null)
            rt_gt=nan(nTr,nB); rt_own=nan(nTr,nB); rt_cl=nan(nTr,nB);
            for t=1:nTr
                if isempty(gtBand{bBroad}{si}{t}); continue; end
                trn=setdiff(1:nTr,t); L=size(gtBand{bBroad}{si}{t},1);
                % choose lambda for THIS fold: fixed (own) or nested GT tuning on training trials only
                if strcmp(lambdaTune,'gt')
                    lamUse=tune_lambda_gt(S,Rb,gtb0,trn,fs,dirTRF,tmin,tmax,lambdas,regMethod,pickLambda);
                else
                    lamUse=lamSub(si);
                end
                m=mTRFtrain(S(trn),Rb(trn),fs,dirTRF,tmin,tmax,lamUse,'method',regMethod,'verbose',0);
                [pg,~]=mTRFpredict({S{t}(1:L,:)}, {Rb{t}(1:L,:)}, m,'verbose',0);
                if iscell(pg); pg=pg{1}; end                 % broad prediction, length L
                for b=1:nB
                    % band-limited prediction (leave native-broad prediction unfiltered)
                    if filterPred && ~(broadUsesNative && b==bBroad)
                        pgB = local_bp(pg, bandRange{b}(1), bandRange{b}(2), fs);
                    else
                        pgB = pg;
                    end
                    predBandStore{b,t} = pgB;
                    gtb  = gtBand{b}{si}{t}(1:L,:);            % length L
                    ownb = eegBand{b}{s}.data{t}(1:L,:);      % first L samples (prediction span)
                    rg=nan(1,nCh); rr=nan(1,nCh); rc=nan(1,nCh);
                    for ch=1:nCh
                        rg(ch)=corr(pgB(:,ch), gtb(:,ch));
                        rr(ch)=corr(pgB(:,ch), ownb(:,ch));
                        rc(ch)=corr(ownb(:,ch), gtb(:,ch));   % noise ceiling: own vs GT, same band
                    end
                    rt_gt(t,b)=mean(rg,'omitnan'); rt_own(t,b)=mean(rr,'omitnan'); rt_cl(t,b)=mean(rc,'omitnan');
                end
            end
            nValidGT(si)=sum(~isnan(rt_gt(:,bBroad)));
            rGT(si,:)=mean(rt_gt,1,'omitnan'); rOwn(si,:)=mean(rt_own,1,'omitnan'); rCeil(si,:)=mean(rt_cl,1,'omitnan');
            
            % (3) NULL per band (GT and Own) — all options zero-centred by construction.
            validT=find(~cellfun(@isempty,predBandStore(bBroad,:)) & ~cellfun(@isempty,gtBand{bBroad}{si}));
            codesV=codeGroup{s};                         % monologue id per trial (for 'mismatch')
            if ~isempty(validT)
                rNullG=nan(nPerm,nB); rNullO=nan(nPerm,nB);
                minShift=round(0.5*fs);
                if strcmp(nullType,'randseg')            % concatenated targets, once per subject/band
                    catG=cell(1,nB); catO=cell(1,nB);
                    for b=1:nB
                        catG{b}=vertcat(gtBand{b}{si}{validT});
                        catO{b}=vertcat(eegBand{b}{s}.data{validT});
                    end
                end
                for p=1:nPerm
                    rg=nan(numel(validT),nB); ro=nan(numel(validT),nB);
                    for ti=1:numel(validT)
                        t=validT(ti); L=size(gtBand{bBroad}{si}{t},1);
                        if strcmp(nullType,'mismatch')
                            cand=validT(validT~=t & codesV(validT)~=codesV(t));  % DIFFERENT monologue only
                            if isempty(cand); continue; end
                            w=cand(randi(numel(cand)));
                        elseif strcmp(nullType,'circshift')
                            maxSh=L-minShift;
                            if maxSh<=minShift; sh=randi(max(1,L-1)); else; sh=randi([minShift,maxSh]); end
                        end
                        for b=1:nB
                            pgB=predBandStore{b,t};
                            switch nullType
                                case 'mismatch'
                                    src=pgB; tgtG=gtBand{b}{si}{w};           tgtO=eegBand{b}{s}.data{w};
                                case 'circshift'
                                    src=circshift(pgB(1:L,:),sh,1);
                                    tgtG=gtBand{b}{si}{t}(1:L,:);             tgtO=eegBand{b}{s}.data{t}(1:L,:);
                                case 'randseg'
                                    src=pgB(1:L,:);
                                    ng=max(1,size(catG{b},1)-L); no=max(1,size(catO{b},1)-L);
                                    sg=randi(ng); so=randi(no);
                                    tgtG=catG{b}(sg:sg+L-1,:);                tgtO=catO{b}(so:so+L-1,:);
                            end
                            Lg=min(size(src,1),size(tgtG,1)); Lo=min(size(src,1),size(tgtO,1));
                            vg=nan(1,nCh); vo=nan(1,nCh);
                            for ch=1:nCh
                                a1=src(1:Lg,ch); b1=tgtG(1:Lg,ch);
                                if std(a1)>eps&&std(b1)>eps; vg(ch)=corr(a1,b1); end
                                a2=src(1:Lo,ch); b2=tgtO(1:Lo,ch);
                                if std(a2)>eps&&std(b2)>eps; vo(ch)=corr(a2,b2); end
                            end
                            rg(ti,b)=mean(vg,'omitnan'); ro(ti,b)=mean(vo,'omitnan');
                        end
                    end
                    rNullG(p,:)=mean(rg,1,'omitnan'); rNullO(p,:)=mean(ro,1,'omitnan');
                end
                for b=1:nB
                    pPerm(si,b)=(sum(rNullG(:,b)>=rGT(si,b))+1)/(nPerm+1);
                    rNullMean(si,b)=mean(rNullG(:,b),'omitnan');
                    rN95G(si,b)=prctile(rNullG(:,b),95);            % per-subject significance threshold
                    zGT(si,b)=(rGT(si,b)-mean(rNullG(:,b),'omitnan'))/std(rNullG(:,b),'omitnan');
                    pPermOwn(si,b)=(sum(rNullO(:,b)>=rOwn(si,b))+1)/(nPerm+1);
                    rNullOwnMean(si,b)=mean(rNullO(:,b),'omitnan');
                    rN95O(si,b)=prctile(rNullO(:,b),95);
                    zOwn(si,b)=(rOwn(si,b)-mean(rNullO(:,b),'omitnan'))/std(rNullO(:,b),'omitnan');
                end
                allNullG(:,:,si)=rNullG; allNullO(:,:,si)=rNullO;   % keep full null for GROUP threshold
            end
            
            % (4) OWN-BASED broadband model weights (blue)
            mF=mTRFtrain(S,Rb,fs,dirTRF,tmin,tmax,lamSub(si),'method',regMethod,'verbose',0);
            wO=squeeze(mF.w); if ndims(mF.w)==3; wO=squeeze(mF.w(1,:,:)); end
            WsubOwn(si,:,:)=wO; tAxis=mF.t;
            
            fprintf('  sub %2d: lambda=%-6g GTtr=%d | broad GT=%.3f(p=%.3f) delta GT=%.3f(p=%.3f) theta GT=%.3f(p=%.3f)\n',...
                s, lamSub(si), nValidGT(si), rGT(si,1),pPerm(si,1), rGT(si,2),pPerm(si,2), rGT(si,3),pPerm(si,3));
        end
        
        % ----- group-level tests per band -----
        for b=1:nB
            vv=~isnan(rGT(:,b));
            [~,pG]=ttest(rGT(vv,b)); [~,pO]=ttest(rOwn(vv,b));
            fprintf(['[%s | %-5s] GT r=%.4f (t p=%.3g, perm<.05=%.2f) | Own r=%.4f (t p=%.3g, perm<.05=%.2f) | ',...
                'Ceil r=%.4f | median lambda=%g\n'], condName, bandNames{b}, ...
                mean(rGT(vv,b)),pG,mean(pPerm(vv,b)<0.05), mean(rOwn(vv,b)),pO,mean(pPermOwn(vv,b)<0.05), ...
                mean(rCeil(vv,b),'omitnan'), median(lamSub,'omitnan'));
        end
        
        % ---------- PLOT: grouped bars across bands (GT / Own / Ceil) ----------
        %         subplot(2,2,iicond); hold on
        %         M=[mean(rGT,1,'omitnan'); mean(rOwn,1,'omitnan'); mean(rCeil,1,'omitnan')]';  % [nB x 3]
        %         hbar=bar(M,'EdgeColor','none'); cols=[0.4 0.6 0.9;0.5 0.8 0.5;0.9 0.4 0.4];
        %         for k=1:3; hbar(k).FaceColor=cols(k,:); end
        subplot(2,2,iicond); hold on
        M=[mean(rGT,1,'omitnan'); mean(rOwn,1,'omitnan')]';  % [nB x 2]
        hbar=bar(M,'EdgeColor','none'); cols=[0.4 0.6 0.9;0.5 0.8 0.5];
        for k=1:2; hbar(k).FaceColor=cols(k,:); end
        % GROUP-level 95th-pct threshold: average each permutation across subjects, then p95.
        grpNullG=squeeze(mean(allNullG,3,'omitnan')); grpNullO=squeeze(mean(allNullO,3,'omitnan'));
        grpThrG=prctile(grpNullG,95,1); grpThrO=prctile(grpNullO,95,1);   % [1 x nB] each
        %meas={rGT,rOwn,rCeil}; thr95={grpThrG,grpThrO,[]};
        meas={rGT,rOwn}; thr95={grpThrG,grpThrO};
       hThr=[];
        for k=1:3
            % Commented as an updated Matlab needed for this
            %             xe=hbar(k).XEndPoints; v=meas{k};
            
            % Replaced with this, compatible with Matlab 2018
            nBars = numel(hbar);                 % 2
            x0    = hbar(1).XData(:)';           % group positions (1:nB unless you passed custom x)
            gw    = min(0.8, nBars/(nBars+1.5)); % total width of a group
            
            for k = 1:nBars
                xe = x0 - gw/2 + (2*k-1)*gw/(2*nBars);   % center of bar k in each group
                v  = meas{k};
                se = std(v,0,1,'omitnan')./sqrt(sum(~isnan(v),1));
                errorbar(xe, mean(v,1,'omitnan'), se, 'k', 'LineStyle','none', 'LineWidth',1);
                if ~isempty(thr95{k})
                    th = thr95{k};
                    for bb = 1:nB
                        h = plot(xe(bb)+[-0.13 0.13], [th(bb) th(bb)], '-', ...
                            'Color',[0.15 0.15 0.15], 'LineWidth',1.8);
                        ylim([-0.01 0.08])
                    end
                    hThr = h;
                end
            end
            %             se=std(v,0,1,'omitnan')./sqrt(sum(~isnan(v),1));
            %             errorbar(xe,mean(v,1,'omitnan'),se,'k','LineStyle','none','LineWidth',1);
            %             if ~isempty(thr95{k})
            %                 th=thr95{k};                             % group 95th-pct threshold per band
            %                 for bb=1:nB
            %                     h=plot(xe(bb)+[-0.13 0.13],[th(bb) th(bb)],'-','Color',[0.15 0.15 0.15],'LineWidth',1.8);
            %                 end
            %                 hThr=h;
            %             end
        end
        yline(0,'k-'); hold off; xticks(1:nB); xticklabels(bandNames);
        ylabel('Prediction r');
        %lh=[hbar(1) hbar(2) hbar(3)]; lt={'GT','Own','Ceil'};
        lh=[hbar(1) hbar(2)]; lt={'GT','Own'};
        if ~isempty(hThr); lh(end+1)=hThr; lt{end+1}='group null p95'; end
        legend(lh,lt,'Location','northwest','FontSize',8); legend boxoff
        title(sprintf('%s (n=%d)',condName,nS)); grid on
        if exist('prepExport.m','file'); run prepExport.m; end
        
        % ---------- store ----------
        RESp(iicond).cond=condName; RESp(iicond).validSubs=validSubs; RESp(iicond).bandNames={bandNames};
        RESp(iicond).rGT=rGT; RESp(iicond).rOwn=rOwn; RESp(iicond).rCeil=rCeil;
        RESp(iicond).pPerm=pPerm; RESp(iicond).zGT=zGT; RESp(iicond).rNullMean=rNullMean; RESp(iicond).rN95G=rN95G;
        RESp(iicond).pPermOwn=pPermOwn; RESp(iicond).zOwn=zOwn; RESp(iicond).rNullOwnMean=rNullOwnMean; RESp(iicond).rN95O=rN95O;
        RESp(iicond).nullType=nullType;
        RESp(iicond).grpThrG=grpThrG; RESp(iicond).grpThrO=grpThrO;   % group 95th-pct thresholds per band
        RESp(iicond).lambda=lamSub; RESp(iicond).nValidGT=nValidGT; RESp(iicond).regMethod=regMethod;
        RESp(iicond).WsubOwn=WsubOwn; RESp(iicond).tAxis=tAxis; RESp(iicond).commonLab={commonLab};
    end % iicond
    
    % ---------- PLOT: OWN-BASED broadband TRF weights, BOTH conditions overlapping ----------
    subplot(2,2,[3 4]); hold on
    condCols=[0.20 0.45 0.80; 0.85 0.33 0.10];    % clear blue, vocoded orange
    hh=gobjects(1,2); nm=cell(1,2);
    for ic=1:2
        W=RESp(ic).WsubOwn; tA=RESp(ic).tAxis; cl=RESp(ic).commonLab{1};
        cz=find(strcmpi(cl,Chan2Plot),1); if isempty(cz); cz=1; end
        w=squeeze(W(:,:,cz)); wn=w./sqrt(mean(w.^2,2,'omitnan'));
        mu=mean(wn,1,'omitnan'); se=std(wn,0,1,'omitnan')/sqrt(sum(~isnan(wn(:,1))));
        inX=tA>=plotXlim(1)&tA<=plotXlim(2); c=condCols(ic,:);
        fill([tA(inX) fliplr(tA(inX))],[mu(inX)+se(inX) fliplr(mu(inX)-se(inX))],c,'FaceAlpha',0.15,'EdgeColor','none');
        hh(ic)=plot(tA(inX),mu(inX),'Color',c,'LineWidth',1.8); nm{ic}=RESp(ic).cond;
    end
    yline(0,'-','Color',[.7 .7 .7]); xline(0,'--k'); xlim(plotXlim);
    xlabel('Latency (ms)'); ylabel('norm. a.u.');
    legend(hh,nm,'Location','best','FontSize',8); legend boxoff
    if avgElectrodes; chLbl=['ROI(' strjoin(roiElec,',') ')']; else; chLbl=Chan2Plot; end
    title(sprintf('Own-based TRF @ %s (%s, broadband)',chLbl,regMethod)); box off; hold off
    if exist('prepExport.m','file'); run prepExport.m; end
    
    % ---------- SAVE (one row per subject x band x condition) ----------
    rows={};
    for iicond=1:2
        vs=RESp(iicond).validSubs;
        for si=1:numel(vs)
            for b=1:nB
                rows(end+1,:)={RESp(iicond).cond, bandNames{b}, vs(si), ...
                    RESp(iicond).rGT(si,b),  RESp(iicond).pPerm(si,b),    RESp(iicond).zGT(si,b), ...
                    RESp(iicond).rOwn(si,b), RESp(iicond).pPermOwn(si,b), RESp(iicond).zOwn(si,b), ...
                    RESp(iicond).rCeil(si,b), RESp(iicond).lambda(si)}; %#ok<AGROW>
            end
        end
    end
    %csvName=sprintf('%sISC_NeuroLip_v3bands_%s_stim%d.csv',savePath,regMethod,iiStim);
    %writecell([{'Condition','Band','Subj','R_GT','pPerm_GT','z_GT','R_Own','pPerm_Own','z_Own','R_Ceil','Lambda'};rows],csvName,'Delimiter',',');
    save(sprintf('%sTRF_NeuroLip_v3bands_%s_stim%d.mat',savePath,regMethod,iiStim),'RESp');
    fprintf('Saved: %s\n',csvName);
end % iiStim

%% Plot TRF weights (own) + broadband r values, clear vs vocoded — combined figure

Color_clear   = [222, 161, 147] ./ 255;  % lighter red for clear
Color_vocoded = [206, 12, 12]   ./ 255;  % darker red for vocoded

figure('Position',[100,100,900,1000],'Color','white','Name','TRF + broadband r');

% ================= TOP: TRF time series =================
subplot(2,1,1); hold on
condCols = [Color_clear; Color_vocoded];
hh=gobjects(1,2); nm=cell(1,2);
for ic=1:2
    W=RESp(ic).WsubOwn; tA=RESp(ic).tAxis; cl=RESp(ic).commonLab{1};
    cz=find(strcmpi(cl,Chan2Plot),1); if isempty(cz); cz=1; end
    w=squeeze(W(:,:,cz));
    wn=w./sqrt(mean(w.^2,2,'omitnan'));
    wn=smoothdata(wn,2,'movmean',5);           % optional smoothing, drop if not wanted
    mu=mean(wn,1,'omitnan'); se=std(wn,0,1,'omitnan')/sqrt(sum(~isnan(wn(:,1))));
    inX=tA>=plotXlim(1)&tA<=plotXlim(2); c=condCols(ic,:);
    fill([tA(inX) fliplr(tA(inX))],[mu(inX)+se(inX) fliplr(mu(inX)-se(inX))],c,'FaceAlpha',0.15,'EdgeColor','none');
    hh(ic)=plot(tA(inX),mu(inX),'Color',c,'LineWidth',1.8); nm{ic}=RESp(ic).cond;
end
yline(0,'-','Color',[.7 .7 .7]); xline(0,'--k'); xlim(plotXlim);
xlabel('Latency (ms)'); ylabel('norm. a.u.');
legend(hh,nm,'Location','best','FontSize',8); legend boxoff
if avgElectrodes; chLbl=['ROI(' strjoin(roiElec,',') ')']; else; chLbl=Chan2Plot; end
title(sprintf('Own-based TRF',chLbl,regMethod)); box off; hold off

% ================= BOTTOM: broadband r values =================
subplot(2,1,2); hold on
b = 1;   % broadband index

vals = [mean(RESp(1).rGT(:,b),'omitnan'), mean(RESp(1).rOwn(:,b),'omitnan'), ...
        mean(RESp(2).rGT(:,b),'omitnan'), mean(RESp(2).rOwn(:,b),'omitnan')];

SEs  = [std(RESp(1).rGT(:,b),'omitnan')/sqrt(sum(~isnan(RESp(1).rGT(:,b)))), ...
        std(RESp(1).rOwn(:,b),'omitnan')/sqrt(sum(~isnan(RESp(1).rOwn(:,b)))), ...
        std(RESp(2).rGT(:,b),'omitnan')/sqrt(sum(~isnan(RESp(2).rGT(:,b)))), ...
        std(RESp(2).rOwn(:,b),'omitnan')/sqrt(sum(~isnan(RESp(2).rOwn(:,b))))];

x = [1 2 3.5 4.5];
cols = [Color_clear; Color_clear; Color_vocoded; Color_vocoded];

for i = 1:4
    bar(x(i), vals(i), 0.7, 'FaceColor', cols(i,:), 'FaceAlpha',0.5, 'EdgeColor','none');
end
errorbar(x, vals, SEs, 'k', 'LineStyle','none', 'LineWidth',1);

yline(0,'k-');
xlim([0.3 5.2]);
xticks(x);
xticklabels({'GT','Own','GT','Own'});
ylabel('Prediction r (broadband)');
title('Broadband prediction r: Clear vs Vocoded'); grid on
box off

h1 = bar(nan,nan,'FaceColor',cols(1,:));
h2 = bar(nan,nan,'FaceColor',cols(3,:));
legend([h1 h2], {'Clear','Vocoded'}, 'Location','northwest'); legend boxoff

% ================= apply font size to everything at once =================
set(findall(gcf,'-property','FontSize'),'FontSize',30)

% %% Plot r values for clear and vocoded, for broadband signal
% 
% b = 1;   % broadband index
% 
% M = [mean(RESp(1).rGT(:,b),'omitnan') mean(RESp(1).rOwn(:,b),'omitnan'); ...
%      mean(RESp(2).rGT(:,b),'omitnan') mean(RESp(2).rOwn(:,b),'omitnan')];
% 
% SE = [std(RESp(1).rGT(:,b),'omitnan')/sqrt(sum(~isnan(RESp(1).rGT(:,b)))), ...
%       std(RESp(1).rOwn(:,b),'omitnan')/sqrt(sum(~isnan(RESp(1).rOwn(:,b)))); ...
%       std(RESp(2).rGT(:,b),'omitnan')/sqrt(sum(~isnan(RESp(2).rGT(:,b)))), ...
%       std(RESp(2).rOwn(:,b),'omitnan')/sqrt(sum(~isnan(RESp(2).rOwn(:,b))))];
% 
% figure('Position',[100,100,900,700],'Color','white','Name','Broadband r values');
% hbar = bar(M,'EdgeColor','none');
% cols = [0.4 0.6 0.9; 0.5 0.8 0.5];
% for k=1:2; hbar(k).FaceColor = cols(k,:); end
% hold on
% 
% nBars = numel(hbar);
% x0 = hbar(1).XData(:)';
% gw = min(0.8, nBars/(nBars+1.5));
% for k = 1:nBars
%     xe = x0 - gw/2 + (2*k-1)*gw/(2*nBars);
%     errorbar(xe, M(:,k), SE(:,k), 'k', 'LineStyle','none', 'LineWidth',1);
% end
% 
% yline(0,'k-'); hold off
% xticks(1:2); xticklabels({'Clear','Vocoded'});
% ylabel('Prediction r (broadband)');
% legend(hbar,{'GT','Own'},'Location','northwest'); legend boxoff
% title('Broadband prediction r: Clear vs Vocoded'); grid on
% 
% % apply font size 30 everywhere at once: title, labels, legend, x/y ticks
% set(findall(gcf,'-property','FontSize'),'FontSize',30)

%% Plot individual TRF responses

for ic = 1:2
    
    figure('Position',[100 100 1100 700],'Color','white');
    hold on;
    
    W = RESp(ic).WsubOwn;
    tA = RESp(ic).tAxis;
    validSubs = RESp(ic).validSubs;
    
    w = squeeze(W(:,:,1));
    
    % Same normalization as group plot
    wn = w ./ sqrt(mean(w.^2,2,'omitnan'));
    
    for si = 1:size(wn,1)
        
        plot(tA, wn(si,:), ...
            'LineWidth',0.8, 'color', [0.5 0.5 0.5]);
        
    end
    
    xline(0,'--k');
    yline(0,'Color',[0.7 0.7 0.7]);
    
    xlim([-50 350]);
    
    xlabel('Latency (ms)');
    ylabel('Normalised TRF weight');
    
    title(sprintf('%s — individual TRFs around 0 ms', ...
        RESp(ic).cond));
    
    box off;
end

%% Obtain an array with ID and the r values per condition
% Subject IDs
ids_clear   = RESp(1).validSubs;
ids_vocoded = RESp(2).validSubs;

% Get common valid subjects
commonSubs = intersect(ids_clear, ids_vocoded);

% Find their positions in each condition
[~, idx_clear]   = ismember(commonSubs, ids_clear);
[~, idx_vocoded] = ismember(commonSubs, ids_vocoded);

% Create table
r_table = table();

r_table.ID = {selection{commonSubs(:)}}';

r_table.r_Clear = RESp(1).rGT(idx_clear, 1);
r_table.r_Vocoded = RESp(2).rGT(idx_vocoded, 1);


writetable(r_table, fullfile('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/EEG/r_values.csv'));


%functions
function lam = local_pickLambda(rl, lambdas, tolPct, useTol)
if useTol
    [rmax,imax]=max(rl); thr=rmax-tolPct*abs(rmax);
    bi=find(rl>=thr,1,'first'); if isempty(bi); bi=imax; end   % smallest within tolerance
else
    [~,bi]=max(rl);
end
lam=lambdas(bi);
end

function lam = tune_lambda_gt(S,Rb,gtb0,trn,fs,dirTRF,tmin,tmax,lambdas,regMethod,pickLambda)
% Nested lambda tuning by the GT criterion: inner leave-one-out over the TRAINING trials.
% For each lambda, train stim->own on trn\{j} and predict trial j's GROUP GT; pick the
% lambda maximising GT prediction. Using only training trials keeps the outer GT bar unbiased.
trnGT = trn(~cellfun(@isempty, gtb0(trn)));
if numel(trnGT) < 3; lam = lambdas(max(1,ceil(numel(lambdas)/2))); return; end   % fallback: mid-grid
rL = nan(1,numel(lambdas));
for li = 1:numel(lambdas)
    rr = nan(1,numel(trnGT)); c = 0;
    for j = trnGT
        inTr = setdiff(trn, j);
        mm = mTRFtrain(S(inTr), Rb(inTr), fs, dirTRF, tmin, tmax, lambdas(li), 'method', regMethod, 'verbose',0);
        Lj = size(gtb0{j},1);
        [pj,~] = mTRFpredict({S{j}(1:Lj,:)}, {gtb0{j}}, mm, 'verbose',0);
        if iscell(pj); pj = pj{1}; end
        Lp = size(pj,1); g = gtb0{j}(1:Lp,:);
        c = c+1; rr(c) = mean(diag(corr(pj, g)),'omitnan');   % mean over channels
    end
    rL(li) = mean(rr,'omitnan');
end
lam = pickLambda(rL);
end

function y = local_bp(x, lo, hi, fs)
% zero-phase band-pass; columns = channels
ny=fs/2;
if lo<=0
    [b,a]=butter(3, hi/ny);
elseif hi>=ny
    [b,a]=butter(3, lo/ny, 'high');
else
    [b,a]=butter(3, [lo hi]/ny, 'bandpass');
end
y=filtfilt(b,a,x);
end