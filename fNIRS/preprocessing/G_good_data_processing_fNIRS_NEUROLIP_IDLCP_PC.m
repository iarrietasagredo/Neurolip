% Script written in Irene de la Cruz - Pavia PC

%% Pre-processingv step 1
set(0,'DefaultFigureVisible','on')
beep off;
clc; clear all;
set(groot, ...
    'defaultFigureColor', 'w', ...
    'defaultAxesColor', 'w', ...
    'defaultAxesXColor', 'k', ...
    'defaultAxesYColor', 'k', ...
    'defaultAxesZColor', 'k', ...
    'defaultTextColor', 'k', ...
    'defaultLineColor', 'k');

%% If at home:
% intro_path = '/Users/irenearrietasagredo/';
%% If at work:
% intro_path = '/Users/Laurianne/';

%%
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
path_data_preprocessed = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data_preprocessed/fNIRS',
addpath(genpath(path_data_preprocessed));

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



%% Pre-processing
set(0,'DefaultFigureVisible','off')
close all

cd(path_data)

% Creation of one dataset with all participant da∂fta
participants = struct([]);
cd(path_data)
bad_chan_man = [];
bad_chan = [];

num_subj = dir('NLP*');
subjects_name = {num_subj(:).name};
cont = [];
contt = 0;
% Check jj 20, jj 29
for jj =3%:length(num_subj) % Starting from 2 as NLP01 was tested with another montage
    cd(path_data)

    if (jj~=5 && jj~=29 && jj~=30 && jj~=32 && jj~=43 && jj~=44 && jj~=46 && jj~=47 )
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
            
            if strcmp(subj, "NLP23")
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
           
            %% Include ET condition data
            path_tobii = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/TobiiPro.SDK.Matlab_1.11.0.1';
            addpath(genpath(path_tobii));
            % Path where the data is
            path_data_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data';
            addpath(genpath(path_data_ET));
            cd(path_data_ET);
            num_subj = dir(subj);
            
            subjects_name_ET = subjects_name(~ismember(subjects_name, {'.', '..', '.DS_Store'})); % Remove unwanted files
            path_file = strcat(path_data_ET,filesep,subj, filesep, 'ET')
            cd(char(path_file))
            logfile = dir('*.csv')
            conditions_ET = readtable(logfile.name)

            %% Raw plot
            if strcmp(subj, 'NLP03')
                raw_indiv.stimulus('channel_15').onset;
                n_trigs = 15;
            else
                n_trigs = 14;
            end
            raw_indiv.time
            trig = zeros(length(raw_indiv.time), 14);
            trig_originalT = zeros(length(raw_indiv.time), n_trigs);
            figure;
            start_trig = 100000000;
            end_trig = 0;
            for kk = 1:n_trigs
                % There could be recordings with not all triggers played
                if ~isempty(raw_indiv.stimulus(['channel_' num2str(kk)]))
                    for k = 1:length(raw_indiv.stimulus(['channel_' num2str(kk)]).onset)
                        trial = raw_indiv.stimulus(['channel_' num2str(kk)]).onset(k);
                        [a, b] = min(abs(raw_indiv.time- trial));
                        trig(b, kk) = 1;
                        if end_trig < b
                            end_trig = b;
                        end
                        if start_trig > b
                            start_trig = b;
                        end
                    end
                end
                plot(trig(:, kk),'color', [0.1, 1, 0.9]); hold on;
            end

            plot(trig(:, 1),'color', [0.1, 1, 0.9]); hold on; plot(trig(:, 2),'color', [0.7, 0.4, 0.8]); hold on;
            plot(trig(:, 3),'color', [1, 0, 0]); hold on; plot(trig(:, 4),'color', [0, 0, 0]); hold on;
            plot(trig(:, 5),'color', [0, 1, 1]); hold on; plot(trig(:, 6),'color', [0, 0, 1]); hold on;
            plot(trig(:, 7),'color', [1, 0, 1]); hold on; plot(trig(:, 8),'color', [1, 0.5, 1]); hold on;
            plot(trig(:, 9),'color', [1, 0.5, 0]); hold on; plot(trig(:, 10),'color', [1, 0.5, 0]); hold on;
            plot(trig(:, 11),'color', [0, 0.5, 0]); hold on; plot(trig(:, 12),'color', [0, 0.5, 1]); hold on;
            plot(trig(:, 13),'color', [0.5, 0, 0.5]); hold on; plot(trig(:, 14),'color', [0.5, 0.5, 1]); hold on;

            if strcmp(subj, 'NLP03')
                plot(trig(:, 15),'color', [0.5, 0.5, 0]); hold on;
            end
            plot(raw_indiv.data)

            % Assign all triggers to one only vector
            all_triggers_vector = zeros(length(trig(: ,1)),1); all_triggers_vector(find(trig(:, 1)))= 1;
            all_triggers_vector(find(trig(:, 2)))= 2; all_triggers_vector(find(trig(:, 3)))= 3;
            all_triggers_vector(find(trig(:, 4)))= 4; all_triggers_vector(find(trig(:, 5)))= 5;
            all_triggers_vector(find(trig(:, 6)))= 6; all_triggers_vector(find(trig(:, 7)))= 7;
            all_triggers_vector(find(trig(:, 8)))= 8; all_triggers_vector(find(trig(:, 9)))= 9;
            all_triggers_vector(find(trig(:, 10)))= 10; all_triggers_vector(find(trig(:, 11)))= 11;
            all_triggers_vector(find(trig(:, 12)))= 12; all_triggers_vector(find(trig(:, 13)))= 13;
            all_triggers_vector(find(trig(:, 14)))= 14;

            if strcmp(subj, 'NLP03')
                all_triggers_vector(find(trig(:, 15)))= 15;
            end
            time = zeros(length(raw_indiv.time), 1);
            
            %% Cut the data and calculate triggers again

            raw_indiv.data =raw_indiv.data([start_trig:end_trig], :)
            raw_indiv.time =raw_indiv.time([start_trig:end_trig])
            %n_trigs = size(raw_indiv.getStimMatrix, 2);
            trig = zeros(length(raw_indiv.time), 14);
            trig_originalT = zeros(length(raw_indiv.time), n_trigs);

            figure;
            %
            %     start_trig = 100000000;
            end_trig = 0;
            for kk = 1:n_trigs
                % There could be recordings with not all triggers played
                if ~isempty(raw_indiv.stimulus(['channel_' num2str(kk)]))
                    for k = 1:length(raw_indiv.stimulus(['channel_' num2str(kk)]).onset)
                        trial = raw_indiv.stimulus(['channel_' num2str(kk)]).onset(k);
                        [a, b] = min(abs(raw_indiv.time- trial));
                        trig(b, kk) = 1;

                    end
                end
                plot(trig(:, kk),'color', [0.1, 1, 0.9]); hold on;
            end

            if strcmp(subj, 'NLP38') % Delete an error on the triggers
                idx8 = find(trig(:, 8));
                trig(idx8(1),8)= 0;
            end
            plot(trig(:, 1),'color', [0.1, 1, 0.9]); hold on; plot(trig(:, 2),'color', [0.7, 0.4, 0.8]); hold on;
            plot(trig(:, 3),'color', [1, 0, 0]); hold on; plot(trig(:, 4),'color', [0, 0, 0]); hold on;
            plot(trig(:, 5),'color', [0, 1, 1]); hold on; plot(trig(:, 6),'color', [0, 0, 1]); hold on;
            plot(trig(:, 7),'color', [1, 0, 1]); hold on; plot(trig(:, 8),'color', [1, 0.5, 1]); hold on;
            plot(trig(:, 9),'color', [1, 0.5, 0]); hold on; plot(trig(:, 10),'color', [1, 0.5, 0]); hold on;
            plot(trig(:, 11),'color', [0, 0.5, 0]); hold on; plot(trig(:, 12),'color', [0, 0.5, 1]); hold on;
            plot(trig(:, 13),'color', [0.5, 0, 0.5]); hold on; plot(trig(:, 14),'color', [0.5, 0.5, 1]); hold on;

            if strcmp(subj, 'NLP03')
                plot(trig(:, 15),'color', [0.5, 0.5, 0]); hold on;
            end

            % Assign all triggers to one only vector
            all_triggers_vector = zeros(length(trig(: ,1)),1); all_triggers_vector(find(trig(:, 1)))= 1;
            all_triggers_vector(find(trig(:, 2)))= 2; all_triggers_vector(find(trig(:, 3)))= 3;
            all_triggers_vector(find(trig(:, 4)))= 4; all_triggers_vector(find(trig(:, 5)))= 5;
            all_triggers_vector(find(trig(:, 6)))= 6; all_triggers_vector(find(trig(:, 7)))= 7;
            all_triggers_vector(find(trig(:, 8)))= 8; all_triggers_vector(find(trig(:, 9)))= 9;
            all_triggers_vector(find(trig(:, 10)))= 10; all_triggers_vector(find(trig(:, 11)))= 11;
            all_triggers_vector(find(trig(:, 12)))= 12; all_triggers_vector(find(trig(:, 13)))= 13;
            all_triggers_vector(find(trig(:, 14)))= 14;

            if strcmp(subj, 'NLP03')
                all_triggers_vector(find(trig(:, 15)))= 15;
            end
            time = zeros(length(raw_indiv.time), 1);
            
            raw_indiv_ORIGINAL = raw_indiv;
            %% Update triggers
            deleted_yet = 0;
            
            if strcmp(subj, 'NLP05')
                videos_ET_nonan = conditions_ET.trig;
                videos_ET_nonan(find(cellfun(@isempty, conditions_ET.trig))) = [];
                conditions_ET_nonan = conditions_ET.cond;
                conditions_ET_nonan(find(cellfun(@isempty, conditions_ET.cond))) = [];
            else
            videos_ET_nonan = conditions_ET.trig(~isnan(conditions_ET.trig));
            conditions_ET_nonan = conditions_ET.cond(~isnan(conditions_ET.cond));
            end
            
            if strcmp(subj, "NLP03")
                if deleted_yet == 0
                    videos_ET_nonan(13) = nan; % this trigger was not sent
                    conditions_ET_nonan(13) = nan; % this trigger was not sent
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))

            elseif strcmp(subj, "NLP04") % I forgot to start recording fNIRS... only recorded after the 8th trial
                if deleted_yet == 0
                    videos_ET_nonan(1) = nan; % this trigger was not sent
                    conditions_ET_nonan(1) = nan; 
                    videos_ET_nonan(2) = nan;
                    conditions_ET_nonan(2) = nan; 
                    videos_ET_nonan(3) = nan; 
                    conditions_ET_nonan(3) = nan; 
                    videos_ET_nonan(4) = nan; 
                    conditions_ET_nonan(4) = nan; 
                    videos_ET_nonan(5) = nan; 
                    conditions_ET_nonan(5) = nan; 
                    videos_ET_nonan(6) = nan; 
                    conditions_ET_nonan(6) = nan; 
                    videos_ET_nonan(7) = nan; 
                    conditions_ET_nonan(7) = nan;
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))
            elseif strcmp(subj, "NLP05")
                if deleted_yet == 0
                    videos_ET_nonan(21) = nan; % this trigger was not sent
                    conditions_ET_nonan(21) = nan; % this trigger was not sent
                    videos_ET_nonan(20) = nan; % this trigger was not sent
                    conditions_ET_nonan(20) = nan; % this trigger was not sent
                    videos_ET_nonan(19) = nan; % this trigger was not sent
                    conditions_ET_nonan(19) = nan; % this trigger was not sent
                    videos_ET_nonan(18) = nan; % this trigger was not sent
                    conditions_ET_nonan(18) = nan; % this trigger was not sent
                    videos_ET_nonan(17) = nan; % this trigger was not sent
                    conditions_ET_nonan(17) = nan; % this trigger was not sent
                    videos_ET_nonan(16) = nan; % this trigger was not sent
                    conditions_ET_nonan(16) = nan; % this trigger was not sent
                    videos_ET_nonan(15) = nan; % this trigger was not sent
                    conditions_ET_nonan(15) = nan; % this trigger was not sent
                    videos_ET_nonan(14) = nan; % this trigger was not sent
                    conditions_ET_nonan(14) = nan; % this trigger was not sent

                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))

            elseif strcmp(subj, "NLP08")
                if deleted_yet == 0
                    videos_ET_nonan(19) = nan; % this trigger was not sent
                    conditions_ET_nonan(19) = nan; % this trigger was not sent
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))
            elseif strcmp(subj, "NLP10")
                if deleted_yet == 0
                    videos_ET_nonan(20) = nan; % this trigger was not sent
                    conditions_ET_nonan(20) = nan; % this trigger was not sent
                    videos_ET_nonan(10) = nan; % this trigger was not sent
                    conditions_ET_nonan(10) = nan; % this trigger was not sent
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))
            elseif strcmp(subj, "NLP18")
                if deleted_yet == 0
                    videos_ET_nonan(20) = nan; % this trigger was not sent as the experiment was paused, therefore out.
                    conditions_ET_nonan(20) = nan;
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))
            elseif strcmp(subj, "NLP20")
                if deleted_yet == 0
                    videos_ET_nonan(13) = nan; % this trigger was not sent as the experiment was paused, therefore out.
                    conditions_ET_nonan(13) = nan;
                    videos_ET_nonan(14) = nan; % this trigger was not sent as the experiment was paused, therefore out.
                    conditions_ET_nonan(14) = nan;
                    videos_ET_nonan(26) = nan; % this trigger was not sent as the experiment was paused, therefore out.
                    conditions_ET_nonan(26) = nan;
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))
            elseif strcmp(subj, "NLP21")
                if deleted_yet == 0
                    videos_ET_nonan(18) = nan; % this trigger was not sent as the experiment was paused, therefore out.
                    conditions_ET_nonan(18) = nan;
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))
            elseif strcmp(subj, "NLP22")
                if deleted_yet == 0
                    videos_ET_nonan(1) = nan; % This video was paused, therefore out.
                    conditions_ET_nonan(1) = nan; % This video was paused, therefore out.
                    videos_ET_nonan(end) = nan; % This video was paused, therefore out.
                    conditions_ET_nonan(end) = nan; % This video was paused, therefore out.
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))
            elseif strcmp(subj, "NLP23")
                if deleted_yet == 0
                    videos_ET_nonan(13) = nan; % This video was paused, therefore out.
                    conditions_ET_nonan(13) = nan; % This video was paused, therefore out.
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))
            elseif  strcmp(subj, "NLP33")
                if deleted_yet == 0
                    videos_ET_nonan(25) = nan; % This video was paused, therefore out.
                    conditions_ET_nonan(25) = nan; % This video was paused, therefore out.
                    videos_ET_nonan(26) = nan; % This video was paused, therefore out.
                    conditions_ET_nonan(26) = nan; % This video was paused, therefore out.
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))

            elseif  strcmp(subj, "NLP37")
                if deleted_yet == 0
                    videos_ET_nonan(6) = nan; % This video was not played
                    conditions_ET_nonan(6) = nan; % This video was not played

                    videos_ET_nonan(14) = nan; % This video was not played
                    conditions_ET_nonan(14) = nan; % This video was not played
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))
            elseif  strcmp(subj, "NLP39")
                if deleted_yet == 0
                    videos_ET_nonan(end) = []; % This video was paused, therefore out.
                    conditions_ET_nonan(end) = []; % This video was paused, therefore out.
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))
            elseif  strcmp(subj, "NLP47")
                if deleted_yet == 0
                    videos_ET_nonan(7) = NaN; % This video was paused, therefore out.
                    conditions_ET_nonan(7) = NaN; % This video was paused, therefore out.
                    deleted_yet = 1
                end
                videos_ET_nonan = videos_ET_nonan(~isnan(videos_ET_nonan))
                conditions_ET_nonan = conditions_ET_nonan(~isnan(conditions_ET_nonan))
            end
            %%

            triggers_def = zeros(length(trig(:, 1)), 1);
            raw_indiv_newTriggers = raw_indiv;
            % I delete all stimulus information of the new dataset
            raw_indiv_newTriggers.stimulus;
            all_triggers_vector_new = all_triggers_vector;
            all_nonzero_old = all_triggers_vector_new(find(all_triggers_vector_new))
            timings_all_vectors = find(all_triggers_vector_new)
            dif_timings = diff(timings_all_vectors)
            pruebaFoc = [all_nonzero_old, timings_all_vectors]
            all_triggers_vector_new(timings_all_vectors(find(dif_timings <10)+1))= 0;
            timings_all_vectors_no_cond = find(all_triggers_vector_new)
            dif_timings_no_cond = diff(timings_all_vectors_no_cond)
            all_nonzero_no_cond = all_triggers_vector_new(find(all_triggers_vector_new))
            [all_nonzero_no_cond, timings_all_vectors_no_cond]
           
            figure; plot(all_triggers_vector_new)
            all_triggers_vector_mainstim = all_triggers_vector_new;
            dif_timings_mainstim = diff(find(all_triggers_vector_mainstim));
            timings_all_vectors_mainstim = find(all_triggers_vector_mainstim);
            all_triggers_vector_mainstim(timings_all_vectors_mainstim(find(dif_timings_mainstim <100)))= 0; % This includes those triggers that were redundant and also those cases when the video was paused halfway through the presentation (more or less 100 which is half the duration of the videos)
            figure; plot(all_triggers_vector_mainstim);

            %% Keep improving the triggers to interpret the pause
            all_triggers_vector_new_4types = all_triggers_vector_mainstim
            indx_nonz = find(all_triggers_vector_new_4types)
            nonzero_all_Trig = all_triggers_vector_new_4types(indx_nonz)
            dif_time = diff(indx_nonz)
            onsets = all_triggers_vector_new_4types(indx_nonz(dif_time>100));% offsets = all_triggers_vector_new_4types(indx_nonz(dif_time<100));
            num_onsets = all_triggers_vector_mainstim(indx_nonz(dif_time>100));% offsets = all_triggers_vector_new_4types(indx_nonz(dif_time<100));

            if (strcmp(subj, "NLP03") && onsets(k) == 15)
                onsets(13) = [];
                videos_ET_nonan = videos_ET_nonan(end-1)
            elseif (strcmp(subj, "NLP11"))
                onsets(5) = []; % Take out as a pause is interpreted as a trigger
                dif_time(5) = []; % Take out as a pause is interpreted as a trigger
            elseif (strcmp(subj, "NLP10"))
                onsets(20) = []; % Take out as a pause is interpreted as a trigger
                dif_time(20) = []; % Take out as a pause is interpreted as a trigger
                onsets(10) = []; % Take out as a pause is interpreted as a trigger
                dif_time(10) = []; % Take out as a pause is interpreted as a trigger
            elseif (strcmp(subj, "NLP20"))
                onsets(27) = []; % Take out as a pause is interpreted as a trigger
                dif_time(27) = []; % Take out as a pause is interpreted as a trigger
                onsets(26) = []; % Take out as a pause is interpreted as a trigger
                dif_time(26) = []; % Take out as a pause is interpreted as a trigger
                onsets(14) = []; % Take out as a pause is interpreted as a trigger
                dif_time(14) = []; % Take out as a pause is interpreted as a trigger
                onsets(13) = []; % Take out as a pause is interpreted as a trigger
                dif_time(13) = []; % Take out as a pause is interpreted as a trigger
                onsets(23) = []; % Take out as a pause is interpreted as a trigger
                dif_time(23) = []; % Take out as a pause is interpreted as a trigger
            elseif (strcmp(subj, "NLP23"))
                onsets(13) = [];
                dif_time(13) = []; % Take out as a pause is interpreted as a trigger
                indx_nonz(13) = [];
                onsets(end+1) = 170;
            elseif (strcmp(subj, "NLP22"))
                onsets(end) = []; % Take out as a pause is interpreted as a trigger
                dif_time(end) = []; % Take out as a pause is interpreted as a trigger
            elseif (strcmp(subj, "NLP37"))
                onsets(8) = []; % Take out as a pause is interpreted as a trigger
            elseif (strcmp(subj, "NLP47"))
                onsets(7:8) = [];
                dif_time(7:8) = [];
            end
            onsets_old = onsets;
            for k = 1:length(onsets)
                onsets(k) ==  videos_ET_nonan(k)
                if conditions_ET_nonan(k) == 1 % clear condition
                    onsets(k)= 150
                elseif conditions_ET_nonan(k) == 2 % vocoded condition
                    onsets(k)= 170
                end
            end
            % When comparing onsets to videos_ET, one missing at the end.. adding it manually
            if (strcmp(subj, "NLP23"))
                all_triggers_vector_new_4types([indx_nonz(dif_time>100); indx_nonz(end)])  = onsets;
                all_triggers_vector_new_4types(indx_nonz(dif_time<100)) = 500; % Offsets
                idx = find(all_triggers_vector_new_4types);
                all_triggers_vector_new_4types(idx(13)) = 0;
                all_triggers_vector_mainstim(idx(13))= 0
            elseif (strcmp(subj, "NLP37"))
                % Even if I take out the onsets, the number continues to be
                % present in all_triggers_vector, take out manually.
                var =  indx_nonz(dif_time>100)
                dif_time(8) = 0;
                indx_nonz = find(all_triggers_vector_new_4types)
                all_triggers_vector_new_4types(indx_nonz(dif_time>100)) = onsets;
                all_triggers_vector_new_4types(indx_nonz(dif_time<100)) = []; % Offsets
                idx = find(all_triggers_vector_new_4types);
            elseif (strcmp(subj, "NLP39"))
                all_triggers_vector_new_4types(indx_nonz(dif_time>100)) = onsets;
                all_triggers_vector_new_4types(indx_nonz(dif_time<100)) = 500; % Offsets
            else
                all_triggers_vector_new_4types(indx_nonz(dif_time>100)) = onsets;
                all_triggers_vector_new_4types(indx_nonz(dif_time<100)) = NaN; % Offsets
            end
            figure; plot(all_triggers_vector_new_4types);

            % New incorporation to the code, see if it does not work with other participants...
             figure; plot(all_triggers_vector_mainstim);
            
             %% Simplify triggers to conditions: clear and vocoded
             raw_indiv.draw;
             raw_indiv_4triggers = raw_indiv;
             % nirs.viz.TimeSeriesViewer(raw_indiv)
             raw_indiv.draw;
             raw_indiv_4triggers.stimulus('clear') = raw_indiv_4triggers.stimulus('channel_1');
             raw_indiv_4triggers.stimulus('clear').onset = raw_indiv_4triggers.stimulus('clear').onset(1)
             raw_indiv_4triggers.stimulus('clear').amp= raw_indiv_4triggers.stimulus('clear').amp(1)
             raw_indiv_4triggers.stimulus('clear').dur = raw_indiv_4triggers.stimulus('clear').dur(1)
             raw_indiv_4triggers.stimulus('vocoded') = raw_indiv_4triggers.stimulus('channel_1');
             raw_indiv_4triggers.stimulus('vocoded').onset = raw_indiv_4triggers.stimulus('vocoded').onset(1);
             raw_indiv_4triggers.stimulus('vocoded').amp = raw_indiv_4triggers.stimulus('vocoded').amp(1);
             raw_indiv_4triggers.stimulus('vocoded').dur = raw_indiv_4triggers.stimulus('vocoded').dur(1);
             cont_clear = 0;
            cont_vocoded = 0;
            deleted_yet = 0;

            for i = 1:size(trig, 2) % 1 = clear, 2 = vocoded
                triggers_clean = find(all_triggers_vector_mainstim==i);
                if ~isempty(triggers_clean)
                    %Changed all_triggers_vector for all_triggers_vector
                    old_triggers = find(all_triggers_vector==i);
                    idx = zeros(length(find(triggers_clean)), 1);
                    for k = 1:length(find(triggers_clean))
                        % Get which onset I want to keep from the stimulus
                        idx(k) = find(old_triggers== triggers_clean(k))
                    end

                    % Exceptions varyng from participant to participant
                    idx_cond = conditions_ET_nonan(find(videos_ET_nonan == i))

                    for kk = 1:length(idx_cond)
                        % Conversion from channel_X triggers to clear and vocoded triggers
                        % These are exceptions in case epochs are noisy, to manually 'delete' them, the i is the trigger number (video number), and it is set in the first or second ...
                        % if or elseif if it is in the first time this video was presneted or in the second
                        if (strcmp(subj, "NLP02") && i == 3) || (strcmp(subj, "NLP02") && i == 6) || (strcmp(subj, "NLP02") && i == 2)|| (strcmp(subj, "NLP03") && i == 5) ...
                                || (strcmp(subj, "NLP03") && i == 1) || (strcmp(subj, "NLP03") && i == 7)|| (strcmp(subj, "NLP05") && i == 4) || (strcmp(subj, "NLP05") && i == 6) ...
                                || (strcmp(subj, "NLP07") && i ==7)|| (strcmp(subj, "NLP07") && i ==9) || (strcmp(subj, "NLP07") && i ==6) || ...
                                (strcmp(subj, "NLP07") && i ==4) || (strcmp(subj, "NLP07") && i ==1) || (strcmp(subj, "NLP09") && i ==2) || (strcmp(subj, "NLP09") && i ==12)...
                                || (strcmp(subj, "NLP09") && i ==6) || (strcmp(subj, "NLP11") && i ==5) || (strcmp(subj, "NLP11") && i ==6) || (strcmp(subj, "NLP12") && i ==4)...
                                || (strcmp(subj, "NLP12") && i ==12)   || (strcmp(subj, "NLP10") && i ==5) || (strcmp(subj, "NLP10") && i ==6) || (strcmp(subj, "NLP16") && i ==12)...
                                || (strcmp(subj, "NLP16") && i ==6)|| (strcmp(subj, "NLP16") && i ==2)...
                                || (strcmp(subj, "NLP16") && i ==3) || (strcmp(subj, "NLP16") && i ==5) || (strcmp(subj, "NLP16") && i ==9) || (strcmp(subj, "NLP16") && i ==14)...
                                || (strcmp(subj, "NLP16") && i ==12) || (strcmp(subj, "NLP17") && i ==6) || (strcmp(subj, "NLP18") && i ==2) || (strcmp(subj, "NLP18") && i ==12) ...
                                || (strcmp(subj, "NLP18") && i ==1) || (strcmp(subj, "NLP20") && i ==12)|| (strcmp(subj, "NLP20") && i ==9)...
                                || (strcmp(subj, "NLP26") && i ==6)|| (strcmp(subj, "NLP26") && i ==13)|| (strcmp(subj, "NLP26") && i ==10)|| (strcmp(subj, "NLP26") && i ==7)...
                                || (strcmp(subj, "NLP26") && i ==1)|| (strcmp(subj, "NLP26") && i ==4)|| (strcmp(subj, "NLP27") && i ==1)...
                                || (strcmp(subj, "NLP27") && i ==14)|| (strcmp(subj, "NLP27") && i ==13) || (strcmp(subj, "NLP28") && i ==3)...
                                || (strcmp(subj, "NLP28") && i ==6)|| (strcmp(subj, "NLP28") && i ==4) || (strcmp(subj, "NLP28") && i ==12)...
                                || (strcmp(subj, "NLP28") && i ==1)|| (strcmp(subj, "NLP28") && i ==10) || (strcmp(subj, "NLP28") && i ==11)...
                                || (strcmp(subj, "NLP28") && i ==7)|| (strcmp(subj, "NLP28") && i ==8)  || (strcmp(subj, "NLP28") && i ==5)...
                                || (strcmp(subj, "NLP31") && i ==7)|| (strcmp(subj, "NLP31") && i ==10)|| (strcmp(subj, "NLP31") && i ==8)...
                                || (strcmp(subj, "NLP31") && i ==11)|| (strcmp(subj, "NLP31") && i ==13)|| (strcmp(subj, "NLP31") && i ==9)...
                                || (strcmp(subj, "NLP31") && i ==3)|| (strcmp(subj, "NLP31") && i ==5)|| (strcmp(subj, "NLP31") && i ==6)...
                                || (strcmp(subj, "NLP31") && i ==14) || (strcmp(subj, "NLP32") && i ==2) || (strcmp(subj, "NLP32") && i ==1)...
                                || (strcmp(subj, "NLP32") && i ==10) || (strcmp(subj, "NLP32") && i ==7) || (strcmp(subj, "NLP32") && i ==11)...
                                || (strcmp(subj, "NLP32") && i ==8) || (strcmp(subj, "NLP32") && i ==12) || (strcmp(subj, "NLP32") && i ==4)...
                                || (strcmp(subj, "NLP32") && i ==3) || (strcmp(subj, "NLP32") && i ==6) || (strcmp(subj, "NLP33") && i ==3)...
                                || (strcmp(subj, "NLP33") && i ==10) || (strcmp(subj, "NLP33") && i ==11)...
                                || (strcmp(subj, "NLP34") && i ==11) || (strcmp(subj, "NLP34") && i ==3)  || (strcmp(subj, "NLP34") && i ==4)...
                                || (strcmp(subj, "NLP34") && i ==13) || (strcmp(subj, "NLP37") && i ==1) ...
                                || (strcmp(subj, "NLP37") && i ==12) || (strcmp(subj, "NLP37") && i ==6) || (strcmp(subj, "NLP37") && i ==5) ...
                                || (strcmp(subj, "NLP41") && i ==7) || (strcmp(subj, "NLP41") && i ==5)  ...
                                || (strcmp(subj, "NLP42") && i ==2)  || (strcmp(subj, "NLP42") && i ==3)|| (strcmp(subj, "NLP42") && i ==6)...
                                || (strcmp(subj, "NLP42") && i ==8) || (strcmp(subj, "NLP42") && i ==7)...
                                || (strcmp(subj, "NLP42") && i ==11) || (strcmp(subj, "NLP42") && i ==10) || (strcmp(subj, "NLP42") && i ==1)...
                                || (strcmp(subj, "NLP42") && i ==12) || (strcmp(subj, "NLP42") && i ==13)...
                                || (strcmp(subj, "NLP42") && i ==14)  || (strcmp(subj, "NLP45") && i ==8) || (strcmp(subj, "NLP45") && i ==11)  ...
                                || (strcmp(subj, "NLP45") && i ==13) || (strcmp(subj, "NLP47") && i ==6) || (strcmp(subj, "NLP47") && i ==5)...
                                || (strcmp(subj, "NLP47") && i ==9)|| (strcmp(subj, "NLP47") && i ==13) || (strcmp(subj, "NLP47") && i ==5)...
                                || (strcmp(subj, "NLP47") && i ==11)...
                                || (strcmp(subj, "NLP38") && i ==2) || (strcmp(subj, "NLP38") && i ==6) ...
                                || (strcmp(subj, "NLP38") && i ==5) || (strcmp(subj, "NLP38") && i ==3) || (strcmp(subj, "NLP38") && i ==9) ...
                                || (strcmp(subj, "NLP38") && i ==13)  || (strcmp(subj, "NLP38") && i ==14)
                            if kk == 1
                                % Do not do anything, therefore 'delete' that trigger as by automatic ways I cannot get rid of it
                            elseif kk == 2
                                if idx_cond(kk) == 1
                                    raw_indiv_4triggers.stimulus('clear').onset(cont_clear+1) = raw_indiv.stimulus(['channel_' num2str(i)]).onset(idx(kk))
                                    raw_indiv_4triggers.stimulus('clear').dur(cont_clear+1) = raw_indiv.stimulus(['channel_' num2str(i)]).dur(idx(kk))
                                    raw_indiv_4triggers.stimulus('clear').amp(cont_clear+1) = raw_indiv.stimulus(['channel_' num2str(i)]).amp(idx(kk))
                                    cont_clear = cont_clear + 1;
                                elseif idx_cond(kk) == 2
                                    raw_indiv_4triggers.stimulus('vocoded').onset(cont_vocoded+1) = raw_indiv.stimulus(['channel_' num2str(i)]).onset(idx(kk))
                                    raw_indiv_4triggers.stimulus('vocoded').dur(cont_vocoded+1) = raw_indiv.stimulus(['channel_' num2str(i)]).dur(idx(kk))
                                    raw_indiv_4triggers.stimulus('vocoded').amp(cont_vocoded+1) = raw_indiv.stimulus(['channel_' num2str(i)]).amp(idx(kk))
                                    cont_vocoded = cont_vocoded + 1;
                                end
                            end
                        elseif (strcmp(subj, "NLP02") && i == 14) || (strcmp(subj, "NLP02") && i == 13) || (strcmp(subj, "NLP08") && i == 11) || (strcmp(subj, "NLP10") && i ==7)...
                                || (strcmp(subj, "NLP10") && i ==10) || (strcmp(subj, "NLP10") && i ==12)  || (strcmp(subj, "NLP16") && i ==6)  || (strcmp(subj, "NLP17") && i ==9) ...
                                || (strcmp(subj, "NLP18") && i ==14)|| (strcmp(subj, "NLP27") && i ==1)|| (strcmp(subj, "NLP27") && i ==7)...
                                || (strcmp(subj, "NLP22") && i ==1)|| (strcmp(subj, "NLP22") && i ==6)...
                                || (strcmp(subj, "NLP33") && i ==14) || (strcmp(subj, "NLP38") && i ==8) || (strcmp(subj, "NLP38") && i ==10)...
                                || (strcmp(subj, "NLP38") && i ==12)|| (strcmp(subj, "NLP38") && i ==7)...
                                || (strcmp(subj, "NLP38") && i ==6) || (strcmp(subj, "NLP38") && i ==1) ...
                                || (strcmp(subj, "NLP39") && i ==3) || (strcmp(subj, "NLP45") && i ==6) || (strcmp(subj, "NLP45") && i ==9)
                            if kk == 1
                                if idx_cond(kk) == 1
                                    raw_indiv_4triggers.stimulus('clear').onset(cont_clear+1) = raw_indiv.stimulus(['channel_' num2str(i)]).onset(idx(kk))
                                    raw_indiv_4triggers.stimulus('clear').dur(cont_clear+1) = raw_indiv.stimulus(['channel_' num2str(i)]).dur(idx(kk))
                                    raw_indiv_4triggers.stimulus('clear').amp(cont_clear+1) = raw_indiv.stimulus(['channel_' num2str(i)]).amp(idx(kk))
                                    cont_clear = cont_clear + 1;
                                elseif idx_cond(kk) == 2
                                    raw_indiv_4triggers.stimulus('vocoded').onset(cont_vocoded+1) = raw_indiv.stimulus(['channel_' num2str(i)]).onset(idx(kk))
                                    raw_indiv_4triggers.stimulus('vocoded').dur(cont_vocoded+1) = raw_indiv.stimulus(['channel_' num2str(i)]).dur(idx(kk))
                                    raw_indiv_4triggers.stimulus('vocoded').amp(cont_vocoded+1) = raw_indiv.stimulus(['channel_' num2str(i)]).amp(idx(kk))
                                    cont_vocoded = cont_vocoded + 1;
                                end
                            elseif kk == 2
                                % Do not do anything, therefore 'delete' that trigger as by automatic ways I cannot get rid of it
                            end
                        else
                            if idx_cond(kk) == 1
                                raw_indiv_4triggers.stimulus('clear').onset(cont_clear+1) = raw_indiv.stimulus(['channel_' num2str(i)]).onset(idx(kk))
                                raw_indiv_4triggers.stimulus('clear').dur(cont_clear+1) = raw_indiv.stimulus(['channel_' num2str(i)]).dur(idx(kk))
                                raw_indiv_4triggers.stimulus('clear').amp(cont_clear+1) = raw_indiv.stimulus(['channel_' num2str(i)]).amp(idx(kk))
                                cont_clear = cont_clear + 1;
                            elseif idx_cond(kk) == 2
                                raw_indiv_4triggers.stimulus('vocoded').onset(cont_vocoded+1) = raw_indiv.stimulus(['channel_' num2str(i)]).onset(idx(kk))
                                raw_indiv_4triggers.stimulus('vocoded').dur(cont_vocoded+1) = raw_indiv.stimulus(['channel_' num2str(i)]).dur(idx(kk))
                                raw_indiv_4triggers.stimulus('vocoded').amp(cont_vocoded+1) = raw_indiv.stimulus(['channel_' num2str(i)]).amp(idx(kk))
                                cont_vocoded = cont_vocoded + 1;
                            end
                            %In this case we are in subject NL02 and I want to take out, therefore I do not do anything, I do not add this onset
                        end
                    end
                end
            end
            raw_indiv_4triggers.stimulus('channel_1') = []; raw_indiv_4triggers.stimulus('channel_2') = []
            raw_indiv_4triggers.stimulus('channel_3') = []; raw_indiv_4triggers.stimulus('channel_4') = []
            raw_indiv_4triggers.stimulus('channel_5') = []; raw_indiv_4triggers.stimulus('channel_6') = []
            raw_indiv_4triggers.stimulus('channel_7') = []; raw_indiv_4triggers.stimulus('channel_8') = []
            raw_indiv_4triggers.stimulus('channel_9') = []; raw_indiv_4triggers.stimulus('channel_10') = []
            raw_indiv_4triggers.stimulus('channel_11') = []; raw_indiv_4triggers.stimulus('channel_12') = []
            raw_indiv_4triggers.stimulus('channel_13') = []; raw_indiv_4triggers.stimulus('channel_14') = []
            raw_indiv_4triggers.stimulus('channel_15') = [];

            %% Pre-processing
            % Check SCI threshold on time and convert to NAN those channels with less than 0.7 SCI
            thresh = 0.7;
            thresh_psp = 0;
            %  thresh_psp = 0.1;
            j = [];
            j = nirs.modules.QT();
            j.qThreshold = thresh; % We require at least 70% of good data in every channel
            j.sciThreshold = thresh;
            j.pspThreshold = thresh_psp; % If I would take it into account, I would add 0.1 as the threshold, 0 as I just want to look at SCI:
            raw_indiv_4triggers.stimulus('clear').onset
            raw_indiv_4triggers.time(end)
            % Why? Because it's marking many channels as bad...
            j.condMask = 'all';
            cutoff = 0.5;
            j.fCut = [cutoff];
            j.windowSec = 5; % We will consider 5-sec windows
            ScansQuality = j.run(raw_indiv_4triggers);
            %% Convert to NAN bad SCI channels for the whole signal
            display(['Bad channels: ' num2str(ScansQuality.qMats.bad_links')])
            bad_chan = ScansQuality.qMats.bad_links
            loss_sci(i) = length(bad_chan);
            raw_indiv_4triggers_nonan = raw_indiv_4triggers;
            raw_indiv_4triggers.data(:, [bad_chan;height(raw_indiv_4triggers.probe.link)/2 + bad_chan]) = nan;
            %% Convert to NAN bad channels manually
            bad_chan_man = [];
            if strcmp(subj, "NLP10")
                % Delete channels  S4-D3,, S8-D5, S7D6, S8-D6
                bad_chan_man = [7, 13, 12, 14]
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP07")
                % Delete channels S8-D6
                bad_chan_man =  14
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP16")
                % Delete channels S3-D3, S4-D3
                bad_chan_man = [5, 7]
                %14, 12
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP18")
                % Delete channels S2-D1, S2-D2, S4-D3?
                bad_chan_man = [2, 3, 7]
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP26")
                % Delete channels S4-D3
                bad_chan_man = [7]
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP27")
                % Delete channels S4-D3, S2-D2
                bad_chan_man = [7, 3]
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP28")
                % Delete channels S5-D4, S6-D4, S3-D3, S2-D2, S4-D3, S4-D2
                bad_chan_man = [8, 9, 5, 3, 7, 6]
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP31")
                % Delete channels S5-D4, S3-D2, S4-D2, S2-D2
                bad_chan_man = [8, 4, 6]
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP32")
                % Delete channels S1D1, S2-D1, S2-D2, S3-D2, S3-D3, S8-D6,
                % S4-D3
                bad_chan_man = [1, 2, 3, 4, 5, 14, 28, 7]
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP33")
                % Delete channels s3d3, s4d3, s7d6, S8D6
                bad_chan_man = [5, 7, 12, 14];
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP36")
                % Delete channels s7d6, s8d6
                bad_chan_man = [12, 14];
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP38")
                % Delete channels s5d4, s8d6
                bad_chan_man = [8];
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP37")
                % Delete channels s7d6, s4d3, s2d2
                bad_chan_man = [12, 7, 3];
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
            if strcmp(subj, "NLP42")
                % Delete channels s1d1, s2d1, s4d3,
                bad_chan_man = [1, 2, 7];
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
            end
             if strcmp(subj, "NLP48")
                % Delete channels s8d5, S7D6, S6D5, S8D6, S2D2
                bad_chan_man = [13, 12, 10, 14, 3];
                raw_indiv_4triggers.data(:, [bad_chan_man;height(raw_indiv_4triggers.probe.link)/2 + bad_chan_man]) = nan;
             end

             %% Conversion to OD
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
            preprocess3 = nirsGUI.modules.LowPassFilter(preprocess3); preprocess3.CutOffFrequency = 0.25; %0.20 ; % Est. heartrate responses as low as 0.5 Hz, and other autonimic responses down to 0.15
            preprocess3 = nirsGUI.modules.HighPassFilter(preprocess3); preprocess3.CutOffFrequency = 0.01;
            
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

            %% Plot all epochs together
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

            %% Plot epochs
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

            
            
            %% Check which triggers were deleted after all the steps
            %% Compare ORIGINAL triggers vs FINAL CLEANED triggers
            % Insert this block right before `save(filename, 'epoched_conc_OD')`
            % Requires: raw_indiv_ORIGINAL (snapshot taken right after loadNIRx, before
            % any manual edits) and raw_indiv_4triggers (final cleaned clear/vocoded stims)
            
            tol_sec = 1.0; % tolerance (in seconds) to consider an onset "the same" trigger
            
            %% 1. Collect ALL original onsets (channel_1 ... channel_n) with times + labels
            orig_onsets = [];
            orig_labels = {};
            n_chan_trig = n_trigs; % from earlier in the script
            for kk = 1:n_chan_trig
                stim_name = ['channel_' num2str(kk)];
                if ~isempty(raw_indiv_ORIGINAL.stimulus(stim_name))
                    ons = raw_indiv_ORIGINAL.stimulus(stim_name).onset;
                    for k = 1:length(ons)
                        orig_onsets(end+1,1) = ons(k); %#ok<AGROW>
                        orig_labels{end+1,1} = stim_name; %#ok<AGROW>
                    end
                end
            end
            [orig_onsets, sortIdx] = sort(orig_onsets);
            orig_labels = orig_labels(sortIdx);
            
            %% 2. Collect FINAL cleaned onsets (clear + vocoded)
            final_onsets = [];
            final_labels = {};
            if ~isempty(raw_indiv_4triggers.stimulus('clear'))
                ons = raw_indiv_4triggers.stimulus('clear').onset;
                final_onsets = [final_onsets; ons(:)];
                final_labels = [final_labels; repmat({'clear'}, numel(ons), 1)];
            end
            if ~isempty(raw_indiv_4triggers.stimulus('vocoded'))
                ons = raw_indiv_4triggers.stimulus('vocoded').onset;
                final_onsets = [final_onsets; ons(:)];
                final_labels = [final_labels; repmat({'vocoded'}, numel(ons), 1)];
            end
            [final_onsets, sortIdx] = sort(final_onsets);
            final_labels = final_labels(sortIdx);
            
            %% 3. Match original onsets to final onsets within tolerance
            n_orig = length(orig_onsets);
            matched = false(n_orig, 1);
            matched_to = strings(n_orig, 1);
            
            for i = 1:n_orig
                d = abs(final_onsets - orig_onsets(i));
                [minD, idxMin] = min(d);
                if ~isempty(minD) && minD <= tol_sec
                    matched(i) = true;
                    matched_to(i) = final_labels{idxMin};
                end
            end
            
%             %% 4. Build a report table
%             deleted_idx = find(~matched);
%             kept_idx = find(matched);
%             
%             report = table(final_onsets, final_labels, ...
%                 'VariableNames', {'final_time_sec', 'final_channel'});
%             
%             disp(['Subject: ' subj]);
%             disp(['Total original triggers: ' num2str(n_orig)]);
%             disp(['Kept (matched to clear/vocoded): ' num2str(numel(kept_idx))]);
%             disp(['Deleted: ' num2str(numel(deleted_idx))]);
%             disp('--- Deleted triggers ---');
%             disp(report(deleted_idx, :));
%             
%             %% 5. Save the report alongside the cleaned data
%             cd(path_data_preprocessed)
%             report_filename = ['trigger_report_clean_' char(indiv) '.mat'];
%             save(report_filename, 'report');
%             writetable(report, ['trigger_report_clean' char(indiv) '.csv']);
%             
%             %% Create the legend after all lines are processed
%             legend(legendHandles, legendEntries, 'Location', 'best');
%             % List of participants' datasets
%             epoched_conc_OD.description = subj;
%             
            %% Save data into master participants matrix
            participants{contt} =epoched_conc_OD; % Replace with actual data objects
            
            cd(path_data_preprocessed)
            filename = ['clean_' char(indiv) '.mat']
            save(filename, 'epoched_conc_OD')
        end
    end
end

%% Save participant dataset
cd(path_data)
save('NIRS_participants_07_09_2026.mat', 'participants')


%% Check auxillary data maps the 'clean' events
aux = raw_indiv.auxillary;      % run this on the object right after loadNIRx
class(aux)
keys = aux.keys
for i = 1:numel(keys)
    a = aux(keys{i});
    fprintf('%s: class=%s, size=%s\n', keys{i}, class(a), mat2str(size(a)));
    if isobject(a) || isstruct(a), disp(a); end
end
size(raw_indiv.data), numel(raw_indiv.time)
%% Load participant dataset
%cd(path_data)
% participants = load('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data/NIRS_participants_19_05.mat');
%participants = load('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data/NIRS_participants_21_09_2026.mat');
%participants = participants.participants;

participants = dir(fullfile(path_data_preprocessed, 'clean*'))

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
set(0,'DefaultFigureVisible','on')

% Took out nlp01 (other montage) and nlp12 (bad quality)
% n = 30 included, the ones useed for statistics
% selection        = {'NLP02','NLP03','NLP04','NLP06','NLP07','NLP08','NLP09',...
%     'NLP10','NLP11','NLP13','NLP14','NLP15','NLP17','NLP18','NLP19','NLP20',...
%     'NLP21','NLP22','NLP23','NLP24','NLP25','NLP26','NLP27','NLP31',...
%     'NLP33', 'NLP35', 'NLP36', 'NLP37', 'NLP39', 'NLP45'}; 
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

participants = dir(fullfile(path_data_preprocessed, 'clean*'))

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

% n = 21 excellent
selection_excellent = {'NLP03','NLP08','NLP09',...
   'NLP11','NLP13','NLP14','NLP15','NLP17','NLP19','NLP20',...
    'NLP21','NLP22','NLP23','NLP25','NLP27','NLP31',...
    'NLP33', 'NLP35', 'NLP37', 'NLP39', 'NLP45'}; 
selection = selection_excellent;

nChannels = 14;
nParticipants = length(selection);

matrix_all_HbR_voc = cell(nChannels, 0);
matrix_all_HbO_voc = cell(nChannels, 0);
matrix_all_HbR_clear = cell(nChannels, 0);
matrix_all_HbO_clear = cell(nChannels, 0);

positions = nan(nChannels, 4); % Preallocate for axes positions
% Comment below if needed
subjCounter = 0; 
% Comment above if needed
for kk = 1:length(participants)
    epoched_conc_OD = load(participants(kk).name);
    epoched_conc_OD = epoched_conc_OD.epoched_conc_OD;
    subj_id = participants(kk).name;
    subj_id = subj_id(end-8:end-4);

    if ismember(subj_id, selection)
        % Comment below if needed
        subjCounter = subjCounter + 1;  
        % Comment above if needed
        
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
                        matrix_all_HbR_voc{ch, subjCounter} = y;
                    case contains(label, 'vocoded (hbo)')
                        matrix_all_HbO_voc{ch, subjCounter} = y;
                    case contains(label, 'clear (hbr)')
                        matrix_all_HbR_clear{ch, subjCounter} = y;
                    case contains(label, 'clear (hbo)')
                        matrix_all_HbO_clear{ch, subjCounter} = y;
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

size(positions)
length(ep.EpochAxes)
positions

for ch = 1:nChannels
    ax = axes('Position', positions(ch, :));
    hold(ax, 'on');

    HbR_voc = stack_row(matrix_all_HbR_voc(ch, :));
    HbO_voc = stack_row(matrix_all_HbO_voc(ch, :));
    HbR_clear = stack_row(matrix_all_HbR_clear(ch, :));
    HbO_clear = stack_row(matrix_all_HbO_clear(ch, :));
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
        ylim([-20, 65])
    end
    if ~isempty(HbO_voc)
        HbO_voc_mean = mean(HbO_voc, 1);
        HbO_voc_std = std(HbO_voc, [], 1);
        fill(ax, [x fliplr(x)], [HbO_voc_mean+HbO_voc_std fliplr(HbO_voc_mean-HbO_voc_std)], colors.HbO_voc, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
        plot(ax, x, HbO_voc_mean, 'Color', colors.HbO_voc, 'LineWidth', 2);
        ylim([-20, 65])
    end
    if ~isempty(HbR_clear)
        HbR_clear_mean = mean(HbR_clear, 1);
        HbR_clear_std = std(HbR_clear, [], 1);
        fill(ax, [x fliplr(x)], [HbR_clear_mean+HbR_clear_std fliplr(HbR_clear_mean-HbR_clear_std)], colors.HbR_clear, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
        plot(ax, x, HbR_clear_mean, 'Color', colors.HbR_clear, 'LineWidth', 2);
        ylim([-20, 65])
    end
    if ~isempty(HbO_clear)
        HbO_clear_mean = mean(HbO_clear, 1);
        HbO_clear_std = std(HbO_clear, [], 1);
        fill(ax, [x fliplr(x)], [HbO_clear_mean+HbO_clear_std fliplr(HbO_clear_mean-HbO_clear_std)], colors.HbO_clear, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
        plot(ax, x, HbO_clear_mean, 'Color', colors.HbO_clear, 'LineWidth', 2);
        ylim([-20, 65])
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

save('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/NIRS/matrix_all_HbO_clear.mat', 'matrix_all_HbO_clear')
save('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/NIRS/matrix_all_HbR_clear.mat', 'matrix_all_HbR_clear')
save('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/NIRS/matrix_all_HbO_voc.mat', 'matrix_all_HbO_voc')
save('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/NIRS/matrix_all_HbR_voc.mat', 'matrix_all_HbR_voc')


% % Store all individual participant data used for the group mean
% groupData = struct();
% 
% groupData.ID = selection(1:subjCounter);
% 
% for ch = 1:nChannels
%     
%     HbR_voc = matrix_all_HbR_voc(ch, :);
%     HbR_voc = HbR_voc(~cellfun(@isempty, HbR_voc));
%     HbR_voc = vertcat(HbR_voc{:});
%     
%     HbO_voc = matrix_all_HbO_voc(ch, :);
%     HbO_voc = HbO_voc(~cellfun(@isempty, HbO_voc));
%     HbO_voc = vertcat(HbO_voc{:});
%     
%     HbR_clear = matrix_all_HbR_clear(ch, :);
%     HbR_clear = HbR_clear(~cellfun(@isempty, HbR_clear));
%     HbR_clear = vertcat(HbR_clear{:});
%     
%     HbO_clear = matrix_all_HbO_clear(ch, :);
%     HbO_clear = HbO_clear(~cellfun(@isempty, HbO_clear));
%     HbO_clear = vertcat(HbO_clear{:});
%     
%     % Time axis
% %     if ~isempty(groupData(ch).HbR_voc)
% %         nTime = size(groupData(ch).HbR_voc, 2);
% %     elseif ~isempty(groupData(ch).HbO_voc)
% %         nTime = size(groupData(ch).HbO_voc, 2);
% %     elseif ~isempty(groupData(ch).HbR_clear)
% %         nTime = size(groupData(ch).HbR_clear, 2);
% %     else
% %         nTime = size(groupData(ch).HbO_clear, 2);
% %     end
% 
%     %groupData(ch).time = linspace(-5, 30, nTime);
%     
%     % Group means
%     groupData(ch).HbR_voc   = HbR_voc;
%     groupData(ch).HbO_voc   = HbO_voc;
%     groupData(ch).HbR_clear = HbR_clear;
%     groupData(ch).HbO_clear = HbO_clear;
%     
%     % and calculate the means:
%     groupData(ch).HbR_voc_mean   = mean(HbR_voc, 1);
%     groupData(ch).HbO_voc_mean   = mean(HbO_voc, 1);
%     groupData(ch).HbR_clear_mean = mean(HbR_clear, 1);
%     groupData(ch).HbO_clear_mean = mean(HbO_clear, 1);
%     
% end
% writetable('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/NIRS/group_results.csv', 'groupData');

function stacked = stack_row(cellRow)
    nonEmptyIdx = ~cellfun(@isempty, cellRow);
    validData = cellRow(nonEmptyIdx);

    if isempty(validData)
        stacked = [];
        return
    end

    lens = cellfun(@length, validData);
    minLen = min(lens);

    truncated = cellfun(@(v) v(1:minLen), validData, 'UniformOutput', false);
    stacked = cell2mat(truncated(:));
end


