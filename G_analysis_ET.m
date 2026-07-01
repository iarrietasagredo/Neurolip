%% TOMORROW I NEED TO RETRIEVE AND COMPUTE CALIBRATION DATA INDIVIDUALLY TO UNDERSTAND THE VARIATION WITHIN AND ACROSS THE BLOCKS...
% WITH THE ULTIMATE GOAL OF CREATING A VALID ROI THRESHOLDING
clc; clear all;

%% If at home:
intro_path = '/Users/irenearrietasagredo/';

%% If at work:
intro_path = '/Users/Laurianne/';

%% paths
close all;
path_tobii = [intro_path '/Dropbox/UPC POSTDOC/Code/NEUROLIP/TobiiPro.SDK.Matlab_1.11.0.1'];
addpath(genpath(path_tobii));

EyeTrackingOperations()
% Path where the data is
path_data = [intro_path 'Dropbox/UPC POSTDOC/Projects/NEUROLIP/NEUROLIP_updated/data_centralised'];
addpath(genpath(path_data));


path_scripts = '/Users/irenearrietasagredo/Dropbox/UPC POSTDOC/Projects/NEUROLIP/Data_processing';
addpath(genpath(path_scripts));

path_preprocessed = '/Users/irenearrietasagredo/Dropbox/UPC POSTDOC/Projects/NEUROLIP/Data_processing/ET';
addpath(genpath(path_preprocessed));

path_colormaps = '/Users/irenearrietasagredo/Dropbox/UPC POSTDOC/Projects/NEUROLIP/Data_processing/matplotlib';
addpath(genpath(path_colormaps))
%%

set(0,'DefaultFigureVisible','off')
cd(path_data)
num_subj = dir('*NLP*');
subjects_name = {num_subj(:).name};

sf = readtable('/Users/irenearrietasagredo/Dropbox/UPC POSTDOC/Projects/NEUROLIP/NEUROLIP_updated/data_centralised/NLP13/ET/nlp1333_trial_all_titta_pause_2025-04-11_09h52.21.992.csv')
sf = sf.frameRate(1);

img = imread('/Users/irenearrietasagredo/Dropbox/UPC POSTDOC/Projects/NEUROLIP/clementine.png'); % Replace with your image file
[imgH, imgW, ~] = size(img);    % Get image dimensions

% Subj 2 fuera... noisy!
selection = [1, 3:length(subjects_name)]

