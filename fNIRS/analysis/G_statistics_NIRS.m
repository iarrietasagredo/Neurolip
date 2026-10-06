% statistics fNIRS
clc; clear all;close all;
set(0,'DefaultFigureVisible','on')
path_data =  '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data';
addpath(genpath(path_data));
path_data_preprocessed =  '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data_preprocessed/fNIRS',
addpath(genpath(path_data_preprocessed));


cd(path_data_preprocessed)
% participants = load('NIRS_participants_07_09_2026.mat');
% participants = participants.participants;
participants = dir(fullfile(path_data_preprocessed, 'clean*'))


% n = 21 excellent
selection_excellent = {'NLP03','NLP08','NLP09',...
   'NLP11','NLP13','NLP14','NLP15','NLP17','NLP19','NLP20',...
    'NLP21','NLP22','NLP23','NLP25','NLP27','NLP31',...
    'NLP33', 'NLP35', 'NLP37', 'NLP39', 'NLP45'}; 
selection = selection_excellent;

% I will compare for each channel, AUC for both clear and vocoded conditions

HbO = zeros(length(selection)*14, 5); % Structure being each row one subject by condition (for HbO), ...
% each column informs on the condition, channel source, channel detector and AUC 
HbR = zeros(length(selection)*14, 5); % Structure being each row one subject by condition (for HbO), ...

names_types = {}

% For each subject and channel, I averaged all the trials of the same
% condition.
cntHBO = 1;
cntHBR = 1;
channel_numbers = repelem(1:14, 2);
cnt_names = 1;
for kk = 1:length(participants)
    %epoched_conc_OD = participants{kk};
    participants_single = load([path_data_preprocessed '/' participants(kk).name])
    epoched_conc_OD = participants_single.epoched_conc_OD;
    subj_id = participants(kk).name;
    subj_id = subj_id(end-8:end-4);
    if ismember(subj_id, selection)
        for chn = 1:size(epoched_conc_OD.data, 2) % only HbO
            % Structure inside auxillary is: time, epochs, condition,
            % channel (being the first HbO and sequentially next HbR)
            ch_tmp_clear = nanmean(epoched_conc_OD.auxillary.values{1, 1}.data(:, :, 1, chn), 2);
            %figure;plot(ch_tmp_clear)
            AUC_tmp_clear = trapz([1:length(ch_tmp_clear)], ch_tmp_clear);
            names_types{cnt_names, 1} = subj_id;
            %names_types{cnt_names+1, 1} = subj_id;
            %names_types{cnt_names, 2} = epoched_conc_OD.probe.link.type(chn);

            if strcmp(epoched_conc_OD.probe.link.type(chn), 'hbo')
                
                HbO(cntHBO, 2) = 1;
                HbO(cntHBO, 3) = epoched_conc_OD.probe.link.source(chn);
                HbO(cntHBO, 4) = epoched_conc_OD.probe.link.detector(chn);
                HbO(cntHBO, 5) = AUC_tmp_clear;
                cntHBO = cntHBO + 1;
                cnt_names = cnt_names + 1;
            else   
            
                 HbR(cntHBR, 2) = 1;
                 HbR(cntHBR, 3) = epoched_conc_OD.probe.link.source(chn);
                 HbR(cntHBR, 4) = epoched_conc_OD.probe.link.detector(chn);
                 HbR(cntHBR, 5) = AUC_tmp_clear;
                 cntHBR = cntHBR +1
            end
            
            ch_tmp_vocoded = nanmean(epoched_conc_OD.auxillary.values{1, 1}.data(:, :, 2, chn), 2)
            %figure;plot(ch_tmp_clear)
            AUC_tmp_vocoded = trapz([1:length(ch_tmp_vocoded)], ch_tmp_vocoded);
            
            if strcmp(epoched_conc_OD.probe.link.type(chn), 'hbo')
                
                HbO(cntHBO, 2) = 2;
                HbO(cntHBO, 3) = epoched_conc_OD.probe.link.source(chn);
                HbO(cntHBO, 4) = epoched_conc_OD.probe.link.detector(chn);
                HbO(cntHBO, 5) = AUC_tmp_vocoded;
                cntHBO = cntHBO + 1;
                cnt_names = cnt_names + 1;
            else   
            
                 HbR(cntHBR, 2) = 2;
                 HbR(cntHBR, 3) = epoched_conc_OD.probe.link.source(chn);
                 HbR(cntHBR, 4) = epoched_conc_OD.probe.link.detector(chn);
                 HbR(cntHBR, 5) = AUC_tmp_vocoded;
                 cntHBR = cntHBR +1
            end
            
        end
        HbO(cntHBO-28:cntHBO-1, 1) = channel_numbers;
        HbR(cntHBR-28:cntHBR-1, 1) = channel_numbers;
    end
    
