%% =========================================================================
% preprocess_fNIRS_NEUROLIP.m
%
% Preprocessing pipeline for the NEUROLIP fNIRS dataset.
%
% Processing steps:
%   1. Load participant data
%   2. Correct participant-specific trigger issues
%   3. Synchronize fNIRS triggers with eye-tracking conditions
%   4. Compute signal quality (SCI)
%   5. Remove manually identified bad channels
%   6. Convert intensity to optical density
%   7. Apply motion correction (TDDR)
%   8. Convert to HbO/HbR concentrations
%   9. Extract epochs
%  10. Generate quality-control figures
%
% Required toolboxes:
%   - nirs-toolbox
%   - NIRS-GUI
%   - Homer2
%   - BrainWavelet
%   - qt-nirs
%
% Author: Irene Arrieta Sagredo
% Last updated: 2026

% REQUIREMENTS
%
% MATLAB R2023b (or later)
%
% Required toolboxes:
%   - nirs-toolbox
%   - Homer2
%   - NIRS-GUI
%   - BrainWavelet
%   - qt-nirs
%
% Input data:
%   - NIRx recordings
%   - ET event files
%   - stimulus order file
%


%% ========================================================================
% INITIALIZATION
% ========================================================================

set(0,'DefaultFigureVisible','on');

beep off;
clc;
clear all;

set(groot, ...
    'defaultFigureColor', 'w', ...
    'defaultAxesColor', 'w', ...
    'defaultAxesXColor', 'k', ...
    'defaultAxesYColor', 'k', ...
    'defaultAxesZColor', 'k', ...
    'defaultTextColor', 'k', ...
    'defaultLineColor', 'k');

set(0,'DefaultFigureVisible','off')
% Toolboxes
toolbox_path = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/fNIRS/nirs-toolbox-master 2';
addpath(genpath(toolbox_path));
path_wavelet_despike =  '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/fNIRS/BrainWavelet';
addpath (genpath(path_wavelet_despike));
path_nirsGUI =  '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/fNIRS/NIRS-GUI-master';
addpath (genpath(path_nirsGUI));
addpath(genpath(  '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/fNIRS/NIRS-GUI-master'))
savepath
toolbox_qt_path = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/fNIRS/qt-nirs-master'
addpath(genpath(toolbox_qt_path));
path_Homer2 ='/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/fNIRS/homer2_src_v2_3_10202017';
addpath(genpath(path_Homer2));
path_SPM =  '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/fNIRS/spm_fnirs'
addpath(genpath(path_SPM));

% My scripts
path_my_scripts = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/fNIRS/My_scripts_NIRS';
addpath (genpath(path_my_scripts));

% Path where the data is
path_data =  '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data';
addpath(genpath(path_data));

% Output paths
path_nirs =  '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/fNIRS';
addpath(genpath( '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/fNIRS'));
path_fig =  '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/fNIRS/Figures';
addpath(genpath(path_fig));

%% 
cd(path_data)
num_subj = dir('NLP*');

% Creation of one dataset with all participant data
participants = struct([]);
cd(path_data)
bad_chan_man = [];
bad_chan = [];