for j =1:length(selection)
    i = selection(j)
    %i = 2;
    indiv = subjects_name(i)
    
    path_file = strcat(path_data,filesep,indiv, filesep, 'ET')
    cd(char(path_file))
    folder_0 = dir(char(path_file));
    folder_0 = {folder_0.name}; % Extract file names
    folder_0 = folder_0(~ismember(folder_0, {'.', '..', '.DS_Store'})); % Remove unwanted files

    % Define old and new extensions
    oldExt = '.h5_gaze'; % Change to your current file extension
    newExt = '.txt';  % Change to the desired extension
    
    oldExt_2 = '.h5_exp';
    newExt_2 = '.txt';
    
    % Get a list of all files with the old extension
    fileList = dir(['*' oldExt]);
    fileList_2 = dir(['*' oldExt_2]);
    
    
    files = dir('gaze_*');
    files_exp = dir('exp_*');
    
    if(isempty(files))
        
        % Loop through each file and rename it
        for j = 1:length(fileList)
            %fileList(j).name = strcat(fileList(j).name,  'h5_gaze');
            oldName = fullfile(path_file, fileList(j).name);
            newName = fullfile(path_file, strcat('gaze_', replace(fileList(j).name, oldExt, newExt)));
            
            oldName_2 = fullfile(path_file, fileList_2(j).name);
            newName_2 = fullfile(path_file, strcat('exp_', replace(fileList_2(j).name, oldExt_2, newExt_2)));
            
            movefile(fileList(j).name, strcat('gaze_', replace(fileList(j).name, oldExt, newExt)))
            movefile(fileList_2(j).name, strcat('exp_', replace(fileList_2(j).name, oldExt_2, newExt_2)))
            
        end
        
        disp('File extensions changed successfully.');
        
    end
    
    files = dir('gaze_*');
    files_exp = dir('exp_*');
    
    % Create a database by subject, with a column extra for each trial number and another for subject name
    T_participant = [];
    figure;
    
    info_trial = zeros(length(files_exp), 5);
    for block = 1:length(files_exp)
        data_k = readtable(files(block).name);
        exp_k = readtable(files_exp(block).name);
        idx = regexp(exp_k.msg, "7less");
        idx = find(~cellfun(@isempty, idx));
        video_n = char(exp_k.msg(idx));
        video_n = video_n(1:2);
        video_n = str2num(video_n);
        if isempty(video_n)
            video_n = char(exp_k.msg(idx));
            video_n = video_n(1);
            video_n = str2num(video_n);
        end
        tf = contains(exp_k.msg, 'vocoded');  % returns true
        
        id_num = char(indiv);
        id_num = str2num(id_num(4:5));
        
        info_trial(block, 1) = id_num;
        info_trial(block, 2) = video_n;
        
        if tf == 1
            info_trial(block, 3) = 2;
        else
            info_trial(block, 3) = 1;
        end

        y = data_k.left_gaze_point_on_display_area_y;
        
        info_trial(block, 4) = sum(isnan(y))/length(y);
        
    end
    
    %% Plot of time series
    
    path_tobii = [intro_path '/Dropbox/UPC POSTDOC/Code/NEUROLIP/TobiiPro.SDK.Matlab_1.11.0.1'];
    addpath(genpath(path_tobii));
    
    EyeTrackingOperations()
    % Path where the data is
    path_data = [intro_path '/Dropbox/UPC POSTDOC/Projects/NEUROLIP/NEUROLIP_updated/data_centralised'];
    addpath(genpath(path_data));
    cd(path_data)
    
    num_subj = dir('*NLP*');
    subjects_name = {num_subj(:).name};
    data_y_normalised = 0;
    
    offset_trial = 0;
    indiv = subjects_name(i)
    
    path_file = strcat(path_data,filesep,indiv, filesep, 'ET')
    cd(char(path_file))
    folder_0 = dir(char(path_file));
    folder_0 = {folder_0.name}; % Extract file names
    folder_0 = folder_0(~ismember(folder_0, {'.', '..', '.DS_Store'})); % Remove unwanted files
    
    % Define old and new extensions
    oldExt = '.h5_gaze'; % Change to your current file extension
    newExt = '.txt';  % Change to the desired extension
    
    oldExt_2 = '.h5_exp';
    newExt_2 = '.txt';
    
    % Get a list of all files with the old extension
    fileList = dir(['*' oldExt]);
    fileList_2 = dir(['*' oldExt_2]);
    
    files = dir('gaze_*');
    files_exp = dir('exp_*');
    
    if(isempty(files))
        
        % Loop through each file and rename it
        for j = 1:length(fileList)
            %fileList(j).name = strcat(fileList(j).name,  'h5_gaze');
            oldName = fullfile(path_file, fileList(j).name);
            newName = fullfile(path_file, strcat('gaze_', replace(fileList(j).name, oldExt, newExt)));
            
            oldName_2 = fullfile(path_file, fileList_2(j).name);
            newName_2 = fullfile(path_file, strcat('exp_', replace(fileList_2(j).name, oldExt_2, newExt_2)));
            
            movefile(fileList(j).name, strcat('gaze_', replace(fileList(j).name, oldExt, newExt)))
            movefile(fileList_2(j).name, strcat('exp_', replace(fileList_2(j).name, oldExt_2, newExt_2)))
        end
        disp('File extensions changed successfully.');
    end
    data_y_normalised = 0;
    files = dir('gaze_*');
    files_exp = dir('exp_*');
    
    % Create a database by subject, with a column extra for each trial number and another for subject name
    T_participant = [];
    
    threshold_tmp = zeros(1, 4);
    offset = 0;
    
    %% Plot ROI
    
    [threshold{i}, threshold_xmin{i}, threshold_xmax{i}, offset] = ROI_creation_ET(indiv, threshold_tmp, files, idx, files_exp);
    
    
    figure;
    for block = 1:length(files_exp)
        % Face ROI
        if sum(block == [1:7]) >0
            thresh_tmp = threshold{i};
            thresh_tmp = thresh_tmp(1);
            threshold_xmin_tmpp = threshold_xmin{i};
            threshold_xmin_tmp = threshold_xmin_tmpp(1);
            threshold_xmax_tmpp = threshold_xmax{i};
            threshold_xmax_tmp = threshold_xmax_tmpp(1);
        elseif sum(block == [8:14]) >0
            thresh_tmp = threshold{i};
            thresh_tmp = thresh_tmp(2);
            threshold_xmin_tmpp = threshold_xmin{i};
            threshold_xmin_tmp = threshold_xmin_tmpp(2);
            threshold_xmax_tmpp = threshold_xmax{i};
            threshold_xmax_tmp = threshold_xmax_tmpp(2);
        elseif sum(block == [15:21])>0
            thresh_tmp = threshold{i};
            thresh_tmp = thresh_tmp(3);
            threshold_xmin_tmpp = threshold_xmin{i};
            threshold_xmin_tmp = threshold_xmin_tmpp(3);
            threshold_xmax_tmpp = threshold_xmax{i};
            threshold_xmax_tmp = threshold_xmax_tmpp(3);
        elseif sum(block == [22:28])>0
            thresh_tmp = threshold{i};
            thresh_tmp = thresh_tmp(4);
            threshold_xmin_tmpp = threshold_xmin{i};
            threshold_xmin_tmp = threshold_xmin_tmpp(4);
            threshold_xmax_tmpp = threshold_xmax{i};
            threshold_xmax_tmp = threshold_xmax_tmpp(4);
        end
        
        face_ymax = thresh_tmp - offset;
        face_ymin = thresh_tmp + offset;
        
        data_k = readtable(files(block).name);
        exp_k = readtable(files_exp(block).name);
        idx = regexp(exp_k.msg, "7less");
        idx = find(~cellfun(@isempty, idx));
        
        % Ahora, para encontrar los xmin y xmax plotear
        subplot(6, 5, block);
        x = data_k.left_gaze_point_on_display_area_x;
        y = data_k.left_gaze_point_on_display_area_y;
        
        plot(x, y, '.')
        hold on;
        rectangle('Position', [threshold_xmin_tmp, face_ymax, abs(threshold_xmin_tmp-threshold_xmax_tmp), abs(face_ymax-face_ymin)]);
        % Add horizontal line at y = 2
        plot(xlim, [thresh_tmp thresh_tmp], '-k');  % Dashed red line across the current x-axis limits
        hold on;
        
        set(gca, 'YDir', 'reverse');
        xm = threshold_xmin_tmp -1;
        xM = threshold_xmax_tmp + 1;
        ym = face_ymin +1;
        yM = face_ymax - 1;
        xlim([xm, xM])
        ylim([yM, ym])
        if block == 1
            
            title([indiv ' B ' num2str(block)])
        else
            title(['B ' num2str(block)])
        end
        
        %% Calculate PTLT
        x = data_k.left_gaze_point_on_display_area_x;
        y = data_k.left_gaze_point_on_display_area_y;
        
        x = x(~isnan(x));
        y = y(~isnan(y));
        
        x_min_idx = find(x>threshold_xmin_tmp);
        x_max_idx = find(x<threshold_xmax_tmp);
        x_idx_in = intersect(x_min_idx, x_max_idx);
        
        x_ysamples_face = y(x_idx_in);
        % Remember the y axis is inverted, that is why the logic of the > and <
        x_y_ymin_idx = find(x_ysamples_face<face_ymin);
        x_y_ymax_idx = find(x_ysamples_face>face_ymax);
        x_y_idx_in = intersect(x_y_ymin_idx, x_y_ymax_idx);
        samples_face = y(x_y_idx_in);
        
        samples_eye = samples_face(samples_face<thresh_tmp);
        samples_mouth = samples_face(samples_face>thresh_tmp);
        
        time_eye = length(samples_eye);
        time_mouth = length(samples_mouth);
        total_eye_mouth = time_eye + time_mouth;
        ptlt_dif =(time_mouth - time_eye) / total_eye_mouth;
        info_trial(block, 5) = ptlt_dif;
        
    end
    
    saveas(gcf, [path_preprocessed '/' char(indiv) '_ROI.png']);
    cd(path_preprocessed)
    info_trial_indiv = array2table(info_trial);
    info_trial_indiv.Properties.VariableNames ={'ID', 'Video_n', 'Cond', 'Loss', 'PTLT'}
    writetable(info_trial_indiv, [char(indiv) '_info_trial_ET.csv'])
    
    
