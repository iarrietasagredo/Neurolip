clc; clear all; close all;

% ET_data = readtable('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/ET/master_info_trial_ET.csv');

NIRS_HBO_AUC = readtable('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/NIRS/HbO_AUC.csv');
NIRS_HBR_AUC = readtable('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/NIRS/HbR_AUC.csv');

% Only Ch1 came out as significantly different from clear to vocoded
% conditions


HbO_Color_clear = [222, 161, 147] ./ 255;  % Reddish for clear
HbR_Color_clear = [181,199,235] ./ 255;   % Bluish for clear
HbO_Color_vocoded = [206,12,12]./255;  % Darker red for vocoded
HbR_Color_vocoded = [0, 0, 1];    % Darker blue for vocoded

channel_anatomical_locations = {'LeftIFGant', 'LeftIFGpost', 'LeftIFGpost2', 'LeftTempAnt', 'LeftTempPostInf', 'LeftTempPostSup', 'LeftTempPost'...
    'RightIFGant', 'RightIFGpost', 'RightIFGpost2', 'RightTempAnt', 'RightTempPostInf', 'RightTempPostSup', 'RightTempPost'}

results = table('Size', [0, 8], ...
    'VariableTypes', {'string','double','string','double','double','double','double','double'}, ...
    'VariableNames', {'HbType','channel','channel_anatomical_locations','n','beta_diffPTLT','SE','pValue','R2'});


% Only take into account the ptlt values of the trials were there was
% neural activity:
path_NIRS_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/NIRS_ET_DATASETS';
files_ET_NIRS = dir(fullfile(path_NIRS_ET, 'NIRS_ET*'));

% Create a master table:
masterTable = table();

for i = 1:length(files_ET_NIRS)
    for t = 1:2
        participant = load([path_NIRS_ET '/' files_ET_NIRS(i).name]);
        subjID = {participant.raw_indiv.description(1:5)};
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
%

ET_avg = masterTable;
ET_wide = unstack(ET_avg, 'PTLT', 'cond');
ET_wide.diffPTLT = ET_wide.x1 - ET_wide.x2;


%% Check whther condition and mouth interaction explain nirs data
hblab = {'HbO', 'HbR'};

for ch = 1:14

    for t = 1:2

        %% Select HbO or HbR

        if t == 1
            NIRSAUC = NIRS_HBO_AUC;
        else
            NIRSAUC = NIRS_HBR_AUC;
        end

        %% Make participant IDs consistent

        merged_dataset = NIRSAUC;
        merged_dataset.subjID = lower(string(merged_dataset.subjID));

        %% Select channel

        HbO_ch1 = merged_dataset(merged_dataset.channel == ch, :);

        %% Convert NIRS data to wide format

        HbO_wide = unstack( ...
            HbO_ch1(:, {'subjID','condition','AUC'}), ...
            'AUC', 'condition');

        %% Calculate clear - vocoded difference

        HbO_wide.diffAUC = HbO_wide.x1 - HbO_wide.x2;

        %% Make sure ET IDs have the same format

        ET_temp = ET_wide;

        ET_temp.subjID = lower(string(ET_temp.subjID));

        %% Merge ET and NIRS

        diffData = innerjoin( ...
            ET_temp(:, {'subjID','diffPTLT'}), ...
            HbO_wide(:, {'subjID','diffAUC'}), ...
            'Keys', 'subjID');

        %% Remove participants with missing values

        diffData = rmmissing(diffData, ...
            'DataVariables', {'diffPTLT','diffAUC'});

        %% Linear model

        lm = fitlm(diffData, 'diffAUC ~ diffPTLT');

        %% Extract statistics

        beta = lm.Coefficients.Estimate(2);
        se   = lm.Coefficients.SE(2);
        pval = lm.Coefficients.pValue(2);
        r2   = lm.Rsquared.Ordinary;
        n    = height(diffData);

        results = [results; ...
            {t, ch, string(channel_anatomical_locations{ch}), ...
            n, beta, se, pval, r2}];

        %% Plot

        figure;
        hold on;

        scatter(diffData.diffPTLT, diffData.diffAUC, ...
            80, 'k', 'filled');

        xlabel('\Delta PTLT (clear - vocoded)', ...
            'FontSize', 20, 'FontWeight', 'bold');

        ylabel(['\Delta AUC (' ...
            channel_anatomical_locations{ch} ')'], ...
            'FontSize', 20, 'FontWeight', 'bold');

        title(['Change in mouth-looking vs change in neural activation, channel ' ...
            num2str(ch) ' ' hblab{t}], ...
            'FontSize', 16);

        grid on;
        box on;

    end
