%% Instructions to experimenter
% This script runs the retrieval phase using the retstim stimuli created
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
        error('Unfinished data from first Phase 1. Finish first Phase 1.');
    elseif isempty(retstim1{end,idx_stim1_onset})
        retstim = retstim1;
    elseif isempty(encstim2{1,idx_stim1_onset})
        error('Data for first Phase 2 already exists. Choose different subject number.');
    end
else, retstim = retstim1;
end

% In case of crash, begin from last trial
num_trial = size(retstim,1);
if 0%~isequal(subject,666)
    for trial_start = 1:length(retstim)
        if isempty(retstim{trial_start,idx_stim1_onset})
            break
        end
    end
else
    trial_start = 1;
end

%% Create Variables %%

% Durations
min_iti = .500; max_iti = 1.500; num_points = (max_iti - min_iti)*60+1; % change these dependent on refresh rate of monitor (60 Hz in this case)
if ~speed_mode
    fix_duration = 2.000;
    word_duration = 1.000;
    jitter = datasample(linspace(min_iti,max_iti,num_points),num_trial);
else % speed mode
    fix_duration = 0.010;
    word_duration = 0.010;
    jitter(1:size(retstim,1),1) = 0.010;
end

% Font sizes
instruc_font_size = 35; % instructions size
fix_font_size = 50;
word_font_size = 50;   % word size
opt_font_size = 35;

% Locations
resp_loc = 300;

% Colors
black = [0 0 0];    % text color
grey = [127 127 127];   % instruction/fixation background

% Text
instructions = [
    'Now we will test your memory for the word lists from the last session.\n' ...
    'You will see the words that were studied.\n' ...
    '(i.e., the ones you rated for pleasantness)\n' ...
    'and words that were not studied.\n' ...
    'If you remember the word press "Z". If not press "M".\n' ...
    'Pay close attention, because some of the non-studied words\n' ...
    'are closely related to studied words, and\n' ...
    'you should only press "Z" for words that were previously presented.\n\n' ...
    'After each of these responses, you will rate your confidence\n' ...
    'in your memory decision from 1 to 4 at the top of the keyboard\n' ...
    '(1 = guessing, 2 = uncertain, 3 = confident, 4 = certain).\n' ...
    'Please use the full range of responses. That is, do not simply use\n' ...
    'only two or three of the confidence buttons but rather\n' ...
    'distribute your responses across all four buttons.\n\n' ...
    'This task will be self-paced, and\n' ...
    'the response options will be displayed on the screen\n' ...
    'shortly after each word is presented.\n' ...
    'You can only respond when the response options are displayed.\n' ...
    'Press enter when you are ready.'];
    
fixation = '+'; % fixation cross

task_quest = 'Did you see this word?';
resp_options = 'Z = yes                      M = no';

conf_question = 'How confident are you?';
conf_options1 = '1                       2                       3                    4';
conf_options2 = 'guessing          uncertain          confident          certain';

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
    [KeyIsDown, endrt, KeyCode1]=KbCheck(resp_device);
    KeyIsDown = zeros(size(KeyIsDown));
    endrt = zeros(size(endrt));
    KeyCode1 = zeros(size(KeyCode1));
    KeyCode2 = zeros(size(KeyCode1));
    
    % Display instructions
    Screen('TextSize', w, instruc_font_size);
    DrawFormattedText(w, instructions,'center','center',black);
    Screen('Flip', w);
    
    while KeyCode1(enter)==0
        [KeyIsDown, endrt, KeyCode1]=KbCheck(resp_device);
        WaitSecs(0.001);
    end
    
    % Fixation
    Screen('TextSize', w, fix_font_size);
    DrawFormattedText(w, fixation, 'center', 'center', black);
    [VBLTimestamp, fix_onset1] = Screen('Flip', w);
    retstim{trial_start,idx_block_onset} = [retstim{trial_start,idx_block_onset} fix_onset1]; % for multiple block starts
    WaitSecs('UntilTime',fix_onset1+fix_duration);
    
    % Loop through trials
    for itrial = trial_start:num_trial
        
        Screen('Close'); % Close to not overload
        
        % Present word only
        Screen('TextSize', w, word_font_size);
        DrawFormattedText(w, retstim{itrial,idx_word},'center','center',black);
        [VBLTimestamp,retstim{itrial,idx_stim1_onset}]=Screen('Flip', w);
        WaitSecs('UntilTime',retstim{itrial,idx_stim1_onset}+word_duration);
        
        % Present word and response options
        DrawFormattedText(w, retstim{itrial,idx_word},'center','center',black);
        Screen('TextSize', w, opt_font_size);
        DrawFormattedText(w, task_quest,'center',my - resp_loc,black);
        DrawFormattedText(w, resp_options,'center',my + resp_loc,black);
        [VBLTimestamp,retstim{itrial,idx_stim2_onset}]=Screen('Flip', w);
                
        % Clear keys
        KeyCode1 = zeros(size(KeyCode1));
        
        % while loop to show stimulus until yes or no
        while   ~(isequal(KbName(find(KeyCode1,1,'last')),'z') || isequal(KbName(find(KeyCode1,1,'last')),'m'))
            [retstim{itrial,idx_resp1_onset},KeyCode1,deltasecs]=KbPressWait(resp_device);
        end

        % Present word and confidence options
        Screen('TextSize', w, word_font_size);
        DrawFormattedText(w, retstim{itrial,idx_word},'center','center',black);
        Screen('TextSize', w, opt_font_size);
        DrawFormattedText(w, conf_question,'center',my - resp_loc,black);
        DrawFormattedText(w, conf_options1,'center',my + resp_loc-15,black);
        DrawFormattedText(w, conf_options2,'center',my + resp_loc+15,black);
        [VBLTimestamp,retstim{itrial,idx_stim3_onset}]=Screen('Flip', w);

        % Clear keys
        KeyCode2 = zeros(size(KeyCode2));

        % while loop to show stimulus until 1, 2, 3, or 4
        while   ~(isequal(KbName(find(KeyCode2,1,'last')),'1!') || isequal(KbName(find(KeyCode2,1,'last')),'2@') || ...
                isequal(KbName(find(KeyCode2,2,'last')),'3#') || isequal(KbName(find(KeyCode2,1,'last')),'4$'))
            [retstim{itrial,idx_resp2_onset},KeyCode2,deltasecs]=KbPressWait(resp_device);
        end
        
        % Fixation
        Screen('TextSize', w, fix_font_size);
        Screen('TextSize', w, word_font_size);
        DrawFormattedText(w, fixation, 'center', 'center', black);
        [VBLTimestamp,retstim{itrial,idx_fix_onset}] = Screen('Flip', w);
        
        retstim{itrial,idx_resp1} = KbName(find(KeyCode1,1,'last'));
        retstim{itrial,idx_resp2} = KbName(find(KeyCode2,1,'last'));
        
        retstim1 = retstim;
        save(data_file,'encstim1','retstim1');
        
        WaitSecs('UntilTime',retstim{itrial,idx_fix_onset}+jitter(itrial));

        Screen('TextSize', w, instruc_font_size);
        DrawFormattedText(w, end_task, 'center', 'center', black);
        [VBLTimestamp,next_list_onset] = Screen('Flip', w);
        WaitSecs('UntilTime',next_list_onset+fix_duration);
        
    end    % Trial loop
    
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
    psychrethrow(psychlasterror);   % Output the error message that describes the error
end
