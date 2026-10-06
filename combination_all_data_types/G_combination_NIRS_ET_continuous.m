clc; clear all;close all;
set(0,'DefaultFigureVisible','off')
path_data =  '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data';
addpath(genpath(path_data));
toolbox_path = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/fNIRS/nirs-toolbox-master 2';
addpath(genpath(toolbox_path));
path_data_preprocessed = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data_preprocessed/fNIRS';
addpath(genpath(path_data_preprocessed));
path_NIRS_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/NIRS_ET_DATASETS';
addpath(genpath(path_NIRS_ET));

files = dir(fullfile(path_data_preprocessed, 'clean_*'));
files_auxvalid = dir(fullfile(path_data_preprocessed, 'auxvalid_*'));
cd(path_data_preprocessed)

% n = 21 excellent
selection_excellent = {'clean_NLP03.mat','clean_NLP08.mat','clean_NLP09.mat',...
    'clean_NLP11.mat','clean_NLP13.mat','clean_NLP14.mat','clean_NLP15.mat','clean_NLP17.mat','clean_NLP19.mat','clean_NLP20.mat',...
    'clean_NLP21.mat','clean_NLP22.mat','clean_NLP23.mat','clean_NLP25.mat','clean_NLP27.mat','clean_NLP31.mat',...
    'clean_NLP33.mat', 'clean_NLP35.mat', 'clean_NLP37.mat', 'clean_NLP39.mat', 'clean_NLP45.mat'};


participants_selection = {};
cont = 0;
for t=1:length(files)
    if ismember({files(t).name}, selection_excellent)
        cont = cont + 1;
        participants_selection{cont} = files(t);
    end
end

%ET_data = readtable('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/results/ET/master_info_trial_ET.csv');

