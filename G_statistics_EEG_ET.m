% Objective, create a dataset containing 
    % -> r_EEG (best channel, best lambda) = COND + Error

% Then, combine with PTLT, creating a dataset containing 
    % -> r_EEG (best channel, best lambda) = PTLT * Cond + Error
    
clc; clear all; close all;
TRF_all_clear = load('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/EEG/TRF_all_clear_EEG.mat');
TRF_all_vocoded = load('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/EEG/TRF_all_vocoded_EEG.mat');
 
TRF_all_clear = TRF_all_clear.TRF_clear;
TRF_all_vocoded = TRF_all_vocoded.TRF_vocoded;
 
ids_clear = table2array(TRF_all_clear(:, 1));
ids_voco = table2array(TRF_all_vocoded(:, 1));

vals_clear = table2array(TRF_all_clear(:, 2));
vals_voco = table2array(TRF_all_vocoded(:, 2));

n = length(ids_clear);
vals_voco_aligned = NaN(n, 1);   % pre-fill with NaN

for i = 1:n
    idx = find(strcmp(ids_voco, ids_clear{i}));
    if ~isempty(idx)
        vals_voco_aligned(i) = vals_voco(idx);
    end
    % if not found, stays NaN
end

% ── RESULT table ─────────────────────────────────────────────────────────────
T = table(ids_clear, vals_clear, vals_voco_aligned, ...
    'VariableNames', {'ID', 'Clear', 'Vocoded'});

% ── Build long-format table ──────────────────────────────────────────────────

% Stack IDs and values
ids_long = [ids_clear; ids_clear];

r_values = [vals_clear; vals_voco_aligned];

conditions = [ones(n,1); 2*ones(n,1)];   % 1 = clear, 2 = vocoded

% Create table
T_long = table(ids_long, conditions, r_values, ...
    'VariableNames', {'ID', 'Condition', 'R_value'});

% Sort by ID for readability (optional)
T_long = sortrows(T_long, {'ID', 'Condition'});

disp(T_long)

%% Model whether condition explains TRF to clear and vocoded (16 subjects, all heard clear and vocoded)
lme = fitlme(T_long, ...
    'R_value ~ Condition + (1|ID)');


disp(lme)
% Subjects tracked the speech envelope significantly above zero in both conditions. 
% There was a trend toward reduced neural tracking for vocoded vs. clear speech (β = −0.011, p = 0.074), 
% but it did not reach significance. This could reflect:

% A genuine but small degradation in cortical tracking under vocoding that the study is underpowered to detect 
% (only 19 subjects had both conditions)
% The vocoder preserving enough temporal envelope structure for the auditory cortex to still track it

% However, 
% Your model has 47 observations but 28 subjects — meaning 9 subjects only contributed condition 1 data 
% (their condition 2 is NaN). This reduces power for detecting the condition effect and may bias the estimate. 
% You could run a sensitivity analysis using only the 19 subjects with both conditions:

%% Model whether condition explains TRF to clear and vocoded 

T_long.Condition = categorical(T_long.Condition)

ids_both = T_long.ID(T_long.Condition == '2' & ~isnan(T_long.R_value));
T_balanced = T_long(ismember(T_long.ID, ids_both), :);

lme_balanced = fitlme(T_balanced, 'R_value ~ Condition + (1|ID)');
disp(lme_balanced)

% In the 19 subjects with complete data, cortical tracking of the speech envelope was significantly above zero 
% for both conditions, but did not differ significantly between clear and vocoded speech (p = 0.070). 
% The trend suggests vocoding slightly reduces neural tracking, but the effect is small (Δr ≈ 0.012) 
% and the study may be underpowered to detect it reliably.

%% Quick effect size estimate with both conditions
% For 19 subjects
clear_vals = T_balanced.R_value(T_balanced.Condition == '1');
voco_vals  = T_balanced.R_value(T_balanced.Condition == '2');

d = mean(clear_vals - voco_vals) / std(clear_vals - voco_vals);
fprintf('Cohen''s d = %.3f\n', d)

% Given that the result with 28 and with 19 is coherent, we could include
%% Quick effect size estimate for 28 subjects with either or both conditions

clear_vals = T_long.R_value(T_long.Condition == '1');
voco_vals  = T_long.R_value(T_long.Condition == '2');

% Paired differences — only where both are available
diff_vals = clear_vals - voco_vals;   % NaN where vocoded is missing

d_full = mean(diff_vals, 'omitnan') / std(diff_vals, 'omitnan');
fprintf('Cohen''s d (n=28, omitting NaN) = %.3f\n', d_full)

% "A linear mixed-effects model revealed a trend toward reduced cortical tracking for vocoded compared to 
% clear speech (β = −0.012, SE = 0.006, t(36) = −1.87, p = .070, d = 0.42). This effect size estimate was 
% consistent across both the full sample (n = 28) and the subset with complete data (n = 19), 
% suggesting a stable small-to-medium effect that the current sample size is likely underpowered 
% to detect at conventional thresholds."

%% Merge with ET

ET_data = readtable('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/ET/master_info_trial_ET.csv');