num_subj = dir('NLP*');
cont = [];
contt = 0;
for jj =2:length(num_subj) % Starting from 2 as NLP01 was tested with another montage
    cd(path_data)

    if (jj~=5 && jj~=30 && jj~=32 && jj~=43 && jj~=44 && jj~=46 && jj~=47)
        num_subj = dir('NLP*');
        subjects_name = {num_subj(:).name};
        path_file = [];
        indiv = subjects_name(jj)
        loss_sci = [];
        id = [];
        show_img =0; % flag to activate or deactivate plots
        loss_HB = [];
        id_all = [];
        loss_100 = [];
        loss_by_trial_all = [];
        cond_all = zeros(36, 1);
        raw_epoch = {[]};
        path_file = strcat(path_data,filesep,indiv, filesep, 'NIRS')
        folder_0 = dir(char(path_file));
        folder_0 = {folder_0.name}; % Extract file names
        folder_0 = folder_0(~ismember(folder_0, {'.', '..', '.DS_Store'})); % Remove unwanted files
        path_file_2= strcat(path_file,filesep,folder_0)
        folder_2 = dir(char(path_file_2))
        folder_2 = {folder_2.name}; % Extract file names
        folder_2 = folder_2(~ismember(folder_2, {'.', '..', '.DS_Store'})); % Remove unwanted files

        if length(folder_2)>0
            contt = contt + 1;
            for j =1:1%length(folder_2)
                if length(folder_2)>1
                    display('More than one recording')
                    % Adviced to change the j to j = 1:1 and then to j = 2:2
                end
                folder_22 = folder_2(j)
                path_file_3 = strcat(path_file_2, filesep, folder_22)
                folder_3 = dir(char(path_file_3));
                folder_3 = {folder_3.name}; % Extract file names
                folder_3 = folder_3(~ismember(folder_3, {'.', '..', '.DS_Store'})); % Remove unwanted files
                data = folder_3;
                raw_indiv = nirs.io.loadNIRx(char(path_file_3));
            end
            idx_to_change = 7;
            subj = char(indiv);
            raw_indiv.draw
            
            %% ------------------------------------------------------------------------
            % Participant-specific trigger corrections
            %% ------------------------------------------------------------------------
            
            if strcmp(subj, "NLP23")
                 % First trigger corresponds to an acquisition artifact rather than
                % an experimental video presentation.
                % Already seen at the beginning that there was an error, first trigger is not aftually a video but an artifact
                raw_indiv.stimulus('channel_8').onset(1) = [];
                raw_indiv.stimulus('channel_8').dur(1) = [];
                raw_indiv.stimulus('channel_8').amp(1) = [];
            elseif strcmp(subj, "NLP24")
                raw_indiv.stimulus('channel_7').onset =  [raw_indiv.stimulus('channel_7').onset(1); raw_indiv.stimulus('channel_1').onset(idx_to_change)]
                raw_indiv.stimulus('channel_7').dur = [raw_indiv.stimulus('channel_7').dur(1); raw_indiv.stimulus('channel_1').dur(idx_to_change)]
                raw_indiv.stimulus('channel_7').amp = [raw_indiv.stimulus('channel_7').amp(1); raw_indiv.stimulus('channel_1').amp(idx_to_change)]

                raw_indiv.stimulus('channel_1').onset(idx_to_change) = [];
                raw_indiv.stimulus('channel_1').dur(idx_to_change) = [];
                raw_indiv.stimulus('channel_1').amp(idx_to_change) = [];
            end
            raw_indiv.draw
            
            %% ========================================================================
            % Load eye tracking conditions
            % ========================================================================
            
            path_tobii = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/TobiiPro.SDK.Matlab_1.11.0.1';
            addpath(genpath(path_tobii));
            % Path where the data is
            path_data_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data';
            addpath(genpath(path_data_ET));
            cd(path_data_ET);
            num_subj = dir(subj);
            subjects_name = {num_subj(:).name};
            subjects_name = subjects_name(~ismember(subjects_name, {'.', '..', '.DS_Store'})); % Remove unwanted files
            path_file = strcat(path_data_ET,filesep,subj, filesep, 'ET')
            cd(char(path_file))
            logfile = dir('*.csv')
            conditions_ET = readtable(logfile.name)

            %% ------------------------------------------------------------------------
            % Fix triggers
            %% ------------------------------------------------------------------------
            
            raw_indiv_4triggers = fix_triggers_fNIRS(raw_indiv, conditions_ET, subj);
            
            %% ------------------------------------------------------------------------
            % Conversion to OD
            %% ------------------------------------------------------------------------
            
            job = [];
            job = nirs.modules.OpticalDensity(job);
            OD = job.run(raw_indiv_4triggers);
            
            % Temporal Derivative Distribution Repair
            job_1 = [];
            job_1 = nirs.modules.TDDR(job_1);
            OD_tddr = job_1.run(OD);
            
            % Convert to concentration values
            preprocess3 = [];
            preprocess3 = nirs.modules.BeerLambertLaw(preprocess3);
            conc_OD = preprocess3.run(OD_tddr);
            prestim = 5;
            poststim_epoch = 30;
            jobs = [];
            jobs = nirsGUI.modules.EpochExtraction(jobs);
            jobs.PreStimTime = prestim;
            jobs.PostStimTime = poststim_epoch;
            jobs.CorrectionLength = prestim;
            jobs.BaselineCorrect = true; % Process epoch with baseline correction
            epoched_conc_OD= jobs.run(conc_OD);
            
            %% ------------------------------------------------------------------------
            % Plot all epochs together
            %% ------------------------------------------------------------------------
            
            figure;
            subplot(4, 1, 1)
            plot(OD.data)
            title('Optical Density')
            subplot(4, 1, 2)
            plot(OD_tddr.data)
            title('Optical Density with TDDR')
            subplot(4, 1, 3)
            plot(conc_OD.data)
            title('Concentration values')
            subplot(4, 1, 4)
            plot(epoched_conc_OD.data)
            title('Epochs')
            epoched_conc_OD.draw
            sources = epoched_conc_OD.probe.link.source(1:2:end);
            detectors = epoched_conc_OD.probe.link.detector(1:2:end);
            [sources, detectors];
            
            if ~isempty(bad_chan_man)
                sources(bad_chan_man) = [];
                detectors(bad_chan_man) = [];
            end
            [sources, detectors];
            
            %% ------------------------------------------------------------------------
            %% Plot epochs
            %% ------------------------------------------------------------------------
            
            f = figure('Color', 'w');
            ax = axes(f);
            % Create the EpochTopoPlot
            ep = nirsGUI.plot.EpochTopoPlot(epoched_conc_OD, ...
                'SourceDetectorPairs', [sources, detectors], ...
                'Stimuli', {'clear', 'vocoded'}, ...  % Include both conditions
                'SignalTypes', {'hbo', 'hbr'}, ...
                'PlotTrials', false, ...
                'PlotStats', 'mean', ...
                'Axes', ax, ...
                'XLim', [-5 30], ...
                'YLim', [-100 100], ...
                'EnableReferenceAxes', true);


            % Define colors (normalized RGB values)
            HbO_Color_clear = [222, 161, 147] ./ 255;  % Reddish for clear
            HbR_Color_clear = [181,199,235] ./ 255;   % Bluish for clear
            HbO_Color_vocoded = [206,12,12]./255;  % Darker red for vocoded
            HbR_Color_vocoded = [0, 0, 1];    % Darker blue for vocoded
            % Define legend labels dynamically
            legendEntries = {};
            legendHandles = [];

            % Loop through each subplot in the grid (after plotting is done)
            for i = 1:length(ep.EpochAxes)
                ax = ep.EpochAxes(i);
                % Get all lines in the current axes
                lines = findall(ax, 'Type', 'Line');
                % Identify which line corresponds to HbO and which to HbR
                for j = 1:length(lines)
                    % Extract the line name to determine if it's HbO or HbR
                    lineName = lines(j).DisplayName;
                    set(lines, 'LineStyle', '-')  % Ensure line style is consistent
                    % If it's a clear condition, update the color
                    if contains(lineName, 'clear (hbo)', 'IgnoreCase', true)
                        set(lines(j), 'Color', HbO_Color_clear);
                        if isempty(find(legendHandles == lines(j), 1)) % Avoid duplicates
                            legendHandles(end+1) = lines(j);
                            legendEntries{end+1} = 'HbO clear';
                        end
                    elseif contains(lineName, 'clear (hbr)', 'IgnoreCase', true)
                        set(lines(j), 'Color', HbR_Color_clear);
                        if isempty(find(legendHandles == lines(j), 1))
                            legendHandles(end+1) = lines(j);
                            legendEntries{end+1} = 'HbR clear';
                        end
                        % If it's a vocoded condition, update the color
                    elseif contains(lineName, 'vocoded (hbo)', 'IgnoreCase', true)
                        set(lines(j), 'Color', HbO_Color_vocoded);
                        if isempty(find(legendHandles == lines(j), 1)) % Avoid duplicates
                            legendHandles(end+1) = lines(j);
                            legendEntries{end+1} = 'HbO vocoded';
                        end
                    elseif contains(lineName, 'vocoded (hbr)', 'IgnoreCase', true)
                        set(lines(j), 'Color', HbR_Color_vocoded);
                        if isempty(find(legendHandles == lines(j), 1))
                            legendHandles(end+1) = lines(j);
                            legendEntries{end+1} = 'HbR vocoded';
                        end
                    end
                end
            end

            % Create the legend after all lines are processed
            legend(legendHandles, legendEntries, 'Location', 'best');
            % List of participants' datasets
            epoched_conc_OD.description = subj;

            %% Save data into master participants matrix
            participants{contt} =epoched_conc_OD; % Replace with actual data objects
        end
    end
