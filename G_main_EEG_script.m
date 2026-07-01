%% EEG analysis for Neurolip
%% Add paths
clc;
clear all;
close all;
restoredefaultpath
pathhome= '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/NEUROLIP_updated/data_centralised';
addpath(genpath(pathhome));
%addpath '/Users/irenearrietasagredo/Dropbox/UPC POSTDOC/Code/fieldtrip-20181231'
addpath '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/EEG/fieldtrip-20260511'
path_tobii = ['/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/fNIRS/TobiiPro.SDK.Matlab_1.11.0.1']
addpath(genpath(path_tobii));
path_scripts = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/Scripts_github'
addpath(path_scripts);
path_data = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data'
addpath(genpath(path_data));
path_data_preprocessed = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed'
addpath(genpath(path_data_preprocessed));
path_data_ET = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/data'
addpath(genpath(path_data_ET));
path_stimuli = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/trial711_PSYCHOPY_GOOD/stimuli'
addpath(genpath(path_stimuli));
path_figures_coherence = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/EEG/Coherence';
addpath(genpath(path_figures_coherence));
%path_code_EEG = '/Users/irenearrietasagredo/Dropbox/UPC POSTDOC/Projects/NEUROLIP/Data_processing';
%addpath(genpath(path_code_EEG));
path_combined_data = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/NEUROLIP-IDLCP/Data_processing/EEG/combined_data';
addpath(genpath(path_combined_data));
% Initialise fieldtrip
ft_defaults
%%
% To start, select manually path of a subject, Specify the Configuration

set(0,'DefaultFigureVisible','off')

cd(path_combined_data)
num_subj = dir('NLP*');

images_yes = false;
data_combined = [];
% Creation of one dataset with all participant data
dataEEG_detrend.fsample = 10000; % Add it manually for the first time it is run

data_combined_all = {[]};
cont = 1;

all_participants = struct();
cd(path_data)

num_subj = dir('NLP*');
subjects_name = {num_subj(:).name};
for jj = 1:1%length(num_subj)

    display(subjects_name(jj));
    pause(0.5)

    if(jj==2 || jj==10 || jj==21 || jj == 44 || jj == 46|| jj == 47) % 46 is strange, recheck
        % Not recorded data
    else
        path_file = [];

        indiv = subjects_name(jj)
        path_file_eeg = strcat(path_data,filesep,indiv, filesep, 'EEG')
        cd(char(path_file_eeg))
        name_file = dir('*.eeg');
        cd(path_scripts)
        [data_combined, theoretical_cond, theoretical_triggers] = G_combining3_EEG(name_file, path_data, path_file_eeg, path_stimuli, indiv, dataEEG_detrend, images_yes)
        
        [data_preprocessed] = G_preprocessing2_EEG(data_combined, jj)

        [data_preprocessed_epoched] = G_epoching_EEG(data_preprocessed, theoretical_triggers, theoretical_cond)
        
        name = subjects_name{jj};
        cd(path_data_preprocessed)
        filename = ['not_epoched_prep_' char(indiv) '.mat']
        save(filename, 'data_preprocessed')
    end
end

