function [data_combined, theoretical_cond, theoretical_triggers] = combining_EEG2(name_file, path_data, path_file_eeg, path_stimuli, indiv, dataEEG_detrend, images_yes)
ft_defaults

if length(name_file)~=0
    for kk=1:1%length(name_file)
        cd(path_data)
        cfg = [];
        cfg.dataset = char(strcat(path_file_eeg, filesep, name_file(kk).name))
        
        cfg.continuous = 'yes';
        % Step 1: Extract Events from Original Data (Before Resampling)
        events = ft_read_event(cfg.dataset);  % Read events from the original dataset
        if length([events.value])>0
            
            % Step 1: Load raw EEG data (assuming it's in a .mat format or a compatible format)
            cfg = [];
            cfg.dataset = char(strcat(path_file_eeg, filesep, name_file(kk).name));  % Specify the path to your raw data file (e.g., .mat, .fif, .set)
            
            % Load the raw data
            data_raw = ft_preprocessing(cfg);
            
            %% Fetch the triggers
            % Find the trigger events (assuming 'Stimulus' is the type of event you are looking for)
            trigger_events = events(strcmp({events.type}, 'Stimulus'));  % Modify 'trigger' if necessary
            
            % Convert trigger sample indices to time (in seconds) in the original signal
            trigger_samples = [trigger_events.sample];  % Sample indices of triggers
            trigger_times_original = trigger_samples / data_raw.fsample;  % Convert sample indices to time in original signal
            
            triggers_all_zero_one = zeros(1, length(data_raw.trial{1}(1, :)));
            triggers_all_zero_one(trigger_samples) = 100000;
            
            % Plot raw data (1 channel enough) and triggers
            figure;
            plot(data_raw.trial{1}(1, :)');% ylim([0 50000])
            hold on;
            plot(triggers_all_zero_one)
            
            % Get the first and last trigger times
            first_trigger_time = trigger_times_original(1);  % First trigger time
            last_trigger_time = trigger_times_original(end);  % Last trigger time
            
            [~, first_idx] = min(abs(data_raw.time{1} - first_trigger_time));  % Index for the first trigger
            [~, last_idx] = min(abs(data_raw.time{1} - last_trigger_time));    % Index for the last trigger
            
            % Include ET condition data
            
            cd(path_data);
            
            subj = char(indiv);
            num_subj = dir(subj);
            subjects_name = {num_subj(:).name};
            subjects_name = subjects_name(~ismember(subjects_name, {'.', '..', '.DS_Store'})); % Remove unwanted files
            path_file = strcat(path_data,filesep,subj, filesep, 'ET');
            cd(char(path_file));
            
            logfile = dir('*.csv')
            conditions_ET = readtable(logfile.name);
            conditions_ET
            if strcmp(subj, 'NLP02')  ||strcmp(subj, 'NLP10') ||  strcmp(subj, 'NLP05') % || strcmp(subj, 'NLP20') %
                conditions_ET.trig = str2double(conditions_ET.trig)
                conditions_ET.cond = str2double(conditions_ET.cond)
            end
            % Compare theoretical triggers (ET) with received triggers (EEG)
            theoretical_triggers = conditions_ET.trig(~isnan(conditions_ET.trig));
            theoretical_cond = conditions_ET.cond(~isnan(conditions_ET.cond));
            
            eeg_triggers = {events.value}';
            
            % Structure of the triggers received by the EEG: % 6 (beginning of experiment)% video number % condition number
            % 6 (beginning of att getter)% 3 (end of att getter) % I will keep only the trigger informing on the beginning of
            % the trial and the one of the end % Convert the string into numbers
            
            eeg_triggers_str = zeros(length(eeg_triggers), 1);
            for ii = 1:length(eeg_triggers)
                
                if ischar(eeg_triggers{ii}) % If it is not empty
                    eeg_triggers_str(ii) = str2double(regexp(eeg_triggers{ii}, '\d+\.?\d*', 'match'));  % Extract numbers as strings
                end
            end
            
            % Add information to the matrix of triggers, with a column of onset and column of offset
            onset = zeros(length(eeg_triggers_str), 1);
            offset = zeros(length(eeg_triggers_str), 1);
            
            idx_6 = find(eeg_triggers_str==6);
            idx_3 = find(eeg_triggers_str(idx_6+1) ==3);
            
            % If all the triggers are being sent well, the video number should have been sent two triggers before the offset.
            if strcmp('NLP04', subj) || strcmp('NLP06', subj) || strcmp('NLP28', subj)|| strcmp('NLP38', subj)
                idx_3 = idx_3(2:end) % I forgot to record the first two trials
                
            end
            offset(idx_6(idx_3)) = 1;
            onset(idx_6(idx_3)-2) = 1;
            
            triggers_eeg_all = [eeg_triggers_str, offset, onset]
            
            % At this point, the first time that is preprocessed, the triggers_eeg_all with onset ==1 should be the same as ...
            % those in theoretical_triggers (check in the variable workspace)
            
            %% If this is the case, take out those triggers in which a pause was added for example... or when there is noise (MANUAL)
            % If we compare the by default onset and offset idx
            a_default = triggers_eeg_all(find(onset))
            theory = theoretical_triggers
            
            events_onset = events;
            
            [events_onset, onset, offset, theoretical_triggers, theoretical_cond] = G_EEG_trigger_restructuration_neurolip(subj, onset, offset, theoretical_triggers, theoretical_cond, dataEEG_detrend, data_raw.fsample, events_onset, path_stimuli)
            
            % And after modifying it...
            a_modified = triggers_eeg_all(find(onset))
            
            triggers_eeg_all = [eeg_triggers_str, offset, onset]
            % Create an extra column with info about onset and offset
            
            idx_on = find(onset);
            idx_off =  find(offset);
            
            for ll = 1:length(idx_on)
                events_onset(idx_on(ll)).type = 'Onset';
                events_onset(idx_off(ll)).type = 'Offset';
            end
            % CHECK
            a = triggers_eeg_all(find(onset), 1)
            b = theoretical_triggers
            % cd(path_code_EEG)
            triggers_eeg_all = [eeg_triggers_str, offset, onset]
            %% Segment first, to avoid filtering edge effects between segments
            
            % Define event indices for 'Onset' and 'Offset'
            idx_onn = find(strcmp('Onset', {events_onset.type}));
            idx_offf = find(strcmp('Offset', {events_onset.type}));
            idx_all = sort([idx_onn idx_offf]);
            events_onset_trim_on = events_onset(idx_onn);
            events_onset_trim = events_onset(idx_all);
            eventvalues_on = {events_onset_trim_on.value};
            
            % Calculate trial durations (in seconds)
            trial_durations = ([events_onset_trim(strcmp('Offset', {events_onset_trim.type})).sample] - ...
                [events_onset_trim(strcmp('Onset', {events_onset_trim.type})).sample]) / data_raw.fsample;
            
            fs = data_raw.fsample;
            onsets = [events_onset_trim_on.sample]';  % Sample indices where trials begin
            prestim = 0.2;  % 200 ms before onset
            poststim = trial_durations; % 800 ms after onset
            
            trl = zeros(length(onsets), 3);
            for i = 1:length(onsets)
                trl(i, 1) = onsets(i) - round(prestim * fs);  % trial start
                trl(i, 2) = onsets(i) + round(poststim(i) * fs) - 1;  % trial end
                trl(i, 3) = -round(prestim * fs);  % offset
            end
            cfg = [];
            cfg.dataset = char(strcat(path_file_eeg, filesep, name_file(kk).name));  % Or .eeg depending on file structure
            cfg.trl = trl;
            cfg.bpfilter = 'no';  % <-- ADD THIS LINE
            data = ft_preprocessing(cfg);
            
            
            %% Next, add the audio signals at the beginning of each trigger
            
            % Comprobar que está todo bien mirando a las condiciones del ET
            % triggers_eeg_all(find(onset), 1) == theoretical_triggers
            data_combined = struct();
            triggers_eeg_all
            triggers_eeg_all(find(onset), 1)
            theoretical_triggers
            
            figure; plot(triggers_eeg_all)
            if sum(triggers_eeg_all(find(onset), 1) == theoretical_triggers) ==length(triggers_eeg_all(find(onset), 1))
                % Now, the triggers are good.
                
                for pp = 1:length(theoretical_triggers)
                    
                    % Identify the video number with loading the specific audio from that video
                    switch (theoretical_triggers(pp))
                        case 1
                            if theoretical_cond(pp) == 1
                                name_file= '/stim-1-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file = '/stim-1-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 2
                            if theoretical_cond(pp) == 1
                                name_file = '/stim-2-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file = '/stim-2-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 3
                            if theoretical_cond(pp) == 1
                                name_file = '/stim-3-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file = '/stim-3-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 4
                            if theoretical_cond(pp) == 1
                                name_file = '/stim-4-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file = '/stim-4-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 5
                            if theoretical_cond(pp) == 1
                                name_file = '/stim-5-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file ='/stim-5-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 6
                            if theoretical_cond(pp) == 1
                                name_file = '/stim-6-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file ='/stim-6-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 7
                            if theoretical_cond(pp) == 1
                                name_file =  '/stim-7-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file = '/stim-7-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 8
                            if theoretical_cond(pp) == 1
                                name_file ='/stim-8-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file = '/stim-8-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 9
                            if theoretical_cond(pp) == 1
                                name_file = '/stim-9-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file = '/stim-9-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 10
                            if theoretical_cond(pp) == 1
                                name_file = '/stim-10-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file = '/stim-10-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 11
                            if theoretical_cond(pp) == 1
                                name_file ='/stim-11-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file = '/stim-11-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 12
                            if theoretical_cond(pp) == 1
                                name_file = '/stim-12-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                                figure; plot(audio_file);
                            else
                                name_file = '/stim-12-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 13
                            if theoretical_cond(pp) == 1
                                name_file = '/stim-13-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file = '/stim-13-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                        case 14
                            if theoretical_cond(pp) == 1
                                name_file ='/stim-14-clear-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            else
                                name_file = '/stim-14-vocoded-7less.mp4';
                                [audio_file, fs] = audioread([path_stimuli name_file]);
                            end
                    end
                    
                    
                    %%  Calculate latency from original and aux signal
                    
                    new_fs = round(data.fsample);
                    old_fs = round(fs);
                    epoch_aux =  data.trial{pp}(7, :)';
                    audio_rsmpl = resample(audio_file(:, 1), new_fs, old_fs);
                    
                    if images_yes
                        figure;
                        plot(audio_rsmpl); hold on;
                        title('original audio')
                        xlim([0 3*10^5])
                        plot(epoch_aux/500000);
                        title('aux')
                        xlim([0 3*10^5])
                    end
                    % Normalizar antes de xcorr
                    audio_norm = (audio_rsmpl - mean(audio_rsmpl)) / std(audio_rsmpl);
                    aux_norm   = (epoch_aux - mean(epoch_aux)) / std(epoch_aux);
                    
                    [xcorr_vals, lags] = xcorr(audio_rsmpl, epoch_aux);  % x2 delayed version of x1
                    [~, idx] = max(xcorr_vals);         % Find peak correlation
                    clear xcorr_vals % To save memory
                    % Calculate time delay
                    lagSamples = lags(idx);             % Delay in samples,
                    % if >0, original audio delayed with respect to aux -> need to delete zeros in the beginning
                    % if <0, original audio ocurring before aux -> need to add zeros in the beginning
                    delayInSeconds = lagSamples / data.fsample;   % Delay in seconds
                    
                    %% Apply correction (lag) to the audio original signal, to match the aux
                    if lagSamples > 0
                        audio_rsmpl = audio_rsmpl(lagSamples:end);
                    elseif lagSamples < 0
                        extra_zeros = zeros(abs(lagSamples), 1);
                        audio_rsmpl = [extra_zeros; audio_rsmpl];
                    end
                    
                    %% Checking that the timing is good for the audio data
                    
                    % tmp_audio_rsmpl = zeros(size(epoch_aux));
                    % tmp_audio_rsmpl(abs(lagSamples):abs(lagSamples)+length(audio_rsmpl)-1) = audio_rsmpl
                    %
                    % figure;
                    %  plot(epoch_aux / max(abs(epoch_aux)), 'r'); hold on;
                    % plot(tmp_audio_rsmpl / max(abs(tmp_audio_rsmpl)), 'b');
                    % ylim([-2 1])
                    % legend('aux', 'audio')
                    % %saveas(gcf, [path_figures_coherence '/' char(indiv) '_time_signals_' num2str(pp) '.png']);
                    
                    %% My way to do it before
                    % envelope_audio = hilbert(audio_rsmpl_new);
                    
                    %% Way to have the envelope by Anne Kosem, from the original audio signal, and then resample
                    
                    % %% Obtain envelope from the original audio signal
                    % % Anne kosem way to obtain the envelope
                    % % Filtrer le signal audio et extraire l'enveloppe
                    % %Bw = [100 5000] / (fs / 2);
                    % %[b, a] = butter(4, Bw);
                    % %filtwav = filtfilt(b, a, audio_file(:, 1))';;
                    % audio = audio_file(:, 1);
                    % audio(audio < 0) = 0;
                    % amp = abs(hilbert(audio));
                    %
                    % [blp, alp] = butter(4, 40 / (fs / 2), 'low'); % Anne kosem has it at 20 Hz max freq.
                    % env_audio_file = filter(blp, alp, amp);
                    
                    %% Then, once filtered, resample
                    % envelope_audio_rs = resample(env_audio_file, new_fs, old_fs);
                    %
                    % %% Apply correction (lag) to the audio original signal, to match the aux
                    % if lagSamples > 0
                    %     envelope_audio = envelope_audio_rs(lagSamples:end);
                    % elseif lagSamples < 0
                    %     extra_zeros = zeros(abs(lagSamples), 1);
                    %     envelope_audio = [extra_zeros; envelope_audio_rs];
                    % end
                    
                    % Check timings
                    figure;
                    %plot([(data_resampled.trial{pp}(1:6, :)/500)]', 'color', 'k'); hold on;
                    plot(epoch_aux / max(abs(epoch_aux))); hold on;
                    plot(audio_rsmpl / max(abs(audio_rsmpl))); hold on;
                    %plot(envelope_audio)
                    
                    %% Prepare brain and audio signals to compute coherence (I had it this way before Chatgpt)
                    
                    %                         % Ensure length between the brain signal and the audio signal is the same
                    %                         minLen = min(length(audio_rsmpl), length(data.trial{pp}(1, :)));
                    %
                    %                         %% First update the sampleinfo to the minLen
                    %                         % Preallocate new sampleinfo
                    %                         newSampleInfo = zeros(length(data.trial), 2);
                    %
                    %                         % Truncate trial data to minLen samples and first 6 channels
                    %                         data_eeg.trial = data.trial{pp}(1:6, 1:minLen);
                    %
                    %                         % Time vector for truncated data (start at 0)
                    %                         data_eeg.time = linspace(0, (minLen-1)/data.fsample, minLen);
                    %
                    %                         % Labels and fsample remain same
                    %                         data_eeg.fsample = data.fsample;
                    %                         data_eeg.label = data.label(1:6);
                    %
                    %                         % Adjust sampleinfo for truncated trial
                    %                         startSample = data.sampleinfo(pp, 1);
                    %                         newSampleInfo(pp, :) = [startSample, startSample + minLen - 1];
                    %
                    %                         % Similarly for audio
                    %                         audio_rsmpl = audio_rsmpl(1:minLen)';
                    %                         data_audio.trial = abs(hilbert(audio_rsmpl));
                    %                         data_audio.time = linspace(0, (minLen-1)/data.fsample, minLen);
                    %                         data_audio.fsample = data.fsample;
                    %                         data_audio.label = {'Audio'};
                    %% Suggested by Chatgpt to align aux with envelope instead of full audio, as hilbert creates edge effects and may be worse for alignment if done after
                    
                    % ================= AUDIO ENVELOPE EXTRACTION =================
                    
                    audio = audio_file(:,1);
                    
                    % Hilbert envelope
                    env = abs(hilbert(audio));
                    
                    % Low-pass filter envelope (important!)
                    [b,a] = butter(4,20/(fs/2),'low');
                    env = filtfilt(b,a,env);
                    
                    % Resample envelope to EEG sampling rate
                    env_rs = resample(env, new_fs, fs);
                    
                    % Normalize
                    env_rs = zscore(env_rs);
                    
                    % Align envelope with auxiliary audio channel
                    % Instead of:
                    %aux_norm = zscore(epoch_aux);

                    % Do this to obtain the envelope of the aux, to compare
                    % both envelopes.
                    aux_env = abs(hilbert(epoch_aux));
                    [b,a] = butter(4, 20/(data.fsample/2), 'low');
                    aux_env = filtfilt(b, a, aux_env);
                    aux_norm = zscore(aux_env);
                    
                    % Then xcorr against env_rs as before
                    [xcorr_vals, lags] = xcorr(env_rs, aux_norm);
                    
                    [xcorr_vals,lags] = xcorr(env_rs, aux_norm);
                    
                    [~,idx] = max(xcorr_vals);
                    
                    lagSamples = lags(idx);
                    
                    if lagSamples > 0
                        env_rs = env_rs(lagSamples:end);
                    elseif lagSamples < 0
                        env_rs = [zeros(abs(lagSamples),1); env_rs];
                    end
                    
                    % ================= PREPARE EEG + AUDIO =================
                    
                    minLen = min(length(env_rs), length(data.trial{pp}(1,:)));
                    
                    % EEG
                    data_eeg.trial = data.trial{pp}(1:6,1:minLen);
                    
                    data_eeg.time = linspace(0,(minLen-1)/data.fsample,minLen);
                    
                    data_eeg.fsample = data.fsample;
                    
                    data_eeg.label = data.label(1:6);
                    
                    % Envelope
                    env_rs = env_rs(1:minLen);
                    
                    data_audio.trial = env_rs';
                    
                    data_audio.time = linspace(0,(minLen-1)/data.fsample,minLen);
                    
                    data_audio.fsample = data.fsample;
                    
                    data_audio.label = {'Audio'};
                    
                    
                    figure;
                    t = (0:minLen-1) / data.fsample;
                    plot(t, zscore(aux_env(1:minLen)), 'k'); hold on;
                    plot(t, env_rs(1:minLen), 'r--');
                    legend('AUX envelope', 'Stimulus envelope aligned');
                    title(['Trial ' num2str(pp) ' alignment check']);
                    xlabel('Time (s)');
                    
                    %%
                    data_combined.trial{pp} = [data_eeg.trial; data_audio.trial];
                    
                    % Step 2: Combine labels
                    data_combined.label = [data_eeg.label; data_audio.label];  % must be column cell array
                    
                    % Step 3: Copy timing and other fields
                    data_combined.time{pp} = data_eeg.time;
                    data_combined.fsample = data_eeg.fsample;
                    data_combined.cond(pp) = theoretical_cond(pp);
                    data_combined.monologue(pp) = theoretical_triggers(pp);
                    
                    figure;
                    plot(data_eeg.trial(1:6, :)');
                    hold on;
                    plot(abs(data_audio.trial(1, :))*10000);
                    
                    
                    
                end
                data_combined.cfg = [];
                %data_combined.noisy_trials = data.noisy_trials;
                
                sampleinfo = zeros(length(data_combined.trial), 2);
                sample_start = 1;
                
                for i = 1:length(data_combined.trial)
                    nsamples = length(data_combined.time{i});
                    sample_end = sample_start + nsamples - 1;
                    sampleinfo(i,:) = [sample_start sample_end];
                    sample_start = sample_end + 1;
                end
                
                data_combined.sampleinfo = sampleinfo;
                %data_combined.sampleinfo = newSampleInfo;
                %data_combined.sampleinfo = data_resampled.sampleinfo;
                %% After the loop, I would have in data_combined{1:nVideosSeen} both the eeg and audio signals to compute the coherence (and to send to Anne)
                
            end
        end
    end
end