end

%% Save participant dataset
cd(path_data)
save('NIRS_participants_19_05.mat', 'participants')

%% Load participant dataset
cd(path_data)
participants = load('NIRS_participants_19_05.mat');
participants = participants.participants;


%% Plot contributed data for all participants and loss of channels
set(0,'DefaultFigureVisible','on')

clear_trials_all = zeros(1, length(participants));
vocoded_trials_all = zeros(1, length(participants));
trials_all = zeros(1, length(participants));
IDs = {};

loss_channels_all = zeros(1, length(participants));

for p = 1:length(participants)
    tmp = participants{1, p};
    clear_trials_all(p) = tmp.stimulus.values{1, 1}.count; % Clear trials
    vocoded_trials_all(p) = tmp.stimulus.values{1, 2}.count; % Vocoded trials
    trials_all(p) = tmp.stimulus.values{1, 1}.count + tmp.stimulus.values{1, 2}.count; % ...
    % contributed trials, clear and vocoded together
    IDs{1, p} = tmp.description;

    loss_channels_all(p) = length(find(all(isnan(tmp.data), 1)))/2 ; % Find columns of data turned into NaN, and as hbo and hbr use the same channel, divide by two the result
end


figure;
b = bar([clear_trials_all' vocoded_trials_all'], 'stacked')
% Set custom colors (RGB)
b(1).FaceColor = [0.2 0.6 0.8]; % color for clear trials
b(2).FaceColor = [0 0.4 0]; % color for vocoded trials
xticks([1:length(vocoded_trials_all)])
xticklabels(IDs)
xtickangle(45)
title('Contributed clear (blue) and vocoded (green) trials per participant');
legend({'Clear', 'Vocoded'})



