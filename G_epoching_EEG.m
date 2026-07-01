function [data_epoched, data_epoched_raw_clean] = epoching_EEG(data_preprocessed, theoretical_triggers, theoretical_cond)

% Determinar la longitud mínima de los trials (en segundos)
fs = data_preprocessed.fsample;
fixLength = min(cellfun(@(x) size(x,2), data_preprocessed.trial));
maxEpochLength = fixLength / fs;

% Crear campo sampleinfo si no existe
n_trials = length(data_preprocessed.trial);
data_preprocessed.sampleinfo = zeros(n_trials, 2);
for i = 1:n_trials
    data_preprocessed.sampleinfo(i,:) = [1, size(data_preprocessed.trial{i},2)];
end

% Epocar en ventanas de 4 segundos basadas en umbral de actividad de audio
epochLength = 4;
threshold = 0.01;
[data_epoched, plotting_info, audioOnsets] = epoch_within_trials(data_preprocessed, epochLength, threshold, theoretical_triggers, theoretical_cond);
data_epoched.label = data_preprocessed.label;
data_epoched.cfg = [];

%% FIX 1: rebuild sampleinfo AFTER epoching
sampleinfo = zeros(length(data_epoched.trial), 2);
current_sample = 1;

for i = 1:length(data_epoched.trial)
    nsamples = size(data_epoched.trial{i}, 2);
    sampleinfo(i,:) = [current_sample, current_sample + nsamples - 1];
    current_sample = current_sample + nsamples;
end
data_epoched.sampleinfo = sampleinfo;


%% ===================== BAD EPOCH DETECTION =====================

%  FIX 2: use direct thresholding per epoch (robust)
threshold = 250;   % <-- adjust if your data are scaled differently

noisy_epochs = false(length(data_epoched.trial),1);

for i = 1:length(data_epoched.trial)

    trial_data = data_epoched.trial{i};

    % Remove Audio channel
    idx = ~strcmp(data_epoched.label, 'Audio');
    trial_data = trial_data(idx,:);

    % Check amplitude threshold
    if any(abs(trial_data(:)) > threshold)
        noisy_epochs(i) = true;
    end
end

bad_epochs = find(noisy_epochs);

%% ===================== REMOVE BAD EPOCHS =====================

data_epoched_raw_clean = data_epoched;
data_epoched_raw_clean.trial(bad_epochs) = [];
data_epoched_raw_clean.time(bad_epochs) = [];
data_epoched_raw_clean.bad_epochs = bad_epochs;
data_epoched_raw_clean.bad_channels = data_preprocessed.bad_channels;
data_epoched_raw_clean.trialinfo(:, bad_epochs) = [];
data_epoched_raw_clean.cond = data_preprocessed.cond;
data_epoched_raw_clean.monologue = data_preprocessed.monologue;

if size(theoretical_triggers, 1) > 1
    theoretical_triggers = theoretical_triggers';
end
if size(theoretical_cond, 1) > 1
    theoretical_cond = theoretical_cond';
end
%data_epoched_raw_clean.trialinfo = data_clean.trialinfo;
%data_epoched_raw_clean.trialinfo(2, :) = theoretical_cond;