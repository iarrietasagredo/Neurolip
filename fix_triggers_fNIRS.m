function raw_indiv_4triggers = fix_triggers_fNIRS(raw_indiv, conditions_ET, subj)
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
            
            %% -------------------------------------------------------------------------
            % Participant-specific corrections
            %
            % These corrections reproduce manual adjustments performed after visual
            % inspection of the trigger referring to the trial numbers, that sometimes were confused with triggers
            % that informed about start, stop, pause... They are kept explicitly to
            % ensure full reproducibility of the preprocessing pipeline.
            %% -------------------------------------------------------------------------
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
            
            %% ========================================================================
            % IDENTIFY TRUE STIMULUS ONSETS AND REMOVE PAUSE-RELATED TRIGGERS
            % ========================================================================
            
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
            elseif (strcmp(subj, "NLP20"))
                onsets(25) = []; % Take out as a pause is interpreted as a trigger
                dif_time(25) = []; % Take out as a pause is interpreted as a trigger
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
end