figure;
b = bar(loss_channels_all)
% Set custom colors (RGB)
xticks([1:length(loss_channels_all)])
xticklabels(IDs)
xtickangle(45)
title('Lost channels per participant');




%% Plot all participants together
set(0,'DefaultFigureVisible','off')

% Took out nlp01 (other montage) and nlp12 (bad quality)
% n = 31 included
selection        = {'NLP02','NLP03','NLP04','NLP05','NLP06','NLP07','NLP08','NLP09',...
    'NLP10','NLP11','NLP13','NLP14','NLP15','NLP17','NLP18','NLP19','NLP20',...
    'NLP21','NLP22','NLP23','NLP24','NLP25','NLP26','NLP27','NLP29','NLP31',...
 'NLP33', 'NLP35', 'NLP36', 'NLP37', 'NLP39', 'NLP45'}; % Exclude 12 (bad quality) and 16, 28, 30 (no data)exclude 34 , exclude 38, 40, 41, 42, 43, 44, 46, 47

% Initialize color variables if not already defined
HbR_Color_vocoded = [0 0 1];
HbO_Color_vocoded = [206 12 12] / 255;
HbR_Color_clear = [181 199 235] / 255;
HbO_Color_clear = [222 161 147] / 255;

% Initialize matrices to store condition data
nChannels = 14;
nParticipants = length(selection);
matrix_all_HbR_voc = cell(nChannels, nParticipants);
matrix_all_HbO_voc = cell(nChannels, nParticipants);
matrix_all_HbR_clear = cell(nChannels, nParticipants);
matrix_all_HbO_clear = cell(nChannels, nParticipants);


%% Plotting individual and group results

set(0,'DefaultFigureVisible','on')
set(groot, ...
    'defaultFigureColor', 'w', ...
    'defaultAxesColor', 'w', ...
    'defaultAxesXColor', 'k', ...
    'defaultAxesYColor', 'k', ...
    'defaultAxesZColor', 'k', ...
    'defaultTextColor', 'k', ...
    'defaultLineColor', 'k');
close all;

