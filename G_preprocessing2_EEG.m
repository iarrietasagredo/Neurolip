function [data_preprocessed, data_epoched_raw_clean] = preprocessing_EEG(data_combined, n_sub, theoretical_triggers, theoretical_cond)

%% Apply filtering
% cfg = [];
% cfg.hpfilter = 'yes';
% cfg.hpfreq   = 1;
% cfg.hpfilttype = 'firws';
% 
% cfg.lpfilter = 'yes';
% cfg.lpfreq = 20;
% cfg.lpfilttype = 'firws';
% 
% cfg.dftfilter = 'yes';
% %cfg.dftfreq = [50 100];
% filtered_data = ft_preprocessing(cfg, data_combined);
% 

% In preprocessing2_EEG, separate audio before filtering
cfg_eeg = [];
cfg_eeg.channel = setdiff(data_combined.label, {'Audio'});
cfg_eeg.hpfilter = 'yes';  cfg_eeg.hpfreq = 1; cfg_eeg.hpfilttype = 'firws';
cfg_eeg.lpfilter = 'yes';  cfg_eeg.lpfreq = 8; cfg_eeg.lpfilttype = 'firws';
filtered_eeg = ft_preprocessing(cfg_eeg, data_combined);

cfg_audio = [];
cfg_audio.channel = {'Audio'};
cfg_audio.lpfilter = 'yes';  cfg_audio.lpfreq = 8; cfg_audio.lpfilttype = 'firws';
filtered_audio = ft_preprocessing(cfg_audio, data_combined);

% Then merge back
filtered_data = ft_appenddata([], filtered_eeg, filtered_audio);

%% Detrend  - i did not apply it as Chatty says may introduce artefacts, that diltering above 1 Hz enough.
%cfg = [];
%cfg.detrend    = 'yes';
%cfg.demean     = 'yes';
%dataEEG_detrend = ft_preprocessing(cfg, filtered_data);

%% Resample to 200 Hz
cfg = [];
cfg.resamplefs = 200;     % target sampling rate in Hz
cfg.detrend     = 'no';   % avoid introducing trends during resampling
data_resampled = ft_resampledata(cfg, filtered_data);

%% If sampleinfo is missing after resampling: NEEDED???????????????
%You can recalculate it using the new sampling rate:

fs_old = filtered_data.fsample;
fs_new = data_resampled.fsample;

sampleinfo = zeros(length(data_resampled.trial), 2);
sample_start = 1;

for i = 1:length(data_resampled.trial)
    nsamples = length(data_resampled.time{i});
    sample_end = sample_start + nsamples - 1;
    sampleinfo(i,:) = [sample_start sample_end];
    sample_start = sample_end + 1;
end

data_resampled.sampleinfo = sampleinfo;

%% Mark as noisy if above or below a certain mV, needed if epoching?????????????????????
cfg = [];
cfg.channel = ft_channelselection({'all', '-Aux1'}, data_resampled.label);
cfg.artfctdef.threshold.channel = {'F1', 'Fz', 'F2', 'C1', 'Cz', 'C2'};    % or {'EEG001', ...}
cfg.artfctdef.threshold.min = -120;
cfg.artfctdef.threshold.max = 120;

[a, artifact] = ft_artifact_threshold(cfg, data_resampled);

% TO visualise the quality - uncomment!
%                 cfg.viewmode = 'vertical';  % or 'butterfly', 'component'
%                 cfg.artfctdef.threshold.artifact = artifact;
%                 ft_databrowser(cfg, data_resampled);

noisy_trials_automatique = [];
               
for i = 1:length(data_resampled.trial)
    trial_range = data_resampled.sampleinfo(i,1):data_resampled.sampleinfo(i,2);

    % Check if any artifact overlaps with the current trial
    for j = 1:size(artifact, 1)
        artifact_range = artifact(j,1):artifact(j,2);
        if ~isempty(intersect(trial_range, artifact_range))
            noisy_trials_automatique(end+1) = i;
            break;  % move to next trial after finding overlap
        end
    end
end