end
for i = 2:length(names_types)
    if isempty(names_types{i})
        names_types{i} = names_types{i-1};
    end
end
names_types(end) =  [];
% Create master file

HBOT = table();
HBOT.subjID    = categorical(names_types(:,1)); % ID
HBOT.condition = categorical(HbO(:,2)); % Condition
HBOT.channel   = categorical(HbO(:,1)); % Channel
HBOT.AUC       = double(HbO(:,5)); % AUC

HBRT = table();
HBRT.subjID    = categorical(names_types(:,1)); % ID
HBRT.condition = categorical(HbR(:,2)); % Condition
HBRT.channel   = categorical(HbR(:,1)); % Channel
HBRT.AUC       = double(HbR(:,5)); % AUC


writetable(HBOT, '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/NIRS/HbO_AUC.csv');
writetable(HBRT, '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/NIRS/HbR_AUC.csv');

%% Test for HbO, for each channel, whether the condition makes a difference in the AUC

%HBOT = readtable('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/NIRS/HbO_AUC.csv');
%HBRT = readtable('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/NIRS/HbO_AUC.csv');
channels = unique(HBOT.channel);
pvals = zeros(numel(channels),1);

for i = 1:numel(channels)

    idx = HBOT.channel == channels(i);

    Tch = HBOT(idx, :);   % <-- THIS is enough (no struct building)
    unique(Tch.condition)
    lme = fitlme(Tch, ...
        'AUC ~ condition + (1|subjID)');
    %disp(lme)
     pvals(i) = lme.Coefficients.pValue(strcmp(lme.Coefficients.Name,'condition_2'));
end

 pvals
 % pvals contains the p-values for each clear-vocoded comparison per channel
 find(pvals<0.05)
  % As I separated the HbO from HbR, the channels 1 and 2 correspond to 
 % source detector pairs: {1,1} and {2,1}

% FDR correction
% pvals = vector of raw p-values

[p_sorted, sort_idx] = sort(pvals);

m = length(pvals);                 % number of tests
fdr_vals = (1:m)'/m * 0.05;        % BH thresholds

% Find significant tests
below = p_sorted <= fdr_vals;

if any(below)
    max_idx = find(below, 1, 'last');
    crit_p = p_sorted(max_idx);
else
    crit_p = 0;
end

% Significant channels after FDR
sig = pvals <= crit_p;
 
find(sig)

% The channels did not survive the correction for multiple comparisons


%% Test for HbR, for each channel, whether the condition makes a difference in the AUC
channels = unique(HBRT.channel);
pvals = zeros(numel(channels),1);

for i = 1:numel(channels)

    idx = HBRT.channel == channels(i);

    Tch = HBRT(idx, :);   % <-- THIS is enough (no struct building)
    unique(Tch.condition)
    lme = fitlme(Tch, ...
        'AUC ~ condition + (1|subjID)');
    %disp(lme)
     pvals(i) = lme.Coefficients.pValue(strcmp(lme.Coefficients.Name,'condition_2'));
end

 pvals
 % pvals contains the p-values for each clear-vocoded comparison per channel
 find(pvals<0.05)
  % As I separated the HbO from HbR, the channels 1 and 2 correspond to 
 % source detector pairs: {1,1} and {2,1}

% FDR correction
% pvals = vector of raw p-values

[p_sorted, sort_idx] = sort(pvals);

m = length(pvals);                 % number of tests
fdr_vals = (1:m)'/m * 0.05;        % BH thresholds

% Find significant tests
below = p_sorted <= fdr_vals;

if any(below)
    max_idx = find(below, 1, 'last');
    crit_p = p_sorted(max_idx);
else
    crit_p = 0;
end

% Significant channels after FDR
sig = pvals <= crit_p;
 
find(sig)

% The channels did not survive the correction for multiple comparisons


