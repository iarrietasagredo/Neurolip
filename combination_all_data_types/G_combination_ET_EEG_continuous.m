clc; clear all;close all;
set(0,'DefaultFigureVisible','on')
path_data =  '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data';
addpath(genpath(path_data));
path_data_preprocessed = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed';
addpath(genpath(path_data_preprocessed));
path_EEG_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/EEG_ET_DATASETS';
addpath(genpath(path_EEG_ET));
addpath '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/EEG/fieldtrip-20260511'
path_NIRS_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/NIRS_ET_DATASETS';
addpath(genpath(path_NIRS_ET));
path_EEG_NIRS_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/EEG_NIRS_ET_DATASETS';
addpath(genpath(path_NIRS_ET));
%%
files = dir(fullfile(path_data_preprocessed, 'clean_*'));

files_nirs_et = dir(fullfile(path_NIRS_ET, 'NIRS_ET_*'));

% n = 21 excellent
%selection_excellent = {'clean_NLP03.mat','clean_NLP08.mat','clean_NLP09.mat',...
%    'clean_NLP11.mat','clean_NLP13.mat','clean_NLP14.mat','clean_NLP15.mat','clean_NLP17.mat','clean_NLP19.mat','clean_NLP20.mat',...
%    'clean_NLP21.mat','clean_NLP22.mat','clean_NLP23.mat','clean_NLP25.mat','clean_NLP27.mat','clean_NLP31.mat',...
%    'clean_NLP33.mat', 'clean_NLP35.mat', 'clean_NLP37.mat', 'clean_NLP39.mat', 'clean_NLP45.mat'};

%participants_selection = {};
%cont = 0;
%for t=1:length(files)
%    if ismember({files(t).name}, selection_excellent)
%        cont = cont + 1;
%        participants_selection{cont} = files(t);
%    end
%end

%ET_data = readtable('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/ET/master_info_trial_ET.csv');

%ET_participant = load('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/Data_processing/ET/continuous_ET_NLP03.mat');
%ET_participant = ET_participant.y_in_all_blocks;
files_ET = dir(fullfile('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/Data_processing/ET', 'continuous_*'));

path_original_data = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data';
original_triggers = dir(fullfile(path_original_data, 'NLP*'));

% The way the ET gives the data is starting (as the old TV) by the top left
% therefore, y values that are increasing, are more related to the mouth,
% and those that are decreasing, more to the eyes, therefore, to represent
% it i need to reverse the axis to ressemble a face.

% figure; plot(ET_participant{4})
% set(gca, 'YDir', 'reverse');

% Assuming the start and end of the trials coincide with the start and end
% of the fNIRS triggers

PTLT_clear = [];
PTLT_vocoded = [];
ET_included= [];
ET_PTLT_included = [];
cond_original = [];
eeg = [];
ET_trials_not_in_EEG = [];

found_nirs = 0;
for tt=1:length(files_ET)
    
    close all;
    ET_trials_not_in_fNIRS = []
    ET_participant = [];
    PTLT_clear = [];
    PTLT_vocoded = [];
    ET_included= [];
    ET_PTLT_included = [];
    cond_original = [];
    eeg = [];
    
    found_nirs = 0;
    
    % Create average PTLT per subject
    idx_clear_PTLT = find(cond_original==1);
    idx_voco_PTLT = find(cond_original==2);

    % Obtain the name without the previous fNIRS info
    name = files_ET(tt).name(end-8:end);
    name_alone = files_ET(tt).name(15:19)
    
    % Match with the ET data
    [boo, idx_ET] = ismember(['clean_not_epoched_prep_' name], {files(:).name})

    if boo == 1
        % OBJECTIVE NEXT:
        % Step 3: run TRF on NIRS data with ET continuous data.
        
        eeg = load([path_data_preprocessed '/' files(idx_ET).name]);
        eeg = eeg.data_epoched_clean;

        sorted = eeg.cond'
        original_trials = eeg.original_trial'
        
        % Load ET data
        ET_participant = load(['/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/Data_processing/ET/' files_ET(tt).name]);
        report_ET = ET_participant.continuous_info{1};

        % Load original triggers:
        original_trig_indiv = dir(fullfile([path_original_data '/' name_alone '/ET'], '*.csv'))
        conditions_ET = readtable(original_trig_indiv.name);
        
        if strcmp(name_alone, 'NLP05')
            conditions_ET.trig =str2double(string(conditions_ET.trig))
            videos_id_original = conditions_ET.trig(~isnan(conditions_ET.trig));
            conditions_ET.cond = str2double(string(conditions_ET.cond))
            cond_original =conditions_ET.cond(~isnan(conditions_ET.cond));
        else
            videos_id_original = conditions_ET.trig(~isnan(conditions_ET.trig));
            conditions_ET.cond = str2double(string(conditions_ET.cond))
            cond_original =conditions_ET.cond(~isnan(conditions_ET.cond));
        end
        
        if strcmp(conditions_ET.condition_file(end), "") || strcmp(name_alone, 'NLP01')
            cond_original(end) = [];
        end
        
        all_trials = [1:length(cond_original)]
        lost_trials = setdiff(all_trials, original_trials)
        
        % Check visually the original ET triggers and the nirs triggers
        sorted
        original_trials
        cond_original_comp = cond_original;
        cond_original_comp(lost_trials) = []
        sorted
        cond_original_comp
        
        ET_PTLT_included = ET_participant.continuous_info{1};
        ET_PTLT_included = ET_PTLT_included.PTLT;
        
        ET_PTLT_included(lost_trials) = [];

        % Create average PTLT per subject
        idx_clear_PTLT = find(cond_original_comp==1);
        idx_voco_PTLT = find(cond_original_comp==2);
        
        PTLT_clear = mean(ET_PTLT_included(idx_clear_PTLT));
        PTLT_vocoded = mean(ET_PTLT_included(idx_voco_PTLT));

        ET_continuous = ET_participant.continuous_info{2};
        ET_continuous(lost_trials) = [];
        y = {};
        
        eeg.ET_continuous = ET_continuous;
        
        % If NIRS data usable, include in the EEG dataset
        for kk =1:length(files_nirs_et)
            dataset_nirs_et = load(fullfile([path_NIRS_ET '/' files_nirs_et(kk).name]));
            nirs_et_name = files_nirs_et(kk).name;
            nirs_et_name = nirs_et_name(end-8:end-4);
            if found_nirs == 0
                if strcmp(nirs_et_name, name_alone) == 1
                    save([path_EEG_NIRS_ET '/EEG_NIRS_ET_dataset_' name_alone '.mat'], 'eeg', 'ET_PTLT_included','PTLT_clear','PTLT_vocoded', 'cond_original_comp', 'dataset_nirs_et')
                    found_nirs = 1;
                else
                    save([path_EEG_NIRS_ET '/EEG_NIRS_ET_dataset_' name_alone '.mat'], 'eeg', 'ET_PTLT_included','PTLT_clear','PTLT_vocoded', 'cond_original_comp')
                end
            end
        end
        
        
           end
end


%%
path_NIRS_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/NIRS_ET_DATASETS';
name_dataset = dir(fullfile(path_NIRS_ET,'NIRS_ET*'))
a= load(name_dataset(1).name)

a.raw_indiv.draw