ET_avg = groupsummary(ET_data, {'ID','Cond'}, 'mean', 'PTLT');
    ET_avg.Properties.VariableNames{'ID'} = 'ID';
    ET_avg.Properties.VariableNames{'Cond'} = 'Condition';
    
% Convert IDs comparable between ET format (1, 2...) and EEG format
% (NLP01, NLP02...)

% Convert numeric IDs to NLP format
ET_avg.ID = arrayfun(@(x) sprintf('NLP%02d', x), ET_avg.ID, 'UniformOutput', false);

% Convert condition into a categorical factor
ET_avg.Condition = categorical(ET_avg.Condition);

ET_avg.Condition = double(ET_avg.Condition);

% Now join
data_merged = innerjoin(ET_avg, T_long, 'Keys', {'ID', 'Condition'});

disp(size(data_merged))
disp(head(data_merged))

data_merged = innerjoin(ET_avg, T_long, 'Keys', {'ID','Condition'});

finalData_EEG_ET = table( ...
    data_merged.ID, ...
    data_merged.Condition, ...
    data_merged.mean_PTLT, ...
    data_merged.R_value, ...
    'VariableNames', {'ID','Condition','mean_PTLT','R_value'});

lme = fitlme(finalData_EEG_ET, ...
    'R_value ~ Condition *  mean_PTLT + (1|ID)');

disp(lme)

% Eye tracking (PTLT) neither predicts cortical speech tracking overall, nor moderates the condition 
% effect. The condition trend (clear > vocoded) remains consistent across both models, but mouth-looking
% behaviour does not explain TRF variance. The simpler condition-only model is preferable based on 
% AIC/BIC.

%% Comparison between both models, adding ET or not

% Make sure both models are fit on the same 45 observations
T_nonan = finalData_EEG_ET(~isnan(finalData_EEG_ET.mean_PTLT), :);

lme_simple = fitlme(T_nonan, 'R_value ~ Condition + (1|ID)');
lme_ptlt   = fitlme(T_nonan, 'R_value ~ Condition * mean_PTLT + (1|ID)');

% Likelihood ratio test
results = compare(lme_simple, lme_ptlt)

% results = 


    % Theoretical Likelihood Ratio Test

    % Model         DF    AIC        BIC        LogLik    LRStat    deltaDF    pValue 
    % lme_simple    4     -201.65    -194.42    104.82                                
    % lme_ptlt      6     -198.09    -187.25    105.05    0.4444    2          0.80075
    
% LRStat = 0.44 — the improvement in log-likelihood from adding PTLT is negligible (105.05 vs 104.82, 
% a difference of only 0.23)
%deltaDF = 2 — the complex model uses 2 extra parameters (main effect of PTLT + interaction)
%p = 0.801 — far from significance; adding PTLT explains essentially no additional variance
%AIC/BIC both increase — the simpler model is preferred on both criteria

% "To examine whether mouth-looking behaviour (PTLT) explained variance in cortical speech tracking, 
% we compared a baseline model including only condition as a fixed effect to a model additionally 
% including PTLT and its interaction with condition. A likelihood ratio test indicated no significant 
% improvement in model fit (χ²(2) = 0.44, p = .801), with AIC and BIC both favouring the simpler model. 
% Mouth-looking behaviour was therefore not retained as a predictor."
 
%% Cluster based permutation test
% After your existing loop you already have:
% all_clear:   time x n_participants (TRF weights per participant, clear)
% all_vocoded: time x n_particlccipants (TRF weights per participant, vocoded)

% But you need PAIRED data — same participants in both conditions
% Find participants present in BOTH conditions
all_clear = load('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/EEG/all_clear_EEG_norm.mat');
all_clear = all_clear.all_clear_norm;
all_vocded = load('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/EEG/all_vocoded_EEG_norm.mat');
all_vocded = all_vocded.all_vocoded_norm;

clear_paired   = all_clear;
vocoded_paired = all_vocded;

% Simple paired permutation test across time points
n_perms = 1000;
n_times = size(clear_paired, 1);
true_diff = mean(clear_paired, 2) - mean(vocoded_paired, 2); % time x 1

perm_max = zeros(n_perms, 1);
for p = 1:n_perms
    % Randomly flip signs (equivalent to swapping conditions)
    signs = sign(randn(1, size(all_clear, 2)));
    perm_diff = mean((clear_paired - vocoded_paired) .* signs, 2);
    perm_max(p) = max(abs(perm_diff));
end

% Threshold at 95th percentile
threshold = prctile(perm_max, 95);
significant = abs(true_diff) > threshold;

fprintf('Significant time points: %d out of %d\n', sum(significant), n_times);


figure
plot(true_diff,'k','LineWidth',2)
hold on
yline(threshold,'r--')
yline(-threshold,'r--')
xlabel('Lag')
ylabel('Difference (Clear - Vocoded)')


% Calculate the paired t-value at each lag:

diff_data = clear_paired - vocoded_paired;

n = size(diff_data,2);

tvals = mean(diff_data,2) ./ ...
       (std(diff_data,[],2) ./ sqrt(n));

figure
plot(tvals)
yline(2)
yline(-2)