function ft2cnd()

% FT2CND  Convert per-participant FieldTrip-style data to the CND format
%
% Input per participant (.mat file):
%
%   eeg : FieldTrip-style struct (.label, .trial, .fsample,
%                                 .cond, .monologue, .original_trial,
%                                 .ET_continuous, .bad_channels).
%                                 LAST channel = participant-specific
%                                 stimulus envelope.
%
%   dataset_nirs_et : struct; fNIRS trials in .auxvalid.trials
%
% Output:
%
%   CND_<participant>.mat -> participant-specific EEG, stimulus envelope,
%                            eye tracking, and fNIRS data.
%
% TRIAL ALIGNMENT
%
%   A master list of all unique (monologue, condition) pairs found in
%   participants is still built. This is used ONLY to define common slots
%   for EEG, envelope, ET and fNIRS.
%
%   IMPORTANT:
%   The stimulus envelope is NOT shared across participants.
%   Each EEG trial keeps the envelope recorded for that specific
%   participant and trial.
%
% -------------------------------------------------------------------------

% USER SETTINGS
% -------------------------------------------------------------------------

inDir  = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/EEG_NIRS_ET_DATASETS';

outDir = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/CND_data_format';

% Condition names, indexed by eeg.cond
% 1 = clear
% 2 = vocoded
condNames = {'clear'; 'vocoded'};

% Drop trials not marked as valid in S.auxvalid?
useAuxvalid = false;

% Eye-tracking sampling rate
etFs = 500;

% fNIRS epoch alignment
%
% false = keep the full epoch
% true  = trim so sample 1 corresponds to trial onset
nirsOnsetAligned = false;

CNDversion = 1.0;

% -------------------------------------------------------------------------

files = dir(fullfile(inDir, '*.mat'));

if isempty(files)
    error('No .mat files found in inDir');
end

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% =========================================================================
% PASS 1: Build master list of (monologue, condition) slots
% =========================================================================
%
% IMPORTANT:
% We DO NOT store or compare stimulus envelopes here.
% The envelope belongs to each participant/trial and will be stored
% separately in PASS 2.
% =========================================================================

keys = zeros(0,2);       % [monologue condition]

fsRef = [];

for f = 1:numel(files)

    Sx = load(fullfile(inDir, files(f).name), 'eeg');

    if ~isfield(Sx, 'eeg')
        error('%s: no eeg struct', files(f).name);
    end

    ftx = Sx.eeg;

    % Check that all participants have the same EEG sampling rate
    if isempty(fsRef)

        fsRef = ftx.fsample;

    elseif ftx.fsample ~= fsRef

        error('%s: fsample %g differs from first participant (%g)', ...
            files(f).name, ftx.fsample, fsRef);

    end

    % Find all unique monologue x condition combinations
    for i = 1:numel(ftx.trial)

        k = [ftx.monologue(i) ftx.cond(i)];

        if ~ismember(k, keys, 'rows')

            keys(end+1,:) = k; %#ok<AGROW>

        end

    end

end

% Sort master slots
[keys, ~] = sortrows(keys);

nM = size(keys,1);

fprintf('Master trial list: %d unique (monologue, condition) slots.\n', nM);

if nM > 28
    warning('nM = %d > 28: check that monologue/cond values mean what you expect.', nM);
end

% =========================================================================
% PASS 2: Build each participant separately
% =========================================================================