% n = 32 included
selection        = {'NLP02','NLP03','NLP04','NLP05','NLP06','NLP07','NLP08','NLP09',...
    'NLP10','NLP11','NLP13','NLP14','NLP15','NLP17','NLP18','NLP19','NLP20',...
    'NLP21','NLP22','NLP23','NLP24','NLP25','NLP26','NLP27','NLP29','NLP31',...
    'NLP33', 'NLP35', 'NLP36', 'NLP37', 'NLP39', 'NLP45'}; 
% Exclude 12 16 (bad quality) and 28, 30 32 (no data)exclude 34 , exclude 38, 40, 41, 42, 43, 44, 46, 47

nChannels = 14;
nParticipants = length(selection);

matrix_all_HbR_voc = cell(nChannels, 0);
matrix_all_HbO_voc = cell(nChannels, 0);
matrix_all_HbR_clear = cell(nChannels, 0);
matrix_all_HbO_clear = cell(nChannels, 0);

positions = nan(nChannels, 4); % Preallocate for axes positions

for kk = 1:length(participants)
    epoched_conc_OD = participants{kk};
    subj_id = epoched_conc_OD.description;

    if ismember(subj_id, selection)
        fprintf('Procesando sujeto: %s\n', subj_id);
        figure;
        % Crear figura temporal con EpochTopoPlot para obtener l�neas y posiciones
        ep = nirsGUI.plot.EpochTopoPlot(epoched_conc_OD, ...
            'SourceDetectorPairs', [epoched_conc_OD.probe.link.source(1:2:end), epoched_conc_OD.probe.link.detector(1:2:end)], ...
            'Stimuli', {'clear', 'vocoded'}, ...
            'SignalTypes', {'hbo', 'hbr'}, ...
            'PlotTrials', false, ...
            'PlotStats', 'mean', ...
            'YLim', [-100 100]);
        % Set participant name as the figure title
        title(['Participant: ', subj_id], 'FontSize', 10);
        % Guardar posiciones de los ejes la primera vez (para un sujeto cualquiera)
        if all(isnan(positions(:)))
            for ch = 1:length(ep.EpochAxes)
                positions(ch,:) = get(ep.EpochAxes(ch), 'Position');
            end
        end

        % Extraer l�neas para cada canal
        for ch = 1:length(ep.EpochAxes)
            lines = findall(ep.EpochAxes(ch), 'Type', 'Line');
            for j = 1:length(lines)
                label = lower(lines(j).DisplayName);
                y = lines(j).YData;
                switch true
                    case contains(label, 'vocoded (hbr)')
                        matrix_all_HbR_voc{ch, end+1} = y;
                    case contains(label, 'vocoded (hbo)')
                        matrix_all_HbO_voc{ch, end+1} = y;
                    case contains(label, 'clear (hbr)')
                        matrix_all_HbR_clear{ch, end+1} = y;
                    case contains(label, 'clear (hbo)')
                        matrix_all_HbO_clear{ch, end+1} = y;
                end
            end
        end
        % Define custom colors
        custom_colors = struct( ...
            'vocoded_hbo', [206 12 12]/255, ...
            'vocoded_hbr', [0 0 1], ...
            'clear_hbo', [222 161 147]/255, ...
            'clear_hbr', [181 199 235]/255);

        % Modify line colors and widths
        for ch = 1:length(ep.EpochAxes)
            lines = findall(ep.EpochAxes(ch), 'Type', 'Line');
            for i = 1:length(lines)
                label = lower(lines(i).DisplayName);
                if contains(label, 'vocoded') && contains(label, 'hbo')
                    lines(i).Color = custom_colors.vocoded_hbo;
                    lines(i).LineWidth = 1;
                    lines(i).LineStyle = '-';
                elseif contains(label, 'vocoded') && contains(label, 'hbr')
                    lines(i).Color = custom_colors.vocoded_hbr;
                    lines(i).LineWidth = 1;
                    lines(i).LineStyle = '-';
                elseif contains(label, 'clear') && contains(label, 'hbo')
                    lines(i).Color = custom_colors.clear_hbo;
                    lines(i).LineWidth = 1;
                    lines(i).LineStyle = '-';
                elseif contains(label, 'clear') && contains(label, 'hbr')
                    lines(i).Color = custom_colors.clear_hbr;
                    lines(i).LineWidth = 1;
                    lines(i).LineStyle = '-';

                end
            end
        end
        % TO AVOID MATLAB SAVING IT IN BLACK BACKGROUND
        set(gcf, 'Color', 'w')  
        %close(gcf); % Cerrar figura temporal despu�s de extraer posiciones y datos
    end
