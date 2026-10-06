% Objective, create a dataset containing 
    % -> r_EEG (best channel, best lambda) = COND + Error

% Then, combine with PTLT, creating a dataset containing 
    % -> r_EEG (best channel, best lambda) = PTLT * Cond + Error
    
clc; clear all; close all;
% TRF_all_clear = load('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/EEG/all_clear_EEG_finalLambda.mat');
% TRF_all_vocoded = load('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/EEG/all_vocoded_EEG_finalLambda.mat');
%  
% TRF_all_clear = TRF_all_clear.TRF_clear_final;
% TRF_all_vocoded = TRF_all_vocoded.TRF_vocoded_final;
%  
% ids_clear = TRF_all_clear{:, 1};
% ids_voco = TRF_all_vocoded{:, 1};
% 
% vals_clear = TRF_all_clear{:, 2};
% vals_voco = TRF_all_vocoded{:, 2};


% ── RESULT table ─────────────────────────────────────────────────────────────
r_values = readtable('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/EEG/r_values.csv');

% Convert into long format: 
EEG = r_values;

EEG.ID = erase(EEG.ID, '.mat');
EEG.ID = erase(EEG.ID, 'clean_not_epoched_prep_');

EEG_long = table();

for i = 1:height(EEG)

    % Clear
    row1 = table( ...
        string(EEG.ID(i)), ...
        categorical("Clear"), ...
        EEG.r_Clear(i), ...
        'VariableNames', {'subjID','cond','r_EEG'});

    % Vocoded
    row2 = table( ...
        string(EEG.ID(i)), ...
        categorical("Vocoded"), ...
        EEG.r_Vocoded(i), ...
        'VariableNames', {'subjID','cond','r_EEG'});

    EEG_long = [EEG_long; row1; row2];

end

% Model whether condition explains TRF to clear and vocoded (15 subjects, all heard clear and vocoded)
lme = fitlme(EEG_long, ...
    'r_EEG ~ cond + (1|subjID)')

 % The difference in prediction accuracy was not statistically significant.


%% Load ET data

% Only take into account the ptlt values of the trials were there was
% neural activity:
path_EEG_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/EEG_ET_DATASETS';
files_ET_EEG = dir(fullfile(path_EEG_ET, 'EEG_ET*'));

% Create a master table:
masterTable = table();

for i = 1:length(files_ET_EEG)
    for t = 1:2
        participant = load([path_EEG_ET '/' files_ET_EEG(i).name]);
        subjID = {files_ET_EEG(i).name(end-8:end-4)};
        cond = t;
        if t ==1
            PTLT = participant.PTLT_clear;
        else
            PTLT = participant.PTLT_vocoded;
        end
        
        thisRow = table(subjID, cond, PTLT, ...
            'VariableNames', {'subjID','cond', 'PTLT'});
        
        masterTable = [masterTable; thisRow];
    end
end


ET_avg = masterTable;
ET_wide = unstack(ET_avg, 'PTLT', 'cond');
ET_wide.diffPTLT = ET_wide.x1 - ET_wide.x2;

% Convert table into long format
ET_long = table();

for i = 1:height(ET_wide)

    row1 = table( ...
        string(ET_wide.subjID(i)), ...
        categorical("Clear"), ...
        ET_wide.x1(i), ...
        'VariableNames', {'subjID','cond','PTLT'});

    row2 = table( ...
        string(ET_wide.subjID(i)), ...
        categorical("Vocoded"), ...
        ET_wide.x2(i), ...
        'VariableNames', {'subjID','cond','PTLT'});

    ET_long = [ET_long; row1; row2];

end

%% Merge both ET and EEG data

data = innerjoin(EEG_long, ET_long, ...
                 'Keys', {'subjID','cond'});

summary(data)

%% Fit mixed model
lme = fitlme(data, ...
    'r_EEG ~ cond * PTLT + (1|subjID)')

% Linear mixed-effects model fit by ML
% 
% Model information:
%     Number of observations              52
%     Fixed effects coefficients           4
%     Random effects coefficients         27
%     Covariance parameters                2
% 
% Formula:
%     r_EEG ~ 1 + cond*PTLT + (1 | subjID)
% 
% Model fit statistics:
%     AIC        BIC        LogLikelihood    Deviance
%     -183.43    -171.72    97.714           -195.43 
% 
% Fixed effects coefficients (95% CIs):
%     Name                       Estimate      SE           tStat       DF    pValue      Lower         Upper   
%     '(Intercept)'                 0.01555    0.0075797      2.0515    48    0.045696    0.00030975     0.03079
%     'cond_Vocoded'             -0.0049412    0.0091442    -0.54036    48     0.59144     -0.023327    0.013444
%     'PTLT'                      -0.021251     0.022256    -0.95482    48     0.34445     -0.065999    0.023498
%     'cond_Vocoded:PTLT'          0.019361     0.026972     0.71782    48     0.47635      -0.03487    0.073592
% 
% Random effects covariance parameters (95% CIs):
% Group: subjID (27 Levels)
%     Name1                Name2                Type         Estimate    Lower        Upper   
%     '(Intercept)'        '(Intercept)'        'std'        0.019726    0.0093746    0.041506
% 
% Group: Error
%     Name             Estimate    Lower       Upper   
%     'Res Std'        0.032077    0.024309    0.042326
             
%%


% 
% ET_avg = groupsummary(ET_data, {'ID','Cond'}, 'mean', 'PTLT');
%     ET_avg.Properties.VariableNames{'ID'} = 'ID';
%     ET_avg.Properties.VariableNames{'Cond'} = 'Condition';
%     
% Convert IDs comparable between ET format (1, 2...) and EEG format
% (NLP01, NLP02...)

% Convert numeric IDs to NLP format
ET_avg.ID = arrayfun(@(x) sprintf('NLP%02d', x), ET_avg.ID, 'UniformOutput', false);

% Convert condition into a categorical factor
ET_avg.Condition = categorical(ET_avg.Condition);

ET_avg.Condition = double(ET_avg.Condition);


% Convert IDs to the same type
ET_avg.ID = string(ET_avg.ID);
T_long.ID = string(T_long.ID);

% Convert conditions to the same type
ET_avg.Condition = double(ET_avg.Condition);
T_long.Condition = double(T_long.Condition);

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