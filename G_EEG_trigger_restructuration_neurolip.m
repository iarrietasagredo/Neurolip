function [events_onset, onset, offset, theoretical_triggers, theoretical_cond] = EEG_trigger_restructuration_neurolip(subj, onset, offset, theoretical_triggers, theoretical_cond, dataEEG_detrend, fs, events_onset, path_stimuli)
%path_stimuli = '/Users/experimentos/Desktop/NEUROLIP/trial711_PSYCHOPY_GOOD/stimuli';
%set(0,'DefaultFigureVisible','off')
if strcmp('NLP01', subj)
    % The third block was not presented, so NIRS and EEG were cut before cutting the ET, that's...
    % why the theoretical triggers is one trigger longer for NLP01, delete last
    theoretical_triggers(end) = [];
    theoretical_cond(end) = [];
    % Need to modify one of the trigger numbers, because one condition trigger was not sent and therefore the automatic...
    % search of video number by substracting 2 row positions does not work, I modify the trigger manually
    idx_onsets = find(onset);
    onset(idx_onsets(5)) = 0;
    onset(idx_onsets(5)+ 1) = 1;

    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-12-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 28; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-13-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 56; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';


elseif strcmp('NLP03', subj)
    % The 6th trial in block 1 was not played, therefore out from theoretical triggers
    theoretical_triggers(13) = [];% It is out as it was a pause, therefore I also have to delete from theoretical triggers
    theoretical_cond(13) = [];% It is out as it was a pause, therefore I also have to delete from theoretical triggers

    % There was an error due to the automatic mode, manually change
    onset(75) = 0;
    onset(76) =1;

    % Missing onset and offset on the last trigger
    onset(111) = 1;
    offset(112) = 1;

    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-6-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-8-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 58; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 3 and 4 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-3-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 85; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 4 and end with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-8-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 112; % numbered 6 normally, if not existing, the previous
    gap = 1; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP04', subj)
    % The first two trials were not 'recorded', forgot to click start recording

    theoretical_triggers(12:end) = [];
    theoretical_triggers(1:2) = []; % It is out as it was a pause, therefore I also have to delete from theoretical triggers
    theoretical_cond(12:end) = [];
    theoretical_cond(1:2) = []; % It is out as it was a pause, therefore I also have to delete from theoretical triggers

    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-14-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 22; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %offset(2) = 0; % the logic of setting offset automatically does not work in this case as I did not record first 2 trials
elseif strcmp('NLP05', subj)
    % A partir del trigger numero 10 fue pausado por lo tanto solo incluyo
    % hasta el 9
    theoretical_triggers(10:end) = [];
    theoretical_cond(10:end) = [];
    onset(30) = 0; % The expected 2 samples from offset to onset is not right, therefore the automatic way does not work, manually solved!
    onset(31) = 1;

    %% The offset between blocks is not good, take the length of the stim
    name_file_video = '/stim-4-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';


elseif strcmp('NLP06', subj)
    % A partir del trigger numero 10 fue pausado por lo tanto solo incluyo hasta el 9
    theoretical_triggers(1:14) = [];
    theoretical_cond(1:14) = [];
    onset(11) = 0; % automatic -2 from offset did not work in this case
    onset(12) = 1;
    %% The offset between blocks is not good, take the length of the stim
    name_file_video ='/stim-6-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video]);

    %% Fix lack of trigger at the end with minlength of the audio signal (e.g. NLP05)
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio = min(length(audio_rsmpl));

    events_onset(56).sample = events_onset(56-1).sample + minLen_audio;
    events_onset(56).type = 'Offset';
    %events_onset(55).type = 'Onset';
    onset(55) = 1;
    offset(56) = 1;

    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-8-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);

    minLen_audio_1 = min(length(audio_rsmpl));
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    %epoch_aux =  dataEEG_detrend.trial{pp}(7, :)';
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    events_onset(29).sample = events_onset(29-2).sample + minLen_audio_1;
    events_onset(29).type = 'Offset';
    offset(29) = 1;

