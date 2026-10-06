function [data_preprocessed, trial_quality_table] = ...
    preprocessing_EEG(data_combined, participant, theoretical_triggers, theoretical_cond)

%% ================================================================
% EEG PREPROCESSING
% ================================================================

% %% Separate EEG and audio before filtering
% % EEG: band-pass 1-8 Hz, Butterworth order 2
cfg_eeg = [];
cfg_eeg.channel     = setdiff(data_combined.label, {'Audio'});
cfg_eeg.hpfilter    = 'yes';
cfg_eeg.hpfreq      = 1;
cfg_eeg.hpfilttype  = 'but';
cfg_eeg.hpfiltord   = 2;
cfg_eeg.hpfiltdir   = 'twopass';    % forward+backward = zero phase
cfg_eeg.lpfilter    = 'yes';
cfg_eeg.lpfreq      = 8;
cfg_eeg.lpfilttype  = 'but';
cfg_eeg.lpfiltord   = 2;
cfg_eeg.lpfiltdir   = 'twopass';
%cfg_eeg.plotfiltresp = 'yes';       % plots the filter response so you can check it

filtered_eeg = ft_preprocessing(cfg_eeg, data_combined);

% Audio: low-pass at 8 Hz, same filter
cfg_audio = [];
cfg_audio.channel      = {'Audio'};
% cfg_audio.lpfilter     = 'yes';
% cfg_audio.lpfreq       = 8;
% cfg_audio.lpfilttype   = 'but';
% cfg_audio.lpfiltord    = 1;
% cfg_audio.lpfiltdir    = 'twopass';
% %cfg_audio.plotfiltresp = 'yes';

filtered_audio = ft_preprocessing(cfg_audio, data_combined);
%Merge EEG and audio
filtered_data = ft_appenddata([], filtered_eeg, filtered_audio);