end

%% Plot individual PTLT values per condition
cd(path_preprocessed)
num_subj = dir('*.csv');

% Create a master info table with all subjects
info_table = readtable(num_subj(1).name);
info_table_master = info_table;
for t = 2:length(num_subj)
    info_table = readtable(num_subj(t).name);
    info_table_master = [info_table_master; info_table];
end

% info_trial_master_table = array2table(info_table_master);
info_table_master.Properties.VariableNames ={'ID', 'Video_n', 'Cond', 'Loss', 'PTLT'}
writetable(info_table_master, 'master_info_trial_ET.csv')

% Extract unique IDs and assign a color to each
% info_table_master = readtable('/Users/irenearrietasagredo/Dropbox/UPC POSTDOC/Projects/NEUROLIP/Data_processing/ET/master_info_trial_ET.csv')
% Exclusion by loss > 0.6
% Keep only rows where loss <= 0.6
info_table_master = info_table_master(info_table_master.Loss <= 0.6, :);
unique_IDs = unique(info_table_master.ID);
numSubjects = numel(unique_IDs);


% Use hsv or lines colormap with enough colors
colors = tab20(numSubjects);  % or lines(numSubjects);
uniqueConds = unique(info_table_master.Cond);

figure; hold on;

% Plot gray boxplots in background for each condition
boxplot(info_table_master.PTLT, info_table_master.Cond, ...
    'Colors', [0.7 0.7 0.7], 'Symbol', '', ...
    'Widths', 0.4, 'Positions', uniqueConds);

