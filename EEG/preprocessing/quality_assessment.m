function quality_assessment(fig_yes)
if fig_yes ==1
    set(0,'DefaultFigureVisible','on')
else
    set(0,'DefaultFigureVisible','off')
end
%% Quality assessment -- run until the end!

set(0,'DefaultFigureVisible','on')

path_data_preprocessed = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed';
addpath(genpath(path_data_preprocessed));

files = dir(fullfile(path_data_preprocessed, 'not_epoched_prep*'));

% ============================================================
% BUILD TRIAL-LEVEL QUALITY TABLE
% ============================================================

all_trial_quality = table();

for i = 1:length(files)

    participant = load(files(i).name);
    participant = participant.data_preprocessed;
    S = participant.trial_quality;

    n_trials = length(S.max_abs_uV);

    T = table( ...
        repmat({files(i).name}, n_trials, 1), ...
        (1:n_trials)', ...
        S.max_abs_uV(:), ...
        S.pct_over_120(:), ...
        S.rms(:), ...
        S.peak_to_peak(:), ...
        S.n_bad_channels(:), ...
        'VariableNames', { ...
        'Participant', 'Trial', 'MaxAbs_uV', 'PctOver120', ...
        'RMS', 'PeakToPeak', 'NBadChannels'});

    all_trial_quality = [all_trial_quality; T];

end

all_trial_quality = sortrows(all_trial_quality, {'Participant','Trial'});

disp(all_trial_quality);
fprintf('\nTotal participants: %d\n', numel(unique(all_trial_quality.Participant)));
fprintf('Total trials: %d\n', height(all_trial_quality));

% ============================================================
% TRIAL-LEVEL EEG QUALITY CONTROL (objective criteria)
% ============================================================

max_pct_over120   = 1;     % % of samples
max_bad_channels  = 2;     % channels
max_abs_uV        = 500;   % uV
max_rms           = 100;   % uV
max_ptp           = 1000;  % uV

flag_pct       = all_trial_quality.PctOver120 > max_pct_over120;
flag_channels  = all_trial_quality.NBadChannels > max_bad_channels;
flag_amplitude = all_trial_quality.MaxAbs_uV > max_abs_uV;
flag_rms       = all_trial_quality.RMS > max_rms;
flag_ptp       = all_trial_quality.PeakToPeak > max_ptp;

all_trial_quality.QC_bad = flag_pct | flag_channels | flag_amplitude | flag_rms | flag_ptp;

all_trial_quality.QC_reason = strings(height(all_trial_quality),1);

for i = 1:height(all_trial_quality)

    reasons = strings(0,1);
    if flag_pct(i),       reasons(end+1) = "PctOver120";    end
    if flag_channels(i),  reasons(end+1) = "NBadChannels";  end
    if flag_amplitude(i), reasons(end+1) = "MaxAbs";        end
    if flag_rms(i),       reasons(end+1) = "RMS";           end
    if flag_ptp(i),       reasons(end+1) = "PeakToPeak";    end

    if ~isempty(reasons)
        all_trial_quality.QC_reason(i) = strjoin(reasons, ", ");
    else
        all_trial_quality.QC_reason(i) = "Clean";
    end

end

cd(path_data_preprocessed)
save('all_trial_quality.mat', 'all_trial_quality')

% Plot heatmap of participants that were later selected
participants = unique(all_trial_quality.Participant, 'stable');

n_participants = length(participants);
max_trials = max(all_trial_quality.Trial);

 
rms_matrix = nan(n_participants, max_trials);
 
for i = 1:n_participants
 
    p_name = participants{i};
    idx = strcmp(all_trial_quality.Participant, p_name);
    T = all_trial_quality(idx,:);
 
    rms_matrix(i, T.Trial) = T.RMS;
 
end
 
figure('Color','w');
 
imagesc(rms_matrix, [0 50]);
 
xlabel('Trial');
ylabel('Participant');
title('RMS (\muV) per trial - final clean trial selection');
 
set(gca, ...
    'YTick', 1:n_participants, ...
    'YTickLabel', participants);
colorbar;
set(gca,'Color',[0.9 0.9 0.9]);
 



% ============================================================
%  CLEAN THE DATASETS FROM BAD TRIALS (objective + manual)
% =============================================================

%files = dir(fullfile(path_data_preprocessed, 'not_epoched_prep*'));
cd(path_data_preprocessed)

all_trial_quality = load('all_trial_quality.mat');
all_trial_quality = all_trial_quality.all_trial_quality;

% ---- Manual exclusions, keyed by EXACT filename ----
 manual_bad_trials = containers.Map();
 manual_bad_trials('not_epoched_prep_NLP06.mat') = [5 7 9];
 manual_bad_trials('not_epoched_prep_NLP04.mat') = 9;
 manual_bad_trials('not_epoched_prep_NLP13.mat') = [12 13 15 18 26 27];
 manual_bad_trials('not_epoched_prep_NLP18.mat') = 14;
 manual_bad_trials('not_epoched_prep_NLP20.mat') = [1 14];
 manual_bad_trials('not_epoched_prep_NLP27.mat') = [3 4 5 6 7];
 manual_bad_trials('not_epoched_prep_NLP30.mat') = [1 18 19 20 21];
 manual_bad_trials('not_epoched_prep_NLP34.mat') = [14 15 17 18];
 manual_bad_trials('not_epoched_prep_NLP36.mat') = [6 13 19 20];
 manual_bad_trials('not_epoched_prep_NLP39.mat') = [1 16 17];
 manual_bad_trials('not_epoched_prep_NLP45.mat') = 23;