%% ================================================================
% FILTER EEG
% EEG: zero-phase Butterworth band-pass 0.5-8 Hz
% Audio envelope: already extracted and filtered during
% stimulus preprocessing, so it is not filtered again here
% ================================================================
% 
% fs = data_combined.fsample;
% 
% % EEG band-pass: 0.5-8 Hz
% %[zH,pH,kH] = butter(2, 0.5/(fs/2), 'high');
% %[sosH,gH] = zp2sos(zH,pH,kH);
% 
% [zL,pL,kL] = butter(2, 20/(fs/2), 'low');
% [sosL,gL] = zp2sos(zL,pL,kL);
% 
% sosBP = [sosH; sosL];
% gBP = gH * gL;
% 
% filtered_data = data_combined;
% 
% for k = 1:numel(data_combined.trial)
% 
%     x = data_combined.trial{k};
% 
%     % ------------------------------------------------------------
%     % EEG: channels 1-6
%     % ------------------------------------------------------------
%     eeg_data = x(1:6,:);
% 
%     filtered_data.trial{k}(1:6,:) = ...
%         filtfilt(sosBP, gBP, eeg_data')';
% 
%     % ------------------------------------------------------------
%     % Channel 7 = speech envelope
%     % Leave unchanged
%     % ------------------------------------------------------------
%     filtered_data.trial{k}(7,:) = x(7,:);
% 
%     % ------------------------------------------------------------
%     % Channel 8 = original audio
%     % Leave unchanged
%     % ------------------------------------------------------------
%     filtered_data.trial{k}(8,:) = x(8,:);
% 
% end

% [b,a] = butter(2,20/(fs/2),'low');
%                     env = filtfilt(b,a,env);


%% ================================================================
% RESAMPLE TO 200 Hz
% ================================================================

cfg = [];
cfg.resamplefs = 200;
cfg.detrend    = 'no';

data_resampled = ft_resampledata(cfg, filtered_data);


%% ================================================================
% RECONSTRUCT SAMPLEINFO AFTER RESAMPLING
% ================================================================

n_trials = length(data_resampled.trial);

sampleinfo = zeros(n_trials, 2);

sample_start = 1;

for tr = 1:n_trials

    n_samples = length(data_resampled.time{tr});

    sample_end = sample_start + n_samples - 1;

    sampleinfo(tr,:) = [sample_start sample_end];

    sample_start = sample_end + 1;

end

data_resampled.sampleinfo = sampleinfo;


%% ================================================================
% AUTOMATIC EEG ARTIFACT DETECTION
% ================================================================

% Channels used for amplitude-based artifact detection
eeg_channels = {'F1','Fz','F2','C1','Cz','C2'};

% Keep only channels that actually exist in the dataset
[~, eeg_idx] = ismember(eeg_channels, data_resampled.label);
eeg_idx = eeg_idx(eeg_idx > 0);

eeg_channels_present = data_resampled.label(eeg_idx);


% Detect periods exceeding +/-120 uV
cfg = [];
cfg.channel = eeg_channels_present;

cfg.artfctdef.threshold.channel = eeg_channels_present;
cfg.artfctdef.threshold.min = -120;
cfg.artfctdef.threshold.max = 120;

[~, artifact] = ft_artifact_threshold(cfg, data_resampled);


%% ================================================================
% IDENTIFY TRIALS CONTAINING AN ARTIFACT
% ================================================================

noisy_trials_automatique = [];

for tr = 1:n_trials

    trial_start = data_resampled.sampleinfo(tr,1);
    trial_end   = data_resampled.sampleinfo(tr,2);

    for a = 1:size(artifact,1)

        artifact_start = artifact(a,1);
        artifact_end   = artifact(a,2);

        % Check whether artifact overlaps with this trial
        if artifact_start <= trial_end && artifact_end >= trial_start

            noisy_trials_automatique(end+1) = tr;
            break

        end

    end

end

% Remove duplicates
noisy_trials_automatique = unique(noisy_trials_automatique);


%% ================================================================
% TRIAL-LEVEL EEG QUALITY METRICS
% ================================================================

trial_max_abs        = nan(n_trials,1);
trial_pct_over_120   = nan(n_trials,1);
trial_rms            = nan(n_trials,1);
trial_ptp            = nan(n_trials,1);
trial_n_bad_channels = zeros(n_trials,1);

for tr = 1:n_trials

    % EEG data for this trial
    x = data_resampled.trial{tr}(eeg_idx,:);

    % Samples exceeding +/-120 uV
    over_threshold = abs(x) > 120;

    % Maximum absolute amplitude
    trial_max_abs(tr) = max(abs(x(:)));

    % Percentage of samples exceeding +/-120 uV
    trial_pct_over_120(tr) = ...
        100 * sum(over_threshold(:)) / numel(x);

    % RMS amplitude
    trial_rms(tr) = sqrt(mean(x(:).^2));

    % Peak-to-peak amplitude
    trial_ptp(tr) = max(x(:)) - min(x(:));

    % Number of EEG channels with at least one
    % sample exceeding +/-120 uV
    channel_has_artifact = any(over_threshold, 2);

    trial_n_bad_channels(tr) = sum(channel_has_artifact);

end


%% ================================================================
% STORE TRIAL QUALITY INFORMATION IN DATA STRUCTURE
% ================================================================

automatic_bad = false(n_trials,1);

automatic_bad(noisy_trials_automatique) = true;

data_resampled.trial_quality.max_abs_uV = trial_max_abs;

data_resampled.trial_quality.pct_over_120 = ...
    trial_pct_over_120;

data_resampled.trial_quality.rms = ...
    trial_rms;

data_resampled.trial_quality.peak_to_peak = ...
    trial_ptp;

data_resampled.trial_quality.n_bad_channels = ...
    trial_n_bad_channels;

data_resampled.trial_quality.automatic_bad = ...
    automatic_bad;


%% ================================================================
% KEEP PREVIOUS NOISY-TRIAL FORMAT
% ================================================================

noisy_trials = zeros(n_trials,2);

noisy_trials(:,1) = (1:n_trials)';

noisy_trials(noisy_trials_automatique,2) = 1;

data_resampled.noisy_trials = noisy_trials;


%% ================================================================
% CREATE TRIAL QUALITY TABLE
% ================================================================

trial_quality_table = table( ...
    repmat({participant}, n_trials, 1), ...
    (1:n_trials)', ...
    trial_max_abs, ...
    trial_pct_over_120, ...
    trial_rms, ...
    trial_ptp, ...
    trial_n_bad_channels, ...
    automatic_bad, ...
    'VariableNames', { ...
    'Participant', ...
    'Trial', ...
    'MaxAbs_uV', ...
    'PctOver120', ...
    'RMS', ...
    'PeakToPeak', ...
    'NBadChannels', ...
    'AutomaticBad'});


%% ================================================================
% CHANNEL REJECTION
% ================================================================

channels = data_resampled.label;
nchan = length(channels);

chan_var  = zeros(nchan,1);
chan_kurt = zeros(nchan,1);


% Concatenate all trials once
all_data = cat(2, data_resampled.trial{:});


for ch = 1:nchan

    chan_var(ch)  = var(all_data(ch,:));
    chan_kurt(ch) = kurtosis(all_data(ch,:));

end


%% Identify channels with unusual variance

median_var = median(chan_var);
mad_var    = mad(chan_var,1);

bad_var = ...
    (chan_var < median_var - 3*mad_var) | ...
    (chan_var > median_var + 3*mad_var);


%% Identify channels with unusual kurtosis

median_kurt = median(chan_kurt);
mad_kurt    = mad(chan_kurt,1);

bad_kurt = ...
    (chan_kurt < median_kurt - 3*mad_kurt) | ...
    (chan_kurt > median_kurt + 3*mad_kurt);


%% Combine channel rejection criteria

bad_channels_logical = bad_var | bad_kurt;

bad_channels = channels(bad_channels_logical);


% Never remove Audio based on EEG quality criteria
bad_channels(strcmp(bad_channels,'Audio')) = [];


%% ================================================================
% REMOVE BAD CHANNELS
% ================================================================

good_channels = setdiff(channels, bad_channels);

cfg = [];
cfg.channel = good_channels;

data_preprocessed = ft_selectdata(cfg, data_resampled);


%% ================================================================
% CARRY INFORMATION INTO FINAL DATASET
% ================================================================

data_preprocessed.bad_channels = bad_channels;

data_preprocessed.cond = data_combined.cond;

data_preprocessed.monologue = data_combined.monologue;

% Keep trial quality information
data_preprocessed.trial_quality = data_resampled.trial_quality;

data_preprocessed.noisy_trials = data_resampled.noisy_trials;


end