end


% Crear figura para la media con posiciones iguales a EpochTopoPlot
f2 = figure('Name', 'Media Todos Los Sujetos', 'NumberTitle', 'off');
colors = struct('HbR_voc', [0 0 1], 'HbO_voc', [206 12 12]/255, ...
    'HbR_clear', [181 199 235]/255, 'HbO_clear', [222 161 147]/255);

for ch = 1:nChannels
    ax = axes('Position', positions(ch, :));
    hold(ax, 'on');

       HbR_voc = truncate_and_stack(matrix_all_HbR_voc(ch, :));
    HbO_voc = truncate_and_stack(matrix_all_HbO_voc(ch, :));
    HbR_clear = truncate_and_stack(matrix_all_HbR_clear(ch, :));
    HbO_clear = truncate_and_stack(matrix_all_HbO_clear(ch, :));
    if isempty(HbR_voc) && isempty(HbO_voc) && isempty(HbR_clear) && isempty(HbO_clear)
        title(ax, sprintf('Canal %d (sin datos)', ch));
        continue
    end

    example_signal = [];
    if ~isempty(HbR_voc), example_signal = HbR_voc(1, :);
    elseif ~isempty(HbO_voc), example_signal = HbO_voc(1, :);
    elseif ~isempty(HbR_clear), example_signal = HbR_clear(1, :);
    elseif ~isempty(HbO_clear), example_signal = HbO_clear(1, :);
    end
    x = linspace(-5, 30, length(example_signal));

    if ~isempty(HbR_voc)
        HbR_voc_mean = mean(HbR_voc, 1);
        HbR_voc_std = std(HbR_voc, [], 1);
        fill(ax, [x fliplr(x)], [HbR_voc_mean+HbR_voc_std fliplr(HbR_voc_mean-HbR_voc_std)], colors.HbR_voc, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
        plot(ax, x, HbR_voc_mean, 'Color', colors.HbR_voc, 'LineWidth', 2);
        ylim([-20, 80])
    end
    if ~isempty(HbO_voc)
        HbO_voc_mean = mean(HbO_voc, 1);
        HbO_voc_std = std(HbO_voc, [], 1);
        fill(ax, [x fliplr(x)], [HbO_voc_mean+HbO_voc_std fliplr(HbO_voc_mean-HbO_voc_std)], colors.HbO_voc, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
        plot(ax, x, HbO_voc_mean, 'Color', colors.HbO_voc, 'LineWidth', 2);
        ylim([-20, 80])
    end
    if ~isempty(HbR_clear)
        HbR_clear_mean = mean(HbR_clear, 1);
        HbR_clear_std = std(HbR_clear, [], 1);
        fill(ax, [x fliplr(x)], [HbR_clear_mean+HbR_clear_std fliplr(HbR_clear_mean-HbR_clear_std)], colors.HbR_clear, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
        plot(ax, x, HbR_clear_mean, 'Color', colors.HbR_clear, 'LineWidth', 2);
        ylim([-20, 80])
    end
    if ~isempty(HbO_clear)
        HbO_clear_mean = mean(HbO_clear, 1);
        HbO_clear_std = std(HbO_clear, [], 1);
        fill(ax, [x fliplr(x)], [HbO_clear_mean+HbO_clear_std fliplr(HbO_clear_mean-HbO_clear_std)], colors.HbO_clear, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
        plot(ax, x, HbO_clear_mean, 'Color', colors.HbO_clear, 'LineWidth', 2);
        ylim([-20, 80])
    end

    if ch == nChannels
        %title(ax, sprintf('Canal %d', ch));
        xlabel(ax, 'Time (s)');
        ylabel(ax, 'Change in Hb');
        legend(ax, {'HbR vocoded', 'HbO vocoded', 'HbR clear', 'HbO clear'}, 'Location', 'best');
        %grid(ax, 'on');

    end
    if ch ~= nChannels
        set(ax, 'XTick', [], 'YTick', []);
    end
    % TO AVOID MATLAB SAVING IT IN BLACK BACKGROUND
       set(gcf, 'Color', 'w')  
end