key_list = keys(manual_bad_trials);
matched_keys = false(size(key_list));

for jj = 1:length(files)

    p = load(files(jj).name);
    p = p.data_preprocessed;

    % --- Objective bad trials for this participant ---
    idx_qc = strcmp(all_trial_quality.Participant, files(jj).name);
    bad_trials = all_trial_quality.Trial(idx_qc & all_trial_quality.QC_bad);

    % --- Add manual exclusions, if any ---
    if isKey(manual_bad_trials, files(jj).name)
        manual_vals = manual_bad_trials(files(jj).name);
        bad_trials = sort(unique([bad_trials(:); manual_vals(:)]));
        matched_keys(strcmp(key_list, files(jj).name)) = true;
    end

    fprintf('[%s] total trials: %d | bad trials: %d -> %s\n', ...
        files(jj).name, length(p.trial), numel(bad_trials), mat2str(bad_trials(:)'));

    % --- Keep everything except bad trials ---
    good_trials = setdiff(1:length(p.trial), bad_trials);
    original_trial_quality = p.trial_quality;

    p_select = rmfield(p, 'bad_channels');
    cfg = [];
    cfg.trials = good_trials;
    data_epoched_clean = ft_selectdata(cfg, p_select);
    % Keep trial-wise metadata aligned with the selected trials
    data_epoched_clean.cond = p_select.cond(good_trials);
    data_epoched_clean.monologue = p_select.monologue(good_trials);
    
    fprintf('[%s] good_trials requested: %d | actual output trials: %d\n', ...
        files(jj).name, numel(good_trials), numel(data_epoched_clean.trial));
    
    % --- Carry over matching trial-quality fields ---
    qc_fields = fieldnames(original_trial_quality);
    for k = 1:length(qc_fields)
        field = qc_fields{k};
        if isnumeric(original_trial_quality.(field)) && ...
                numel(original_trial_quality.(field)) == length(p.trial)
            data_epoched_clean.trial_quality.(field) = ...
                original_trial_quality.(field)(good_trials);
        end
    end

    data_epoched_clean.original_trial = good_trials;
    data_epoched_clean.bad_channels = p.bad_channels;

    filename = fullfile(path_data_preprocessed, ['clean_' files(jj).name]);
    save(filename, 'data_epoched_clean', '-v7.3');

    fprintf('Saved: %s\n\n', filename);

end

% --- Flag manual entries that never matched a file (typo detector) ---
if any(~matched_keys)
    warning('These manual entries were never matched to a loaded file: %s', ...
        strjoin(key_list(~matched_keys), ', '));
end

% ============================================================
%  TABLE OF INCLUDED TRIALS PER PARTICIPANT AND CONDITION
% =============================================================

cd(path_data_preprocessed)
clean_files = dir(fullfile(path_data_preprocessed, 'clean_not_epoched_prep*'));

participant = {};
condition = [];
n_trials = [];

for jj = 1:length(clean_files)

    tmp = load(fullfile(path_data_preprocessed, clean_files(jj).name));
    data = tmp.data_epoched_clean;

    participant_name = clean_files(jj).name;
    participant_name = erase(participant_name, 'clean_not_epoched_prep');
    participant_name = erase(participant_name, '.mat');

    conditions = unique(data.cond);

    if ~isempty(conditions)
        for cc = 1:length(conditions)
            participant{end+1,1} = participant_name;
            condition(end+1,1) = conditions(cc);
            n_trials(end+1,1) = sum(data.cond == conditions(cc));
        end
    end

end

trial_counts = table(participant, condition, n_trials, ...
    'VariableNames', {'Participant', 'Condition', 'NTrials'});
trial_counts = sortrows(trial_counts, {'Participant','Condition'});

disp(trial_counts)

% ============================================================
%  RE-RUN QC SUMMARY ONCE BAD TRIALS ARE OUT
% =============================================================

clearvars -except path_data_preprocessed
files = dir(fullfile(path_data_preprocessed, 'clean_not_epoched_prep*'));

% QC thresholds (same as above; redefined here since clearvars wiped them)
max_pct_over120   = 1;
max_bad_channels  = 2;
max_abs_uV        = 500;
max_rms           = 100;
max_ptp           = 1000;

all_trial_quality_clean = table();

for i = 1:length(files)

    participant = load(files(i).name);
    participant = participant.data_epoched_clean;
%     S = participant.trial_quality;
% 
%     n_trials = length(S.max_abs_uV);
% 
%     T = table( ...
%         repmat({files(i).name}, n_trials, 1), ...
%         (1:n_trials)', ...
%         S.max_abs_uV(:), ...
%         S.pct_over_120(:), ...
%         S.rms(:), ...
%         S.peak_to_peak(:), ...
%         S.n_bad_channels(:), ...
%         'VariableNames', { ...
%         'Participant', 'Trial', 'MaxAbs_uV', 'PctOver120', ...
%         'RMS', 'PeakToPeak', 'NBadChannels'});

S = participant.trial_quality;

n_trials = length(S.max_abs_uV);

T = table( ...
    repmat({files(i).name}, n_trials, 1), ...
    (1:n_trials)', ...
    participant.original_trial(:), ...
    S.max_abs_uV(:), ...
    S.pct_over_120(:), ...
    S.rms(:), ...
    S.peak_to_peak(:), ...
    S.n_bad_channels(:), ...
    'VariableNames', { ...
    'Participant', 'Trial', 'OriginalTrial', ...
    'MaxAbs_uV', 'PctOver120', ...
    'RMS', 'PeakToPeak', 'NBadChannels'});

    all_trial_quality_clean = [all_trial_quality_clean; T];

end

all_trial_quality_clean = sortrows(all_trial_quality_clean, {'Participant','Trial'});

disp(all_trial_quality_clean);
fprintf('\nTotal participants: %d\n', numel(unique(all_trial_quality_clean.Participant)));
fprintf('Total trials: %d\n', height(all_trial_quality_clean));

% ---- Re-apply the same objective QC criteria for verification ----

flag_pct       = all_trial_quality_clean.PctOver120 > max_pct_over120;
flag_channels  = all_trial_quality_clean.NBadChannels > max_bad_channels;
flag_amplitude = all_trial_quality_clean.MaxAbs_uV > max_abs_uV;
flag_rms       = all_trial_quality_clean.RMS > max_rms;
flag_ptp       = all_trial_quality_clean.PeakToPeak > max_ptp;

all_trial_quality_clean.QC_bad = flag_pct | flag_channels | flag_amplitude | flag_rms | flag_ptp;

all_trial_quality_clean.QC_reason = strings(height(all_trial_quality_clean),1);

for i = 1:height(all_trial_quality_clean)

    reasons = strings(0,1);
    if flag_pct(i),       reasons(end+1) = "PctOver120";    end
    if flag_channels(i),  reasons(end+1) = "NBadChannels";  end
    if flag_amplitude(i), reasons(end+1) = "MaxAbs";        end
    if flag_rms(i),       reasons(end+1) = "RMS";           end
    if flag_ptp(i),       reasons(end+1) = "PeakToPeak";    end

    if ~isempty(reasons)
        all_trial_quality_clean.QC_reason(i) = strjoin(reasons, ", ");
    else
        all_trial_quality_clean.QC_reason(i) = "Clean";
    end

end

disp(all_trial_quality_clean(all_trial_quality_clean.QC_bad, :));

% 
% % ============================================================
% %  PLOT: RMS HEATMAP - PARTICIPANT x TRIAL (final clean selection)
% % =============================================================
%  
% set(0,'DefaultFigureVisible','on')
%  
% participants_clean = unique(all_trial_quality_clean.Participant, 'stable');
% n_participants_clean = length(participants_clean);
% 
% max_trials_clean = max(all_trial_quality_clean.OriginalTrial);
% 
% rms_matrix = nan(n_participants_clean, max_trials_clean);
% 
% for i = 1:n_participants_clean
% 
%     p_name = participants_clean{i};
% 
%     idx = strcmp(all_trial_quality_clean.Participant, p_name);
% 
%     T = all_trial_quality_clean(idx,:);
% 
%     rms_matrix(i, T.OriginalTrial) = T.RMS;
% 
% end
% ============================================================
% PLOT: RMS HEATMAP - PARTICIPANT x ORIGINAL TRIAL
% ============================================================

set(0,'DefaultFigureVisible','on')

participants_clean = unique(all_trial_quality_clean.Participant, 'stable');

n_participants_clean = length(participants_clean);

% Use ORIGINAL trial numbers so deleted trials remain visible as gaps
max_trials_clean = max(all_trial_quality_clean.OriginalTrial);

rms_matrix = nan(n_participants_clean, max_trials_clean);

for i = 1:n_participants_clean

    p_name = participants_clean{i};

    idx = strcmp(all_trial_quality_clean.Participant, p_name);

    T = all_trial_quality_clean(idx,:);

    % Place RMS according to original trial number
    rms_matrix(i, T.OriginalTrial) = T.RMS;

end

figure('Color','w');

imagesc(rms_matrix);

xlabel('Original trial');
ylabel('Participant');

title('RMS (\muV) per original trial - final clean trial selection');

set(gca, ...
    'YTick', 1:n_participants_clean, ...
    'YTickLabel', participants_clean);

colorbar;

set(gca,'Color',[0.9 0.9 0.9]);

cd('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/Data_processing/EEG/quality assessment/')
save('Quality_assessment_EEG.mat', 'T')
end