end

    
 %%  
   
                  
    %data_merged.Properties.VariableNames = { ...
    %'subjID_ET','cond_ET','task_ET','PTLT', ...
    %'subjID_HbO','cond_HbO','block_HbO','HbO_AUC'};
   
    % uncomment below if not diff: 3. merge with ET
    % finalData = table( ...
      %  data_merged.subjID, ...
      %  data_merged.condition, ...
      %  data_merged.mean_PTLT, ...
      %  data_merged.AUC, ...
      %  'VariableNames', {'subjID','condition','mean_PTLT','AUC'});
    
    % lme = fitlme(finalData, ...
    %    'AUC ~ condition *  mean_PTLT + (1|subjID)');
    %disp(lme)
    
    % Extract fixed effects table
    fe = dataset2table(lme.Coefficients);   % or just: lme.Coefficients
    
    % Get key stats for annotation
    coef_names = lme.CoefficientNames;
    estimates  = lme.Coefficients.Estimate;
    pvalues    = lme.Coefficients.pValue;
    
    % Build annotation string line by line
    txt = 'LME Fixed Effects:';
    for i = 1:length(coef_names)
        txt = sprintf('%s\n%s: \beta=%.3f, p=%.3f', ...
            txt, coef_names{i}, estimates(i), pvalues(i));
    end
    
    
    % Plotting
    
    % Extract columns (raw, may contain NaN strings if read from text)
    condition = data_merged.condition;
    PTLT      = data_merged.mean_PTLT;
    AUC       = data_merged.AUC;
    
    % Force numeric and replace any non-finite with NaN
    %AUC = double(AUC);          % ensure double, not char/cell
    %PTLT = double(PTLT);
    
    % Remove rows where AUC is NaN
    valid = isfinite(AUC);      % isfinite handles NaN AND Inf
    condition = condition(valid);
    PTLT      = PTLT(valid);
    AUC       = AUC(valid);
    
    % Separate by condition
    cond1 = condition == 1;
    cond2 = condition == 2;
    
    % Plot
    % figure;
    %subplot(1, 2, t)
    hold on;
    
    h1 = scatter( PTLT(cond1),AUC(cond1), 80, ...
        'filled', ...
        'Marker', 'o', ...
        'DisplayName', 'Clear');
    h1.MarkerFaceColor = color_clear;    % ← set AFTER plotting
    h1.MarkerEdgeColor = 'none';
    
    h2 = scatter( PTLT(cond2),AUC(cond2), 80, ...
        'filled', ...
        'Marker', 's', ...
        'DisplayName', 'Vocoded');
    h2.MarkerFaceColor = color_vocoded;  % ← set AFTER plotting
    h2.MarkerEdgeColor = 'none';
    
    
    hold on;
    % Fit and plot regression lines per condition
    x_range = linspace(min(PTLT), max(PTLT), 100);
    
    % Condition 1 fit
    p1 = polyfit(PTLT(cond1),AUC(cond1), 1);
    plot(x_range, polyval(p1, x_range), '-', ...
        'Color', color_clear, ...
        'LineWidth', 4);   % hides line from legend
  
    
    % Condition 2 fit
    p2 = polyfit(  PTLT(cond2),AUC(cond2),1);
    plot(x_range, polyval(p2, x_range), '-', ...
        'Color', color_vocoded, ...
        'LineWidth', 4);
   
    
    %hold off;
    
    % Labels and formatting
    xlabel('PTLT', 'FontSize', 25, 'FontWeight', 'bold');
    ylabel(channel_anatomical_locations(ch),  'FontSize', 25, 'FontWeight', 'bold');
    title(title_name, 'FontSize', 18);
    legend('Location', 'best', 'FontSize', 18);
    grid on;
    box on;
    set(gca, 'FontSize', 25);
    ylim([-4000, 10000])
    xlim([-0.6, 1])
    




%% Channel 2

HbO_ch2 = merged_dataset_HbO(merged_dataset_HbO.channel == 2, :);

% 3. merge with ET
data_merged = innerjoin(ET_avg, HbO_ch2, 'Keys', {'subjID','condition'});

%data_merged.Properties.VariableNames = { ...
%'subjID_ET','cond_ET','task_ET','PTLT', ...
%'subjID_HbO','cond_HbO','block_HbO','HbO_AUC'};

finalData = table( ...
    data_merged.subjID, ...
    data_merged.condition, ...
    data_merged.mean_PTLT, ...
    data_merged.AUC, ...
    'VariableNames', {'subjID','condition','mean_PTLT','AUC'});

lme = fitlme(finalData, ...
    'AUC ~ condition *  mean_PTLT + (1|subjID)');

disp(lme)