elseif strcmp('NLP07', subj)
    %theoretical_cond(end) = []; % Last trial was paused, therefore out
    %theoretical_triggers(end) = []; % Last trial was paused, therefore out
    theoretical_triggers(3:5) = [];
    theoretical_cond(3:5) = [];

    onset(11) = 0; % There was a pause, out
    offset(13) = 0;
    onset(19) = 0; % There was a pause, out
    offset(21) = 0; % There was a pause, out

    
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-6-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));

    events_onset(29).sample = events_onset(29-2).sample + minLen_audio_1;
    events_onset(29).type = 'Offset';
    offset(29) = 1;

    %% Fix lack of trigger at the end with minlength of the audio signal (e.g. NLP05)
    name_file_video ='/stim-8-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video]);

    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio = min(length(audio_rsmpl));

    events_onset(56).sample = events_onset(56-1).sample + minLen_audio;
    events_onset(56).type = 'Offset';
    %events_onset(55).type = 'Onset';
    onset(55) = 1;
    offset(56) = 1;
elseif strcmp('NLP08', subj)
    onset(6) = 0;
    onset(7) = 1;
    theoretical_triggers(end) = [];
    theoretical_cond(end) = [];

    theoretical_triggers(19) = [];
    theoretical_cond(19) = [];
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-14-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));

    events_onset(28).sample = events_onset(28-2).sample + minLen_audio_1;
    events_onset(28).type = 'Offset';
    offset(28) = 1;
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-4-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));

    events_onset(56).sample = events_onset(56-2).sample + minLen_audio_1;
    events_onset(56).type = 'Offset';
    offset(28) = 1;
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-13-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));

    events_onset(85).sample = events_onset(85-2).sample + minLen_audio_1;
    events_onset(85).type = 'Offset';
    offset(85) = 1;
elseif strcmp('NLP09', subj)
    theoretical_triggers(end) = [];
    theoretical_cond(end) = [];
    offset(28) = 1;
    onset(18) = 0;
    onset(19) = 1;

    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-12-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    events_onset(28).sample = events_onset(28-2).sample + minLen_audio_1;
    events_onset(28).type = 'Offset';


elseif strcmp('NLP11', subj)
    theoretical_triggers(4) = [];
    theoretical_cond(4) = [];
    onset(15) = 0;
    %events_onset(15).type = '';
    onset(18) = 0; % Take out extra trigger
    display('onset(18):')
    onset(18)
    offset(20) = 0; % Take out extra trigger
    %onset(21) = 0;
    %onset(22) = 1;
    %offset(23) = 0;
    onset(76) = 0;
    onset(77) = 1;
    theoretical_triggers(end) = [];
    theoretical_cond(end) = [];
    
    
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-6-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));

    events_onset(31).sample = events_onset(31-2).sample + minLen_audio_1;
    events_onset(31).type = 'Offset';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-8-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));

    events_onset(59).sample = events_onset(59-2).sample + minLen_audio_1;
    events_onset(59).type = 'Offset';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-3-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    events_onset(86).sample = events_onset(86-2).sample + minLen_audio_1;
    events_onset(86).type = 'Offset';
    display('hola')

elseif strcmp('NLP12', subj)
    theoretical_triggers(6:7) = [];
    theoretical_cond(6:7) = [];    
    onset(18) = 0;
    onset(19) =1;
    onset(22) = 0;
    onset(28) = 0;
    %events_onset(18).type = '';
    %events_onset(19).type = 'Onset';
    %events_onset(22).type = '';
    %events_onset(28).type = '';
    %offset()