% Define colors - one color per ID
numIDs = length(unique_IDs);

% Plot individual points with jitter on x axis
for i = 1:numIDs
    id = unique_IDs(i);
    for cond = uniqueConds'
        % Select data for this ID and condition
        idx = info_table_master.ID == id & info_table_master.Cond == cond;
        y = info_table_master.PTLT(idx);
        % Jitter x values around the condition value
        x_jitter = cond + (rand(size(y)) - 0.5)*0.2;
        scatter(x_jitter, y, 20, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.6);
    end
end

avg_jitter_amount = 0.1;  % smaller jitter for averages
all_avg_x = nan(numIDs, numel(uniqueConds));
all_avg_y = nan(numIDs, numel(uniqueConds));

for i = 1:numIDs
    id = unique_IDs(i);
    for c = 1:numel(uniqueConds)
        cond = uniqueConds(c);
        idx = info_table_master.ID == id & info_table_master.Cond == cond;
        y = info_table_master.PTLT(idx);
        if ~isempty(y)
            ymean = mean(y);
            x_jitter_avg = cond + (rand*2 - 1) * avg_jitter_amount;
            scatter(x_jitter_avg, ymean, 100, colors(i,:), 'filled', 'MarkerEdgeColor', 'none');
            % Save the jittered x and average y for line plot
            all_avg_x(i, c) = x_jitter_avg;
            all_avg_y(i, c) = ymean;
        end
    end
end

% Now plot lines connecting averages per ID
for i = 1:numIDs
    % Only connect points if both conditions exist
    valid = ~isnan(all_avg_x(i,:)) & ~isnan(all_avg_y(i,:));
    plot(all_avg_x(i,valid), all_avg_y(i,valid), '-', 'Color', colors(i,:), 'LineWidth', 1.5);
end
legend_handles = gobjects(numIDs,1);  % NEW
legend_labels = cell(numIDs,1);       % NEW