noisy_trials_automatique = unique(noisy_trials_automatique)  % avoid duplicates
noisy_trials = zeros(length(data_resampled.trial), 2);
noisy_trials(:, 1) = 1:length(data_resampled.trial);
noisy_trials(noisy_trials_automatique, 2) = 1;
data_resampled.noisy_trials = noisy_trials;


%% ===================== CHANNEL REJECTION =====================
% Calcular varianza y curtosis por canal para identificar canales ruidosos
channels = data_resampled.label;
nchan = length(channels);
chan_var = zeros(nchan,1);
chan_kurt = zeros(nchan,1);
for ch = 1:nchan
    all_data = cat(2, data_resampled.trial{:});
    chan_var(ch) = var(all_data(ch,:));
    chan_kurt(ch) = kurtosis(all_data(ch,:));
end

median_var = median(chan_var);
mad_var = mad(chan_var,1);
bad_var = (chan_var < median_var - 3*mad_var) | (chan_var > median_var + 3*mad_var);

median_kurt = median(chan_kurt);
mad_kurt = mad(chan_kurt,1);
bad_kurt = (chan_kurt < median_kurt - 3*mad_kurt) | (chan_kurt > median_kurt + 3*mad_kurt);

bad_channels_logical = bad_var | bad_kurt;
bad_channels = channels(bad_channels_logical);

% Evitar eliminar el canal de audio
bad_channels(strcmp(bad_channels, 'Audio')) = [];
%bad_channels = [];
%Eliminar canales ruidosos

good_channels = setdiff(channels, bad_channels);
[~, idx_good] = ismember(good_channels, data_resampled.label);
idx_good = idx_good(idx_good > 0); % Elimina ceros por si acaso
[a, b] = sort(idx_good);
good_channels(b) = good_channels;

cfg = [];
cfg.channel = good_channels
data_preprocessed = ft_selectdata(cfg, data_resampled);
data_preprocessed.bad_channels = bad_channels;
data_preprocessed.cond = data_combined.cond;
data_preprocessed.monologue = data_combined.monologue;
%data_clean.trialinfo = data_resampled.trialinfo;

% Comparar señal de audio antes y después de limpiar
% audio_clean = data_clean.trial{7};
% audio_clean = audio_clean(end, :);
% audio_noclean = data_epoched.trial{7};
% audio_noclean = audio_noclean(end, :);
% figure; hold on;
% plot(audio_clean);
% plot(audio_noclean);
% legend({'Audio Clean','Audio Original'});

% Detección automática de epochs ruidosos usando umbral de amplitud
% cfg = [];
% cfg.channel = 'all';
% cfg.artfctdef.threshold.channel = setdiff(data_clean.label, 'Audio');
% cfg.artfctdef.threshold.min = -2;
% cfg.artfctdef.threshold.max = 2;
% [~, artifact] = ft_artifact_threshold(cfg, data_clean);
%
% % Visualizar en databrowser con audio escalado
% scaleFactor = 1000;
% data_clean_amp = data_clean;
% for tr = 1:length(data_clean.trial)
%     idx_audio = find(strcmp(data_clean_amp.label, 'Audio'));
%     data_clean_amp.trial{tr}(idx_audio,:) = data_clean_amp.trial{tr}(idx_audio,:) * scaleFactor;
% end
% cfg.viewmode = 'vertical';
% cfg.artfctdef.threshold.artifact = artifact;
% ft_databrowser(cfg, data_clean_amp);
%
% % Marcar epochs ruidosos
% noisy_epochs = zeros(length(data_clean.trial),1);
% for i = 1:length(data_clean.trial)
%     trial_range = data_clean.sampleinfo(i,1):data_clean.sampleinfo(i,2);
%     for j = 1:size(artifact,1)
%         artifact_range = artifact(j,1):artifact(j,2);
%         if ~isempty(intersect(trial_range, artifact_range))
%             noisy_epochs(i) = 1;
%             break;
%         end
%     end
% end
%
% % Eliminar epochs ruidosos
% bad_epochs = find(noisy_epochs);
% data_epoched_raw_clean = data_clean;
% data_epoched_raw_clean.trial(bad_epochs) = [];
% data_epoched_raw_clean.time(bad_epochs) = [];


end