elseif strcmp('NLP13', subj)
    onset(46) = 0; % Changing the confusion of 1 and 2 of trigger vs cond (cond is not sent in these cases)
    onset(47) = 1;

    onset(65) = 0; % Changing the confusion of 1 and 2 of trigger vs cond (cond is not sent in these cases)
    onset(66) = 1;

    %% Fix lack of last trigger at the end with minlength of the audio signal (e.g. NLP05)
    name_file_video ='/stim-6-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video]);

    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio = min(length(audio_rsmpl));

    events_onset(110).sample = events_onset(110-1).sample + minLen_audio;
    events_onset(110).type = 'Offset';
    %events_onset(109).type = 'Onset';
    onset(109) = 1;
    offset(110) = 1;

    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-11-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));

    events_onset(29).sample = events_onset(29-2).sample + minLen_audio_1;
    events_onset(29).type = 'Offset';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-8-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));

    events_onset(83).sample = events_onset(83-2).sample + minLen_audio_1;
    events_onset(83).type = 'Offset';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-4-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 56;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-2).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP14', subj)
    theoretical_triggers(end) = []; % Last trial was paused, therefore out.
    theoretical_triggers(11:12) = [];
    theoretical_triggers(11) = []; % trial was paused, therefore out.
    
    theoretical_cond(end) = []; % Last trial was paused, therefore out.
    theoretical_cond(11:12) = [];
    theoretical_cond(11) = []; % trial was paused, therefore out.

    onset(19) = 1;
    %events_onset(19).type = 'Onset';

    onset(18) = 0; % 1 and 2 get confused with the cond...
    %events_onset(18).type = '';

    onset(43) = 0; % Paused
    %events_onset(43).type = '';
    onset(47) = 0; % Paused
    %events_onset(47).type = '';
    onset(51) = 0; % Paused
    %events_onset(51).type = '';

    offset(45) = 0; % Paused
    %events_onset(45).type = '';
    offset(49) = 0; % Paused
    %events_onset(49).type = '';
    offset(53) = 0; % Paused
    %events_onset(53).type = '';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-6-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 28;
    gap = 2; % 1 if from onset to offset there are only one cell
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Problem with the aux, no good signal from the 8th on
    theoretical_triggers(8:end) = []; % Last trial was paused, therefore out.
    theoretical_cond(8:end) = []; % Last trial was paused, therefore out.
    onset(30) = 0; % Paused
    %events_onset(30).type = '';
    offset(32) = 0; % Paused
    %events_onset(32).type = '';
    onset(34) = 0; % Paused
    %events_onset(34).type = '';
    offset(36) = 0; % Paused
    %events_onset(36).type = '';
    onset(38) = 0; % Paused
    %events_onset(38).type = '';
    offset(40) = 0; % Paused
    %events_onset(40).type = '';
    onset(55) = 0; % Paused
    %events_onset(50).type = '';
    offset(57) = 0; % Paused
    %events_onset(57).type = '';
    onset(59) = 0; % Paused
    %events_onset(59).type = '';
    offset(61) = 0; % Paused
    %events_onset(61).type = '';
elseif strcmp('NLP15', subj)
    % Objective, to modify onset and offset values so that it captures the good trigger
    % inside eeg_triggers_str
    % Method: open a_default and theory side by side. Spot errors, start fixing them by:
    % Method: Open eeg_triggers_str and onset side by side
    % Modify onset and convert it to 0 if not right
    onset(6) = 0;
    onset(7) = 1;
    %events_onset(6).type = '';
    %events_onset(7).type = 'Onset';

    onset(105) = 0;
    onset(106) = 1;
    %events_onset(105).type = '';
    %events_onset(106).type = 'Onset';
    %% Fix lack of last trigger at the end with minlength of the audio signal (e.g. NLP05)
    % Method: how do you know the corresponding video?
    % Opening side by side theoretical_cond and theoretical_triggers
    name_file_video ='/stim-6-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video]);

    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio = min(length(audio_rsmpl));

    onset_to_modify = 109;
    offset_to_modify = 110;
    gap = 1; % 1 if from onset to offset there are only one cell

    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio;
    events_onset(offset_to_modify).type = 'Offset';
    %events_onset(onset_to_modify).type = 'Onset';
    onset(109) = 1;
    %events_onset(109).type = 'Onset';
    offset(110) = 1;
    %events_onset(110).type = 'Offset';

    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-14-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 28;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-4-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 56;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-13-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 84;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
elseif strcmp('NLP16', subj)
    onset(19) = 1;
    onset(18) = 0;
    % onset 22?
     onset(56) = 1;
    offset(57) = 1;  

    % offset(30) = 0; 
    % onset(28) = 0; 
    theoretical_triggers(6) = []; % Last trial was paused, therefore out.
    theoretical_cond(6) = []; % Last trial was paused, therefore out.
    
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-12-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 28;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of last trigger at the end with minlength of the audio signal (e.g. NLP05)
    name_file_video ='/stim-13-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video]);

    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio = min(length(audio_rsmpl));

    onset_to_modify = 56;
    offset_to_modify = 57;
    gap = 1; % 1 if from onset to offset there are only one cell

    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio;
    events_onset(offset_to_modify).type = 'Offset';
    
