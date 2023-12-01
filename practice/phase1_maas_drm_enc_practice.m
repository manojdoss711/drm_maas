%% Instructions to experimenter
% This script runs the encoding phase using the encstim stimuli created
% from phase 0. You will first be asked to provide a subject number. 
% Unlike the real version of this task, you can overwrite stimuli and 
% run this task as many times as you like. You can also change the variable 
% speed_mode at the top from 0 to 1 to allow all trials to run rapidly 
% all the way through, and debug_mode can be changed from 0 to 1 to allow 
% the screen to be small.

%% Prelim
clc; fclose('all'); clear; close all; AssertOpenGL; rng('default'); rng('shuffle');
Screen('Preference', 'SkipSyncTests', 1); % change to see screen sync problems
KbName('UnifyKeyNames'); % Make sure keyboard mapping is the same on all supported operating systems
speed_mode = 0; debug_mode = 0;

subject = input('What is the subject ID? (use single quotes if ID contains text) ');
exp_name = 'drm_maas';
exp_path = cd;
stim_dir = fullfile(exp_path,'stim');
stim_file = fullfile(stim_dir,'stim.csv');
data_dir = fullfile(exp_path,'data');
data_file = fullfile(data_dir,[exp_name,'_data_s',num2str(subject),'.mat']);

idx_sub = 1;
idx_ses = 2;
idx_trial = 3;
idx_word = 4;
idx_drm_list = 5;
idx_cb_list = 6;
idx_list_pos = 7;
idx_item = 8;
idx_list_BAS = 9;
idx_list_val = 10;
idx_list_aro = 11;
idx_val = 12;
idx_aro = 13;
idx_emo = 14;
idx_resp1 = 15;
idx_resp2 = 16;
idx_stim1_onset = 17;
idx_stim2_onset = 18;
idx_stim3_onset = 19;
idx_fix_onset = 20;
idx_resp1_onset = 21;
idx_resp2_onset = 22;
idx_block_onset = 23;

list_length = 10;

% Find response device
clear PsychHID;
devices = PsychHID('devices',1); % Need to add "1" for PCs
if ismac
    all_keyboards = find(strcmp({devices.usageName},'Keyboard')); % Look in this structure for all "Keyboards"
    mask1 = ismember({devices.usageName},'Keyboard');
    mask2 = ~ismember({devices.product},'TouchBarUserDevice'); % Prevent selecting touchbar on Macs
    kb_idx = find(mask1 & mask2,1);
elseif ispc
    all_keyboards = find(strcmp({devices.transport},'Keyboard')); % Look in this structure for all "Keyboards"
    mask1 = ismember({devices.transport},'Keyboard');
    kb_idx = find(mask1,1);
end
resp_device = devices(kb_idx).index; % Device index can be 0 on PCs

%% File %%
load(data_file);

% Prevent overwriting and check for data from previous phase(s) except for subject 666
if 0%~isequal(subject,666)
    if isempty(encstim1{end,idx_stim1_onset})
        encstim = encstim1;
    elseif isempty(retstim1{1,idx_stim1_onset})
        error('Data for first Phase 1 already exists. Choose different subject number.');
    end
else, encstim = encstim1;
end

% In case of crash, begin from last trial
num_trial = size(encstim,1);
if 0%~isequal(subject,666)
    for trial_start = 1:num_trial
        if isempty(encstim{trial_start,idx_stim1_onset})
            break
        end
    end
else
    trial_start = 1;
end

%% Create Variables %%

% Durations
if ~speed_mode
    fix_duration = 2.000;
    word_duration = 2.000;
    next_list_duration = 2.000;
    jitter = repmat(.500,repmat(num_trial,1)); % not an actual jitter but rather 1s ISI
else % speed mode
    fix_duration = 0.010;
    word_duration = 0.010;
    next_list_duration = 0.010;
    jitter(1:size(encstim,1),1) = 0.010;
end

% Font sizes
instruc_font_size = 35; % instructions size
fix_font_size = 50;
word_font_size = 50;
next_font_size = 75;

% Colors
black = [0 0 0];    % text color
grey = [127 127 127];   % instruction/fixation background

% Text
instructions = [ ...
    'During this task, you will see lists of words.\n' ...
    'For each word, you are to make a pleasantness judgment\n' ...
    'WHILE THE WORD IS STILL ON THE SCREEN.\n\n' ...
    'A = unpleasant\n' ...
    'S = slightly unpleasant\n' ...
    'K = slightly pleasant\n' ...
    'L = pleasant\n\n' ...
    'Each word will only be on the screen for 2 seconds,\n' ...
    'so please respond as quickly and accurately as possible.\n' ...
    'Each list of words will be separated by the prompt "NEXT LIST".\n' ...
    'Press enter when you are ready.'];

next_list = 'NEXT LIST';

fixation = '+';

end_task = 'You are done with this phase.';

% Buttons
enter = KbName('return');

%% Run Experiment %%

