clc; clear all; close all;

ET_data = readtable('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/ET/master_info_trial_ET.csv');

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

                            % Significant effect with mouth> Channels 3,
                            % and 14
for ch = 10%:14
    figure; 
for t = 1%:2
    
    if t ==1
        NIRSAUC = NIRS_HBO_AUC;
        color_clear = HbO_Color_clear;
        color_vocoded = HbO_Color_vocoded;
        title_name = ['Mouth looking and ' channel_anatomical_locations(ch)  ' HbO activation by condition'];
    else
        NIRSAUC = NIRS_HBR_AUC;
        color_clear = HbR_Color_clear;
        color_vocoded = HbR_Color_vocoded;
        title_name = ['Mouth looking and ' channel_anatomical_locations(ch)  ' HbR activation by condition'];
    end
    
    merged_dataset = NIRSAUC;
    merged_dataset.subjID =  str2double(extractAfter(string(NIRSAUC.subjID), "NLP"));
    
    ET_avg = groupsummary(ET_data, {'ID','Cond'}, 'mean', 'PTLT');
    ET_avg.Properties.VariableNames{'ID'} = 'subjID';
    ET_avg.Properties.VariableNames{'Cond'} = 'condition';
    
    
    HbO_ch1 = merged_dataset(merged_dataset.channel == ch, :);
    
    % 3. merge with ET
    data_merged = innerjoin(ET_avg, HbO_ch1, 'Keys', {'subjID','condition'});
    
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
    
end
end


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