for f = 1:numel(files)

    name_singolo = files(f).name;

    % Extract participant identifier, e.g. NLP17
    name_singolo = name_singolo(end-8:end-4);

    S = load(fullfile(inDir, files(f).name));

    if ~isfield(S, 'eeg')
        error('%s: no eeg struct', files(f).name);
    end

    ft = S.eeg;

    nTr = numel(ft.trial);

    % ---------------------------------------------------------------------
    % Optional trial selection
    % ---------------------------------------------------------------------

    if useAuxvalid && isfield(S, 'auxvalid')

        keep = false(1, nTr);
        keep(S.auxvalid(:)') = true;

    else

        keep = true(1, nTr);

    end

    % ---------------------------------------------------------------------
    % Master slot of each trial of this participant
    % ---------------------------------------------------------------------

    slot = zeros(1, nTr);

    for i = 1:nTr

        idx = find(ismember(keys, ...
            [ft.monologue(i) ft.cond(i)], 'rows'), 1);

        if isempty(idx)
            error('%s: could not find master slot for trial %d.', ...
                files(f).name, i);
        end

        slot(i) = idx;

    end

    % Check for duplicate monologue x condition combinations
    keptSlots = slot(keep);

    if numel(unique(keptSlots)) < numel(keptSlots)

        warning(['%s: duplicate (monologue, condition) pairs detected. ' ...
                 'Later trials would overwrite earlier trials in the ' ...
                 'master-slot representation.'], ...
                 files(f).name);

    end

    % =====================================================================
    % EEG
    % =====================================================================

    eeg = struct();

    eeg.cndVersion = CNDversion;
    eeg.dataType   = 'EEG';
    eeg.deviceName = '';
    eeg.fs         = ft.fsample;

    % One cell per master slot
    eeg.data = cell(1, nM);

    % Participant-specific stimulus envelope
    eeg.stim = cell(1, nM);

    % Store condition and monologue explicitly
    eeg.cond = NaN(1, nM);
    eeg.monologue = NaN(1, nM);

    eeg.origTrialPosition = NaN(1, nM);

    nLab = numel(ft.label);

    % Last channel is the stimulus envelope
    eegLabels = ft.label(1:nLab-1);

    % ---------------------------------------------------------------------
    % Copy EEG + envelope trial by trial
    % ---------------------------------------------------------------------

    for i = find(keep)

        n = slot(i);

        % -------------------------------------------------------------
        % EEG
        % FieldTrip: channels x time
        % CND:       time x channels
        % -------------------------------------------------------------

        eeg.data{n} = ft.trial{1,i}(1:nLab-1, :)';

        % -------------------------------------------------------------
        % PARTICIPANT-SPECIFIC ENVELOPE
        %
        % This is the LAST channel of the SAME EEG trial.
        %
        % FieldTrip: time x 1 after transpose
        % -------------------------------------------------------------

        eeg.stim{n} = ft.trial{1,i}(nLab, :)';

        % -------------------------------------------------------------
        % Trial metadata
        % -------------------------------------------------------------

        eeg.cond(n)      = ft.cond(i);
        eeg.monologue(n) = ft.monologue(i);

        eeg.origTrialPosition(n) = ft.original_trial(i);

    end

    % EEG channel labels
    eeg.chanlocs = struct('labels', num2cell(eegLabels(:)'));

    % Stimulus metadata
    eeg.stimNames = {'envelope'};
    eeg.stimFs    = ft.fsample;

    % =====================================================================
    % Bad channels
    % =====================================================================

    if isfield(ft, 'bad_channels')

        bc = ft.bad_channels;

        if iscell(bc)

            bcNum = [];

            for c = 1:numel(bc)

                v = bc{c};

                if isnumeric(v)

                    bcNum(end+1) = v; %#ok<AGROW>

                elseif ischar(v) || isstring(v)

                    idx = find(strcmp(eegLabels, char(v)), 1);

                    if ~isempty(idx)
                        bcNum(end+1) = idx; %#ok<AGROW>
                    end

                end

            end

            bc = bcNum;

        end

        for b = bc(:)'

            if isscalar(b) && isnumeric(b) && ...
                    b >= 1 && b <= numel(eeg.chanlocs)

                eeg.chanlocs(b).type = 'unknown';

            end

        end

    end

    % =====================================================================
    % External channels: eye tracking
    % =====================================================================

    if isfield(ft, 'ET_continuous') && ~isempty(ft.ET_continuous)

        eeg.extChan = struct();

        eeg.extChan.dataType = 'eye-tracking';
        eeg.extChan.fs       = etFs;
        eeg.extChan.data     = cell(1, nM);

        for i = find(keep)

            n = slot(i);

            % Keep participant-specific ET trial
            eeg.extChan.data{n} = ft.ET_continuous{1,i};

        end

    end

    % =====================================================================
    % fNIRS
    % =====================================================================

    fnirs = [];

    if isfield(S,'dataset_nirs_et') && ...
            isstruct(S.dataset_nirs_et) && ...
            isfield(S.dataset_nirs_et,'auxvalid') && ...
            isfield(S.dataset_nirs_et.auxvalid,'trials')

        A  = S.dataset_nirs_et.auxvalid;
        tr = A.trials;

        firstWithData = find(arrayfun(@(t) ~isempty(t.data), tr), 1);

        if isempty(firstWithData)

            fprintf('%s: fNIRS trials contain no data, skipping.\n', ...
                files(f).name);

        else

            nCh = size(tr(firstWithData).data, 2);

            % Optional onset alignment
            tAxis = A.time(:);

            i0 = 1;

            if nirsOnsetAligned

                i0 = find(tAxis >= 0, 1);

                tAxis = tAxis(i0:end);

            end

            fnirs = struct();

            fnirs.cndVersion   = CNDversion;
            fnirs.dataType     = 'fNIRS';
            fnirs.deviceName   = '';
            fnirs.fs           = A.Fs;

            fnirs.time         = tAxis;
            fnirs.preStimTime  = A.PreStimTime;
            fnirs.postStimTime = A.PostStimTime;
            fnirs.onsetAligned = nirsOnsetAligned;

            fnirs.data       = cell(1, nM);
            fnirs.chanValid  = cell(1, nM);
            fnirs.stimDur    = NaN(1, nM);

            fnirs.origTrialPosition = eeg.origTrialPosition;

            % -------------------------------------------------------------
            % fNIRS channel labels
            % -------------------------------------------------------------

            ch = A.channels;

            fnirs.chanlocs = struct('labels', cell(1, nCh));

            for c = 1:nCh

                s  = ch.source(c);
                d  = ch.detector(c);
                ty = ch.type(c);

                if iscell(s),  s  = s{1};  end
                if iscell(d),  d  = d{1};  end
                if iscell(ty), ty = ty{1}; end

                if isnumeric(s)
                    s = sprintf('S%d', s);
                else
                    s = char(string(s));
                end

                if isnumeric(d)
                    d = sprintf('D%d', d);
                else
                    d = char(string(d));
                end

                fnirs.chanlocs(c).labels = ...
                    [s '_' d '_' char(string(ty))];

            end

            % -------------------------------------------------------------
            % Match fNIRS trials to EEG trials
            % -------------------------------------------------------------

            nFound = 0;

            for i = find(keep)

                n = slot(i);

                % Duration of corresponding EEG/envelope trial
                fnirs.stimDur(n) = ...
                    size(ft.trial{1,i}, 2) / ft.fsample;

                wantMono = ft.monologue(i);
                wantCond = condNames{ft.cond(i)};

                r = find(arrayfun(@(t) ...
                    isequal(t.video, wantMono) && ...
                    strcmp(t.condition, wantCond), tr), 1);

                if ~isempty(r) && ...
                        tr(r).included && ...
                        ~isempty(tr(r).data)

                    fnirs.data{n} = tr(r).data(i0:end, :);

                    fnirs.chanValid{n} = tr(r).valid_channels;

                    nFound = nFound + 1;

                end

            end

            fprintf('%s: fNIRS built, %d/%d EEG trials matched, %d channels.\n', ...
                files(f).name, nFound, sum(keep), nCh);

        end

    else

        fprintf('%s: no dataset_nirs_et.auxvalid.trials. Variables: %s\n', ...
            files(f).name, strjoin(fieldnames(S), ', '));

    end

    % =====================================================================
    % Save participant
    % =====================================================================

    subIdx = f; %#ok<NASGU>

    out = fullfile(outDir, ...
        sprintf('CND_%s.mat', name_singolo));

    if isempty(fnirs)

        save(out, 'eeg');

    else

        save(out, 'eeg', 'fnirs');

    end

    fprintf(['Saved %s (%d/%d slots filled in EEG, %d/%d slots ' ...
             'with participant-specific envelopes)\n'], ...
        out, ...
        sum(~cellfun(@isempty, eeg.data)), ...
        nM, ...
        sum(~cellfun(@isempty, eeg.stim)), ...
        nM);

end



% function ft2cnd()
% % FT2CND  Convert per-participant FieldTrip-style data to the CND format
% % (Continuous-event Neural Data structure, v1.0; Di Liberto & Nidiffer, CNSP).
% %
% % Input per participant (.mat file):
% %   eeg              : FieldTrip-style struct (.label, .trial, .fsample,
% %                      .cond, .monologue, .original_trial, .ET_continuous,
% %                      .bad_channels). LAST channel = stimulus envelope.
% %   dataset_nirs_et  : struct; fNIRS trials in .auxvalid.trials (1xN struct
% %                      array with fields order, video, rep, condition,
% %                      onset, slot, status, included, valid_channels, data)
% %
% % Output:
% %   dataCND/dataSubX.mat  -> "eeg" (+ "fnirs" if available)
% %   dataCND/dataStim.mat  -> "stim" (built ONCE from a master trial list)
% %
% % TRIAL ALIGNMENT
% %   Not every participant completed the session, so trial sets differ.
% %   A master list of all unique (monologue, condition) pairs found in ANY
% %   participant is built first. Trial n of every modality, of every
% %   participant and of stim always refers to master slot n. Slots a
% %   participant never heard (or that were excluded) are left EMPTY ([]).
% % ---------------------------------------------------------------------------
% % USER SETTINGS - Right now, the outcome is for those trials that had good
% % EEG data, and in those, I look at fNIRS data and ET data.
% % ---------------------------------------------------------------------------
% inDir  = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/EEG_NIRS_ET_DATASETS';
% outDir = '/Users/laurianne/Library/CloudStorage/Dropbox/UPC_POSTDOC/Projects/NEUROLIP/data_preprocessed/CND_data_format';
% 
% % Condition names, indexed by the values in eeg.cond (1=clear, 2=vocoded)
% condNames = {'clear'; 'vocoded'};
% 
% % Drop trials not marked as valid in S.auxvalid? (true/false)
% useAuxvalid = false;
% 
% % Eye-tracking sampling rate (Hz)
% etFs = 500;
% 
% % fNIRS epoch alignment:
% %   false = keep the full epoch (sample 1 = -PreStimTime); timing is stored
% %           in fnirs.time / preStimTime / stimDur
% %   true  = trim so that sample 1 = trial onset (non-standard, document it)
% nirsOnsetAligned = false;
% 
% % Tolerance for comparing envelopes of the same stimulus across participants
% envTol = 1e-6;
% % ---------------------------------------------------------------------------
% CNDversion = 1.0;
% 
% files = dir(fullfile(inDir, '*.mat'));
% if isempty(files), error('No .mat files found in inDir'); end
% if ~exist(outDir, 'dir'), mkdir(outDir); end
% 
% % ===========================================================================
% % PASS 1: master trial list across ALL participants + stim
% % ===========================================================================
% keys = zeros(0,2);   % [monologue cond]
% envs = {};
% fsRef = [];
% name_singolo = [];
% for f = 1:10%numel(files)
%     Sx = load(fullfile(inDir, files(f).name), 'eeg');
%     if ~isfield(Sx, 'eeg'), error('%s: no eeg struct', files(f).name); end
%     ftx = Sx.eeg;
%     if isempty(fsRef), fsRef = ftx.fsample;
%     elseif ftx.fsample ~= fsRef
%         error('%s: fsample %g differs from first participant (%g)', ...
%             files(f).name, ftx.fsample, fsRef);
%     end
%     for i = 1:numel(ftx.trial)
%         k   = [ftx.monologue(i) ftx.cond(i)];
%         env = ftx.trial{1,i}(end,:)';
%         [tf, loc] = ismember(k, keys, 'rows');
%         if ~tf
%             keys(end+1,:) = k;   %#ok<AGROW>
%             envs{end+1}   = env; %#ok<AGROW>
%             %         elseif numel(envs{loc}) ~= numel(env) || max(abs(envs{loc}-env)) > envTol
%             %             warning('%s: envelope for stim %d cond %d differs from earlier participant', ...
%             %                 files(f).name, k(1), k(2));
%         elseif numel(envs{loc}) ~= numel(env) || max(abs(envs{loc}-env)) > envTol
%             a = envs{loc};  b = env;  m = min(numel(a), numel(b));
%             r = corrcoef(a(1:m), b(1:m));
%             [xc, lg] = xcorr(a(1:m)-mean(a(1:m)), b(1:m)-mean(b(1:m)), 50, 'coeff'); % Signal Processing Toolbox
%             [~, im] = max(xc);
%             fprintf('%s stim %d cond %d: len %d vs %d | r=%.4f | best lag=%d samples | std ratio=%.3f\n', ...
%                 files(f).name, k(1), k(2), numel(a), numel(b), r(1,2), lg(im), std(a(1:m))/std(b(1:m)));
%         end
%     end
% end
% [keys, ord] = sortrows(keys);
% envs = envs(ord);
% nM = size(keys,1);
% fprintf('Master trial list: %d unique (monologue, condition) slots.\n', nM);
% if nM > 28
%     warning('nM = %d > 28: check that monologue/cond values mean what you expect.', nM);
% end
% 
% stim = struct();
% stim.cndVersion = CNDversion;
% stim.names      = {'envelope'};
% stim.data       = envs;                 % 1 x nM, each timeSamples x 1
% stim.fs         = fsRef;
% stim.stimIdxs   = keys(:,1)';
% stim.condIdxs   = keys(:,2)';
% stim.condNames  = condNames;
% save(fullfile(outDir, 'dataStim.mat'), 'stim');
% fprintf('Saved dataStim.mat\n');
% 
% % ===========================================================================
% % PASS 2: per-participant files
% % ===========================================================================
% for f = 1:numel(files)
%     name_singolo = files(f).name;
%     name_singolo = name_singolo(end-8:end-4);
%     S = load(fullfile(inDir, files(f).name));
%     if ~isfield(S, 'eeg'), error('%s: no eeg struct', files(f).name); end
%     ft = S.eeg;
%     nTr = numel(ft.trial);
%     
%     % Optional trial selection
%     if useAuxvalid && isfield(S, 'auxvalid')
%         keep = false(1, nTr);
%         keep(S.auxvalid(:)') = true;   % adapt if auxvalid is logical
%     else
%         keep = true(1, nTr);
%     end
%     
%     % Master slot of each trial of this participant
%     slot = zeros(1, nTr);
%     for i = 1:nTr
%         slot(i) = find(ismember(keys, [ft.monologue(i) ft.cond(i)], 'rows'));
%     end
%     if numel(unique(slot(keep))) < sum(keep)
%         warning('%s: duplicate (monologue, condition) pairs; later trials overwrite earlier ones.', ...
%             files(f).name);
%     end
%     
%     % ------------------------------------------------------------------
%     % EEG
%     % ------------------------------------------------------------------
%     eeg = struct();
%     eeg.cndVersion = CNDversion;
%     eeg.dataType   = 'EEG';
%     eeg.deviceName = '';
%     eeg.fs         = ft.fsample;
%     eeg.data       = cell(1, nM);
%     eeg.origTrialPosition = NaN(1, nM);
%     
%     nLab = numel(ft.label);
%     eegLabels = ft.label(1:nLab-1);          % drop stimulus channel
%     for i = find(keep)
%         % FieldTrip channels x time -> CND time x channels
%         eeg.data{slot(i)} = ft.trial{1,i}(1:nLab-1, :)';
%         eeg.origTrialPosition(slot(i)) = ft.original_trial(i);
%     end
%     
%     eeg.chanlocs = struct('labels', num2cell(eegLabels(:)'));
%     if isfield(ft, 'bad_channels')
%         bc = ft.bad_channels;
%         if iscell(bc)
%             bcNum = [];
%             for c = 1:numel(bc)
%                 v = bc{c};
%                 if isnumeric(v)
%                     bcNum(end+1) = v; %#ok<AGROW>
%                 elseif ischar(v) || isstring(v)
%                     idx = find(strcmp(eegLabels, char(v)), 1);
%                     if ~isempty(idx), bcNum(end+1) = idx; end %#ok<AGROW>
%                 end
%             end
%             bc = bcNum;
%         end
%         for b = bc(:)'
%             if isscalar(b) && isnumeric(b) && b >= 1 && b <= numel(eeg.chanlocs)
%                 eeg.chanlocs(b).type = 'unknown';
%             end
%         end
%     end
%     
%     % External channels: eye tracking recorded with the EEG
%     if isfield(ft, 'ET_continuous') && ~isempty(ft.ET_continuous)
%         eeg.extChan = struct();
%         eeg.extChan.dataType = 'eye-tracking';
%         eeg.extChan.fs       = etFs;
%         eeg.extChan.data     = cell(1, nM);
%         for i = find(keep)
%             % adapt transpose if ET cells are channels x time
%             eeg.extChan.data{slot(i)} = ft.ET_continuous{1,i};
%         end
%     end
%     
%     % ------------------------------------------------------------------
%     % fNIRS: dataset_nirs_et.auxvalid.trials is a 1xN struct array
%     % Matched to EEG trials by stimulus (video == monologue) + condition
%     % ------------------------------------------------------------------
%     fnirs = [];
%     if isfield(S,'dataset_nirs_et') && isstruct(S.dataset_nirs_et) ...
%             && isfield(S.dataset_nirs_et,'auxvalid') ...
%             && isfield(S.dataset_nirs_et.auxvalid,'trials')
%         
%         A  = S.dataset_nirs_et.auxvalid;
%         tr = A.trials;
%         
%         firstWithData = find(arrayfun(@(t) ~isempty(t.data), tr), 1);
%         if isempty(firstWithData)
%             fprintf('%s: fNIRS trials contain no data, skipping.\n', files(f).name);
%         else
%             nCh = size(tr(firstWithData).data, 2);
%             
%             % Optional onset alignment
%             tAxis = A.time(:);
%             i0 = 1;
%             if nirsOnsetAligned
%                 i0 = find(tAxis >= 0, 1);
%                 tAxis = tAxis(i0:end);
%             end
%             
%             fnirs = struct();
%             fnirs.cndVersion   = CNDversion;
%             fnirs.dataType     = 'fNIRS';
%             fnirs.deviceName   = '';
%             fnirs.fs           = A.Fs;
%             fnirs.time         = tAxis;            % s relative to trial onset
%             fnirs.preStimTime  = A.PreStimTime;
%             fnirs.postStimTime = A.PostStimTime;
%             fnirs.onsetAligned = nirsOnsetAligned;
%             fnirs.data         = cell(1, nM);
%             fnirs.chanValid    = cell(1, nM);      % non-standard CND field
%             fnirs.stimDur      = NaN(1, nM);       % EEG/stim duration (s)
%             fnirs.origTrialPosition = eeg.origTrialPosition;
%             
%             % Channel labels from the channels table (source, detector, type)
%             ch = A.channels;
%             fnirs.chanlocs = struct('labels', cell(1, nCh));
%             for c = 1:nCh
%                 s = ch.source(c); d = ch.detector(c); ty = ch.type(c);
%                 if iscell(s),  s  = s{1};  end
%                 if iscell(d),  d  = d{1};  end
%                 if iscell(ty), ty = ty{1}; end
%                 if isnumeric(s), s = sprintf('S%d', s); else, s = char(string(s)); end
%                 if isnumeric(d), d = sprintf('D%d', d); else, d = char(string(d)); end
%                 fnirs.chanlocs(c).labels = [s '_' d '_' char(string(ty))];
%             end
%             
%             nFound = 0;
%             for i = find(keep)
%                 n = slot(i);
%                 fnirs.stimDur(n) = size(ft.trial{1,i}, 2) / ft.fsample;
%                 
%                 wantMono = ft.monologue(i);
%                 wantCond = condNames{ft.cond(i)};
%                 r = find(arrayfun(@(t) isequal(t.video, wantMono) && ...
%                     strcmp(t.condition, wantCond), tr), 1);
%                 
%                 if ~isempty(r) && tr(r).included && ~isempty(tr(r).data)
%                     fnirs.data{n}      = tr(r).data(i0:end, :);  % time x channels
%                     fnirs.chanValid{n} = tr(r).valid_channels;
%                     nFound = nFound + 1;
%                 end
%                 % otherwise slot stays empty
%             end
%             fprintf('%s: fNIRS built, %d/%d EEG trials matched, %d channels.\n', ...
%                 files(f).name, nFound, sum(keep), nCh);
%         end
%     else
%         fprintf('%s: no dataset_nirs_et.auxvalid.trials. Variables: %s\n', ...
%             files(f).name, strjoin(fieldnames(S), ', '));
%     end
%     
%     % ------------------------------------------------------------------
%     % Save dataSub<f>.mat
%     % ------------------------------------------------------------------
%     subIdx = f;   % <- use your own anonymised subject numbering here
%     out = fullfile(outDir, sprintf(['CND_' name_singolo '.mat']));
%     if isempty(fnirs)
%         save(out, 'eeg');
%     else
%         save(out, 'eeg', 'fnirs');
%     end
%     fprintf('Saved %s (%d/%d slots filled in EEG)\n', out, ...
%         sum(~cellfun(@isempty, eeg.data)), nM);
% end