ages = [unique_IDs, [8, 7, 7.14, 7, 8, 7.2, 8.1, 7, 7.14, 7.14, 8, 8.1, 8,7.11, 7.1,8.14, 7.13, 7.3, 8, 8.2]']
% Prepare legend labels combining ID and age:
legendLabels = cell(numIDs,1);
for i = 1:numIDs
    % Find age for this ID:
    age_i = ages(ages(:,1) == unique_IDs(i), 2);
    legendLabels{i} = sprintf('ID %d (Age %.2f)', unique_IDs(i), age_i);
end

% Create invisible scatter points just for the legend:
hold on;
hLeg = gobjects(numIDs,1);
for i = 1:numIDs
    % Plot one invisible scatter per ID with color, no data:
    hLeg(i) = scatter(NaN, NaN, 50, colors(i,:), 'filled');
end
hold off;

legend(hLeg, legendLabels, 'Location', 'northeastoutside');

% Customize axes
xlim([min(uniqueConds)-0.5, max(uniqueConds)+0.5]);
xticks(uniqueConds);
xticklabels({'Clear', 'Vocoded'});  % or {'vocoded', 'clear'} if needed
set(gca, 'FontSize', 14);  % Increases tick label size
xlabel('Condition', 'FontSize', 16);
ylabel('Proportion mouth vs eyes', 'FontSize', 16);


saveas(gca, 'PTLT_cond_participant_et_wild.pdf')


%%


% %% Plot calibration accuracy, calculate offset
% 
% log_file = '/Users/irenearrietasagredo/Dropbox/UPC POSTDOC/Projects/NEUROLIP/NEUROLIP_updated/data_centralised/NLP13/ET/nlp1333_trial_all_titta_pause_2025-04-11_09h52.21.992.log';
% fid = fopen(log_file, 'r');
% if fid == -1
%     error('Failed to open the log file.');
% end
% 
% parsed_data = {};  % Cell array to hold parsed data
% 
% pattern = 'text=''(\d+(\.\d+)?)''';  % Matches text= followed by any non-space characters
% while ~feof(fid)
%     line = fgetl(fid);  % Read each line from the file
%     
%     % Find all matches of the pattern in the line
%     tokens = regexp(line, pattern, 'tokens');
%     
%     % If matches are found, process them
%     if ~isempty(tokens)
%         % Add all matches to parsed_data
%         for i = 1:length(tokens)
%             text_value = tokens{i}{1};  % Extract the matched numeric value
%             parsed_data{end+1, 1} = text_value;
%         end
%     end
% end
% 
% fclose(fid);
% 
% % Convert parsed data to a table for better readability
% parsed_table = cell2table(parsed_data, 'VariableNames', {'text_value'});
% disp(parsed_table);
% 
% % Create table with
% cal_results = {'B1_Accuracy_left'; 'B1_Accuracy_right'; 'B1_Precision_left'; 'B1_Precision_right'; 'B1_Data_loss_left'; 'B1_Data_loss_right';
%     'B2_Accuracy_left'; 'B2_Accuracy_right'; 'B2_Precision_left'; 'B2_Precision_right'; 'B2_Data_loss_left'; 'B2_Data_loss_right';
%     'B3_Accuracy_left'; 'B3_Accuracy_right'; 'B3_Precision_left'; 'B3_Precision_right'; 'B3_Data_loss_left'; 'B3_Data_loss_right';
%     'B4_Accuracy_left'; 'B4_Accuracy_right'; 'B4_Precision_left'; 'B4_Precision_right'; 'B4_Data_loss_left'; 'B4_Data_loss_right'};
% 
% calibration = [cal_results, parsed_table]

% %% Applying Calibration Accuracy in Normalized Coordinates:
% 
% % For block 1, calculation of offset:
% 
% % Given values, for the left eye, Q take the least error, right or left i dont care?
% calibration_accuracy_degrees = str2double(table2array(calibration(1, 2)));  % in degrees
% 
% % Example Code for FOV Calculation:
% 
% screen_width = 50;  % in cm (width of screen)
% screen_height = 30;  % in cm (height of screen)
% view_distance = 65;  % in cm (distance from eyes to screen)
% 
% screen_resolution_width = 1920;  % horizontal screen resolution in pixels
% screen_resolution_height = 1080;  % vertical screen resolution in pixels
% 
% % Convert screen width and height from cm to meters
% screen_width_m = screen_width / 100;  % convert to meters
% screen_height_m = screen_height / 100;  % convert to meters
% 
% % Calculate horizontal FOV in degrees
% horizontal_fov = 2 * atan(screen_width_m / (2 * view_distance));  % radians
% horizontal_fov_degrees = rad2deg(horizontal_fov);  % convert to degrees
% 
% % Calculate vertical FOV in degrees
% vertical_fov = 2 * atan(screen_height_m / (2 * view_distance));  % radians
% vertical_fov_degrees = rad2deg(vertical_fov);  % convert to degrees
% 
% 
% % Convert calibration accuracy to normalized coordinates
% calibration_accuracy_norm_x = calibration_accuracy_degrees / horizontal_fov_degrees;
% calibration_accuracy_norm_y = calibration_accuracy_degrees / vertical_fov_degrees;
% 
% % Display the results
% fprintf('calibration_accuracy_norm_x: %.2f normalised coord \n', calibration_accuracy_norm_x);
% fprintf('calibration_accuracy_norm_y: %.2f normalised coord\n', calibration_accuracy_norm_y);
% 
% 
% %%
% % ADD MINE! Always 'restando', as it is between 0 and 1
% gaze_data_x_norm = [0.3, 0.5, 0.7];  % Example gaze x coordinates (normalized)
% gaze_data_y_norm = [0.4, 0.6, 0.8];  % Example gaze y coordinates (normalized)
% 
% % Apply the accuracy correction in normalized coordinates
% gaze_data_corrected_x_norm = gaze_data_x_norm - calibration_accuracy_norm_x;  % Correct x-axis
% gaze_data_corrected_y_norm = gaze_data_y_norm - calibration_accuracy_norm_y;  % Correct y-axis
% 
% % Display the corrected gaze data (normalized coordinates)
% disp([gaze_data_corrected_x_norm; gaze_data_corrected_y_norm]');
% 
% %%