%ET_participant = load('/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/Data_processing/ET/continuous_ET_NLP03.mat');
%ET_participant = ET_participant.y_in_all_blocks;
path_data_preprocessed_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/Data_processing/ET';
files_ET = dir(fullfile(path_data_preprocessed_ET, 'continuous_*'));

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
raw_indiv = [];
ET_trials_not_in_fNIRS = [];
for tt=1:length(files_ET)
    close all;
    ET_trials_not_in_fNIRS = []
    ET_participant = [];
    PTLT_clear = [];
    PTLT_vocoded = [];
    ET_included= [];
    ET_PTLT_included = [];
    cond_original = [];
    raw_indiv = [];
    
    % Create average PTLT per subject
    idx_clear_PTLT = find(cond_original==1);
    idx_voco_PTLT = find(cond_original==2);
    
    
    % Obtain the name without the previous fNIRS info
    name_fnirs = files_ET(tt).name(end-8:end);
    name_alone = files_ET(tt).name(15:19)
    
    % Match with the ET data
    [boo, idx_ET] = ismember(['clean_' name_fnirs], {files(:).name});
    
    
    if ismember({['clean_' name_fnirs]}, selection_excellent) && boo == 1
        
        % Step 1: To each NIRS trial, attach an extra variable named
        % ET continuous (downsampled to the NIRS sampling rate) and another
        % variable called EEG.
        % Step 5: run TRF on NIRS data with ET continuous data.
        
        raw_indiv = load([path_data_preprocessed '/' files(idx_ET).name]);
        raw_indiv = raw_indiv.epoched_conc_OD;
        
        auxvalid = load([path_data_preprocessed '/' files_auxvalid(idx_ET).name]);
        auxvalid = auxvalid.aux_valid;
        
        clear_trig = [raw_indiv.stimulus('clear').onset', ones(length(raw_indiv.stimulus('clear').onset), 1)];
        voco_trig = [raw_indiv.stimulus('vocoded').onset', 2*ones(length(raw_indiv.stimulus('vocoded').onset), 1)];
        
        all_trig = [clear_trig; voco_trig];
        [sorted, idx] = sort(all_trig);
        sorted(:, 2) = sorted(idx(:, 1), 2);
        
        % Load ET data
        ET_participant = load([path_data_preprocessed_ET, '/', files_ET(tt).name]);
        report_ET = ET_participant.continuous_info{1};
        
        % Load original triggers:
        original_trig_indiv = dir(fullfile([path_original_data '/' name_alone '/ET'], '*.csv'))
        conditions_ET = readtable(original_trig_indiv.name);
        
        videos_id_original =conditions_ET.trig(~isnan(conditions_ET.trig));
        cond_original =conditions_ET.cond(~isnan(conditions_ET.cond));
      
        if strcmp(conditions_ET.condition_file(end), "")
        cond_original(end) = []
        end
        % Check visually the original ET triggers and the nirs triggers
        sorted;
        cond_original;
        raw_indiv.draw
        
        
        %ET_included = ET_participant.continuous_info{2};
        ET_PTLT_included = ET_participant.continuous_info{1};
        ET_PTLT_included = ET_PTLT_included.PTLT;
        
        if strcmp(name_alone, 'NLP03')
            ET_trials_not_in_fNIRS = [4, 11, 16, 17];
            %ET_included(ET_trials_not_in_fNIRS) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        elseif strcmp(name_alone, 'NLP08')
            ET_trials_not_in_fNIRS = [19, 22];
            %ET_included(19) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        elseif strcmp(name_alone, 'NLP09')
            ET_trials_not_in_fNIRS = [7, 8];
            %ET_included(ET_trials_not_in_fNIRS) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        elseif strcmp(name_alone, 'NLP11')
            ET_trials_not_in_fNIRS = [4, 22];
            %ET_included(4) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        elseif strcmp(name_alone, 'NLP17')
            ET_trials_not_in_fNIRS = [13];
            %ET_included(ET_trials_not_in_fNIRS) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        elseif strcmp(name_alone, 'NLP22')
            ET_trials_not_in_fNIRS = [1, 27];
            %ET_included(ET_trials_not_in_fNIRS) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        elseif strcmp(name_alone, 'NLP27')
            ET_trials_not_in_fNIRS = [2, 8, 18];
            %ET_included(ET_trials_not_in_fNIRS) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        elseif strcmp(name_alone, 'NLP31')
            ET_trials_not_in_fNIRS = [4, 5, 6, 7, 8, 9, 10, 11, 12];
            %ET_included(ET_trials_not_in_fNIRS) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        elseif strcmp(name_alone, 'NLP33')
            ET_trials_not_in_fNIRS = [4, 8, 10, 22, 25];
            %ET_included(ET_trials_not_in_fNIRS) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        elseif strcmp(name_alone, 'NLP37')
            ET_trials_not_in_fNIRS = [5, 6, 7, 8, 11, 14];
            %ET_included(ET_trials_not_in_fNIRS) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        elseif strcmp(name_alone, 'NLP39')
            ET_trials_not_in_fNIRS = [21];
            %ET_included(ET_trials_not_in_fNIRS) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        elseif strcmp(name_alone, 'NLP45')
            ET_trials_not_in_fNIRS = [6, 9, 11, 16];
            %ET_included(ET_trials_not_in_fNIRS) = [];
            ET_PTLT_included(ET_trials_not_in_fNIRS) = [];
        end
        

        cond_original(ET_trials_not_in_fNIRS) = [];
        
        % Create average PTLT per subject
        idx_clear_PTLT = find(cond_original==1);
        idx_voco_PTLT = find(cond_original==2);
        
        PTLT_clear = mean(ET_PTLT_included(idx_clear_PTLT));
        PTLT_vocoded = mean(ET_PTLT_included(idx_voco_PTLT));
        
        %% How auxillary is organised

        save([path_NIRS_ET '/NIRS_ET_dataset_' name_alone '.mat'], 'raw_indiv', 'ET_PTLT_included','PTLT_clear','PTLT_vocoded', 'cond_original', 'auxvalid')
    end
end

% for NLP03: Tril 4, 11, 16, 17
% for NLP08: Trial 19, 22 from ET out, as there is no fNIRS trial there.
% for NLP09: Trial 7, 8, 9 from ET out
% for NLP11: Trial 4, 22
% for NLP13: all in.
% for NLP14: 16 out for ET
% for NLP17: 13, 24
% for NLP19: all in
% for NLP20: something strange happening,,, recheck
% for NLP21: out 18
% for NLP22: out 1, 27, 28
% for NLP23: out 13
% for NLP25: all in
% for NLP27: 2, 8, 18
% for NLP31: 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
% for NLP33: 4, 8, 10, 22, 25, 26
% for NLP35: 13
% for NLP37: out 5, 6, 7, 8, 11, 14
% for NLP39: out 21
% for NLP45: out 6, 9, 11, 16, 24


%%
path_NIRS_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/NIRS_ET_DATASETS';
name_dataset = dir(fullfile(path_NIRS_ET,'NIRS_ET*'))
a= load(name_dataset(1).name)

a.raw_indiv.draw