elseif strcmp('NLP17', subj)
    theoretical_triggers(end) = []; % Last trial was paused, therefore out.
    theoretical_cond(end) = []; % Last trial was paused, therefore out.
    onset(10) = 0;
    %events_onset(10).type = '';    
    onset(11) = 1;
    %events_onset(11).type = 'Onset';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-11-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 28;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-2-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 56;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-11-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 84;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
elseif strcmp('NLP18', subj)
    onset(74) = 0; % Automatic way with errors, manual fix
    onset(75) = 1;
    theoretical_triggers(end)= []; % The last trigger was paused ,therefore out.
    theoretical_cond(end)= []; % The last trigger was paused ,therefore out.
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-6-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-8-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 57;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
elseif strcmp('NLP19', subj)
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-14-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of last trigger at the end with minlength of the audio signal (e.g. NLP05)
    name_file_video ='/stim-4-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video]);

    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio = min(length(audio_rsmpl));

    onset_to_modify = 54;
    offset_to_modify = 55;
    gap = 1; % 1 if from onset to offset there are only one cell

    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio;
    events_onset(offset_to_modify).type = 'Offset';
    %events_onset(onset_to_modify).type = 'Onset';
    onset(onset_to_modify) = 1;
    offset(offset_to_modify) = 1;

    %% automatic error, manual fix
    onset(46) = 0;
    onset(47) = 1;
elseif strcmp('NLP20', subj)
    theoretical_triggers(end)=[]; % The last was paused, therefore out
    theoretical_triggers(13)=[]; % This was paused, therefore out.
    theoretical_cond(end)=[]; % The last was paused, therefore out
    theoretical_cond(13)=[]; % This was paused, therefore out.
   
    
    onset(47) = 0;
    onset(48)= 1; %Automatic bad, manual fix
    onset(68) = 0;
    onset(69)= 1; %Automatic bad, manual fix
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-11-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 30;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-11-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 30;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-4-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 59;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks with minlength
    name_file_video2 ='/stim-8-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 86;
    gap = 2;
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
elseif strcmp('NLP22', subj)
    onset(3) = 0;
    onset(4) = 1;
    theoretical_triggers(28)= []; % Pen�ltimo was already stopped, therefore 27 and 28 out
    theoretical_triggers(27)= []; % Pen�ltimo was already stopped, therefore 27 and 28 out
    theoretical_triggers(1)= []; % The first trigger was lost (started recording late),therefore out.
    theoretical_cond(28)= []; % Pen�ltimo was already stopped, therefore 27 and 28 out
    theoretical_cond(27)= []; % Pen�ltimo was already stopped, therefore 27 and 28 out
    theoretical_cond(1)= []; % The first trigger was lost (started recording late),therefore out.

    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-14-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 25; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-4-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 53; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks 3 and 4 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-13-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 81; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% No need to fix the last trigger of the block 4 as the last two videos were not played
elseif strcmp('NLP23', subj)
    
    onset(19) = 0;
    onset(20) = 1;
    onset(52) = 0;
    offset(54) = 0;
    onset(84) = 1;
    offset(85) = 1;

    theoretical_triggers(13) = [];
    theoretical_cond(13) = [];
     %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-12-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

     %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-13-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 58; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-6-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 85; % numbered 6 normally, if not existing, the previous
    gap = 1; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';