% Try/catch statement
try
    
    % Get screenNumber of stimulation display, and choose the maximum index, which is usually the right one.
    screens=Screen('Screens');
    screenNumber=max(screens);
    
    % If computer is Windows, hide the task bar.
    if ispc, ShowHideWinTaskbarMex(0); end
    
    % Suppress keys to command window (doesn't work on PCs)
    if ismac, ListenChar(-1); end
    
    % Hide mouse
    HideCursor;
    
    % Open a double buffered fullscreen window on the stimulation screen 'screenNumber' and use 'grey' for color
    % 'w' is the handle used to direct all drawing commands to that window
    % 'wRect' is a rectangle defining the size of the window. See "help PsychRects" for help on such rectangles
    [w, wRect]=Screen('OpenWindow',screenNumber,grey);
    [mx, my] = RectCenter(wRect);
    Priority(MaxPriority(w));   % Set priority for script execution to realtime priority
    
    % Initialize calls
    WaitSecs(0.1);
    GetSecs;
    [KeyIsDown, foo, KeyCode]=KbCheck(resp_device);
    KeyIsDown = zeros(size(KeyIsDown));
    foo = zeros(size(foo));
    KeyCode = zeros(size(KeyCode));
    KbQueueCreate(resp_device);
    KbQueueStart;
    [pressed1, firstpress1]=KbQueueCheck(resp_device);
    KbQueueRelease;
    pressed1 = zeros(size(pressed1));
    firstpress1 = zeros(size(firstpress1));
    
    % Display instructions
    Screen('TextSize', w, instruc_font_size);
    DrawFormattedText(w, instructions,'center','center',black);
    Screen('Flip', w);
    
    while KeyCode(enter)==0
        [KeyIsDown, foo, KeyCode]=KbCheck(resp_device);
        WaitSecs(0.001); % prevents overload
    end
    
    % Fixation
    Screen('TextSize', w, fix_font_size);
    DrawFormattedText(w, fixation, 'center', 'center', black);
    [VBLTimestamp, fix_onset1] = Screen('Flip', w);
    encstim{trial_start,idx_block_onset} = [encstim{trial_start,idx_block_onset} fix_onset1]; % for multiple block starts
    WaitSecs('UntilTime',fix_onset1+fix_duration);
    
    %% Loop through trials
    for itrial = trial_start:num_trial
                
        % next lists
        if ismember(itrial,1+list_length:list_length:size(encstim,1))
            Screen('TextSize', w, next_font_size);
            DrawFormattedText(w, next_list, 'center', 'center', black);
            [VBLTimestamp,next_list_onset] = Screen('Flip', w);
            WaitSecs('UntilTime',next_list_onset+next_list_duration);
            
            Screen('TextSize', w, fix_font_size);
            DrawFormattedText(w, fixation, 'center', 'center', black);
            [VBLTimestamp,fix_onset] = Screen('Flip', w);
            encstim{itrial,idx_block_onset} = [encstim{itrial,idx_block_onset} fix_onset]; % in case of multiple starts on same block
            WaitSecs('UntilTime',fix_onset+fix_duration);
        end
        
        KbQueueCreate(resp_device); % Create queue for device
        KbQueueStart; % Begin recording response (needs time to begin)
        Screen('Close'); % Close to not overload
        
        % Present word
        Screen('TextSize', w, word_font_size);
        DrawFormattedText(w, encstim{itrial,idx_word},'center','center',black);
        [VBLTimestamp,encstim{itrial,idx_stim1_onset}]=Screen('Flip', w);
        WaitSecs('UntilTime',encstim{itrial,idx_stim1_onset}+word_duration);
        
        % Fixation
        Screen('TextSize', w, fix_font_size);
        DrawFormattedText(w, fixation, 'center', 'center', black);
        [VBLTimestamp,encstim{itrial,idx_fix_onset}] = Screen('Flip', w);
        WaitSecs('UntilTime',encstim{itrial,idx_fix_onset}+jitter(itrial));
        
        % Record response
        [pressed1,firstpress1]=KbQueueCheck(resp_device);
        if pressed1
            encstim{itrial,idx_resp1} = KbName(find(firstpress1 == min(firstpress1(firstpress1 > 0))));
            encstim{itrial,idx_resp1_onset} = min(firstpress1(firstpress1 > 0));
        else
            encstim{itrial,idx_resp1} = 'none';
            encstim{itrial,idx_resp1_onset} = NaN;
        end
        KbQueueRelease;
        
        % Which encstim to update
        encstim1 = encstim;
        save(data_file,'encstim1','retstim1');

        Screen('TextSize', w, instruc_font_size);
        DrawFormattedText(w, end_task, 'center', 'center', black);
        [VBLTimestamp,next_list_onset] = Screen('Flip', w);
        WaitSecs('UntilTime',next_list_onset+fix_duration);
        
    end 
    
    %% Finish up %%
    
    % Cleanup at end of experiment
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    if ispc, ShowHideWinTaskbarMex(1); end
    if ismac, ListenChar(0); end
    
    % End of experiment:
    
catch % Catch error in case something goes wrong in the 'try' part
    
    % Do same cleanup as at the end of a regular session except save data and give error
    save(data_file,'encstim1','retstim1');
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    if ispc, ShowHideWinTaskbarMex(1); end
    if ismac, ListenChar(0); end
    psychrethrow(psychlasterror);
end