elseif strcmp('NLP24', subj)
    % Error of the numbering in the automatic mode, manual change
    onset(10) = 0;
    onset(11) = 1;
    onset(82) = 1; % missing trigger for the last video
    offset(83) = 1;% missing trigger for the last video
    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-14-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 28; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-2-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 56; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks 3 and 4 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-11-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 83; % numbered 6 normally, if not existing, the previous
    gap = 1; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP25', subj)
    onset(74) = 0;
    onset(75) = 1;

    %% Add missing onset and offset on the last video
    onset(110) = 1;
    offset(111) =1;
    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-6-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-8-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 57; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks 3 and 4 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-3-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 84; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between block 4 and end
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-8-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 111; % numbered 6 normally, if not existing, the previous
    gap = 1; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP26', subj)
    % Add final trigger onset and offset
    onset(54) = 1;
    offset(55) = 1;
    % there was a confusion in the onset of one trigger
    onset(46) = 0;
    %events_onset(46).type = 'Stimulus';
    onset(47) = 1;

    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-14-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-4-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 55; % numbered 6 normally, if not existing, the previous
    gap = 1; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP27', subj)
    onset(47) = 1;
    onset(46) = 0;
    events_onset(46).type = 'Stimulus'; % Take out the onset name from the info

    onset(66) = 1;
    onset(65) = 0;
    events_onset(65).type = 'Stimulus'; % Take out the onset name from the info

    %% Add last trigger
    onset(81) = 1;
    offset(82) = 1;

    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-11-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-4-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 56; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks 3 and end
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-8-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 82; % numbered 6 normally, if not existing, the previous
    gap = 1; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP28', subj)
    theoretical_triggers(1:3) = []; % First 3 trials was not recorded!
    theoretical_cond(1:3) = []; % First 3 trials was not recorded!

    onset(7) = 0;
    onset(8) = 1;

    % missing end
    onset(43) = 1;
    offset(45) = 1;

    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-1-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and end with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-4-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 45; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP29', subj)
    theoretical_triggers(4) = [];
    theoretical_cond(4) = [];

    onset(6) = 0;
    onset(7) = 1;

    onset(23) = 1;
    offset(24) = 1;
elseif strcmp('NLP30', subj)
    onset(18) = 0;
    onset(19) = 1;

    onset(82) = 1;
    offset(83) = 1;
    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-12-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 28; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-13-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 56; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks 3 and end
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-6-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 83; % numbered 6 normally, if not existing, the previous
    gap = 1; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP31', subj)
    onset(10) = 0;
    onset(11) = 1;
    %events_onset(10).type = '';
    %events_onset(11).type = 'Onset';

   
    theoretical_triggers(end-1:end) = [];
    theoretical_cond(end-1:end) = [];
elseif strcmp('NLP32', subj)
    onset(56) = 1;
    offset(57) = 1;

elseif strcmp('NLP33', subj)
    onset(46) = 0;
    onset(47) = 1;
    onset(65) = 0;
    onset(66) = 1;
    onset(93) = 0;
    offset(95) = 0;

    theoretical_triggers(24:end) = [];
    theoretical_cond(24:end) = [];

    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-14-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-4-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 56; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks 3 and end
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-14-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 83; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP34', subj)
    theoretical_triggers(end) = [];
    theoretical_cond(end) = [];

    onset(46) = 0;
    onset(47) = 1;
    onset(65) = 0;
    onset(66) = 1;

     %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-11-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-4-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 56; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP35', subj)
    onset(18) = 0; % Confused the automatic way, manual fix
    onset(19) = 1;
    %events_onset(46).type = 'Stimulus'; % Take out the onset name from the info

    %last trigger was not sent and the previous bad
    theoretical_triggers(end-1:end) = [];
    theoretical_cond(end-1:end) = [];
    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-6-clear-7less.mp4';
    [path_stimuli name_file_video2]
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 24; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP36', subj)
    onset(6) = 0; % Confused the automatic way, manual fix
    onset(7) = 1;
    %events_onset(7).type = 'Stimulus'; % Take out the onset name from the info

    %% Add last trigger
    onset(82) = 1;
    %events_onset(82).type = 'Stimulus'; % Take out the onset name from the info
    offset(83) = 1;


    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-14-clear-7less.mp4';
    [path_stimuli name_file_video2]
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 28; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-4-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 56; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks 3 and end
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-13-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 83; % numbered 6 normally, if not existing, the previous
    gap = 1; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP37', subj)

    % Take out last trigger (noise)
    theoretical_triggers(14) = [];
    theoretical_cond(14) = [];

    onset(18) = 0;
    onset(19) = 1;
    %events_onset(19).type = 'Onset'; % Take out the onset name from the info

    onset(23) = 0;
    onset(24) = 1;
    %events_onset(25).type = 'Onset'; % Take out the onset name from the info

    onset(31) = 1;
    %events_onset(31).type = 'Onset';
    offset(33) = 1;

elseif strcmp('NLP38', subj)

% Take out first trigger (noise)
    theoretical_triggers(1) = [];
    theoretical_cond(1) = [];
    % Last trigger was not well sent
    theoretical_triggers(end) = [];
    theoretical_cond(end) = [];
    
    onset(7) = 0;
    onset(8) = 1;

     %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-11-vocoded-7less.mp4';
    [path_stimuli name_file_video2]
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 25; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-4-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 51; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP39', subj)
    onset(74) = 0;
    onset(75) = 1;
    %events_onset(74).type = '';
    %events_onset(75).type = 'Onset';

    % Add last trigger
    onset(81) = 1;
    offset(83) = 1;
    %events_onset(81).type = 'Onset';
    %events_onset(83).type = 'Offset';


 %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-6-vocoded-7less.mp4';
    [path_stimuli name_file_video2]
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-8-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 57; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks 3 and end
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-3-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 83; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP40', subj)
    theoretical_triggers(end-1:end) = [];
    theoretical_cond(end-1:end) = [];

elseif strcmp('NLP41', subj)
    onset(2) = 0;
    onset(3) = 1;

    theoretical_triggers(end) = [];
    theoretical_cond(end) = [];
    theoretical_triggers(9) = [];
    theoretical_cond(9) = [];
    theoretical_triggers(1) = [];
    theoretical_cond(1) = [];

elseif strcmp('NLP42', subj)
    onset(18) = 0;
    onset(19) = 1;
    %events_onset(18).type = '';
    %events_onset(19).type = 'Onset';


    % add last trigger
    onset(54) = 1;
    offset(55) = 1;
    %events_onset(54).type = 'Onset';
    %events_onset(55).type = 'Offset';

     %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-3-clear-7less.mp4';
    [path_stimuli name_file_video2]
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 28; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-8-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 55; % numbered 6 normally, if not existing, the previous
    gap = 1; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP43', subj)
    onset(6) = 0;
    onset(7) = 1;
    %events_onset(6).type = '';
    %events_onset(7).type = 'Onset'; 

    % Add last trigger
    onset(54) = 1;
    offset(55) = 1;
    %events_onset(54).type = 'Onset';
    %events_onset(55).type = 'Offset';

   %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-14-clear-7less.mp4';
    [path_stimuli name_file_video2]
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 28; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-4-vocoded-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 55; % numbered 6 normally, if not existing, the previous
    gap = 1; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    elseif strcmp('NLP45', subj)

    onset(10) = 0;
    onset(11) = 1;
    %events_onset(10).type = '';
    %events_onset(11).type = 'Onset';

    % Take out last trigger
    theoretical_triggers(end) = [];
    theoretical_cond(end) = [];
    %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-11-vocoded-7less.mp4';
    [path_stimuli name_file_video2]
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 28; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-2-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 56; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

    %% Fix lack of trigger between blocks 3 and end
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-11-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 84; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';

elseif strcmp('NLP46', subj)
    % Delete last two triggers as not finished.
    theoretical_triggers(end-1:end) = [];
    theoretical_cond(end-1:end) = [];

     %% Fix lack of trigger between blocks 1 and 2 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-7-vocoded-7less.mp4';
    [path_stimuli name_file_video2]
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 29; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
    %% Fix lack of trigger between blocks 2 and 3 with minlength
    % Method, check where is the index of the trigger to change the duration of.
    name_file_video2 ='/stim-8-clear-7less.mp4';
    [audio_file, fs] = audioread([path_stimuli name_file_video2]);
    new_fs = round(dataEEG_detrend.fsample);
    old_fs = round(fs);
    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
    minLen_audio_1 = min(length(audio_rsmpl));
    offset_to_modify = 61; % numbered 6 normally, if not existing, the previous
    gap = 2; % How many cells 'far' is the actual beginning of the start of the last video of the block
    events_onset(offset_to_modify).sample = events_onset(offset_to_modify-gap).sample + minLen_audio_1;
    events_onset(offset_to_modify).type = 'Offset';
end
end