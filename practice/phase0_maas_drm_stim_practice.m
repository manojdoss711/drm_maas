%% Instructions to experimenter %%
% This script creates all stimuli and will only have to be run once per
% subject. It creates data frames with blanks for responses and stimulus
% onsets for all encoding session and all retrieval sessions. You will
% only be asked to enter a subject number (no counterbalancing order).
% Unlike the real version of this task, you can overwrite stimuli.

%% Prelim
clc; fclose('all'); clear; close all; rng('default'); rng('shuffle');

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

num_blank = idx_block_onset - idx_emo;
num_drug = 1;
num_emo = 2;
num_targ_enc = 10;
ret_targ_pos = 1;
emo_cond = {'negative' 'positive'};

%% File %%

% Read existing result file and prevent overwriting files from a previous subject (except for subject 666)
% if ~isequal(subject,666) && fopen(data_file,'rt')~=-1
%     fclose('all');
%     error('Stimulus set already exists! Choose a different subject number.');
% end

%% Create Stimuli %%
stimuli = readtable(stim_file);
stimuli = [num2cell(nan(size(stimuli,1),3)) table2cell(stimuli)];
stimuli(:,idx_sub) = {subject};

% Label sessions
stimuli(ismember(stimuli(:,idx_cb_list),'X'),idx_ses) = num2cell(0);

% Split stimuli for encoding and retrieval
targ_mask = ismember(stimuli(:,idx_item),'target');
encstim = stimuli(targ_mask,:);

targ_mask = ismember(cell2mat(stimuli(:,idx_list_pos)),ret_targ_pos);
crit_mask = ismember(cell2mat(stimuli(:,idx_list_pos)),0);
rel_mask = cell2mat(stimuli(:,idx_list_pos)) > num_targ_enc;
unrel_mask = isnan(cell2mat(stimuli(:,idx_list_pos)));
retstim = stimuli(targ_mask | crit_mask | rel_mask | unrel_mask,:);

% Fill cells for responses
encstim = [encstim cell(size(encstim,1),num_blank)];
retstim = [retstim cell(size(retstim,1),num_blank)];

% Randomize encstim (no pseudorandomization with only 2 lists) and add trial number
unique_drm = unique(encstim(:,idx_drm_list));
num_drm_list = length(unique_drm);
list_order = unique_drm(randperm(num_drm_list));
encstim1 = [];
for ilist = 1:num_drm_list
    drm_list_mask = ismember(encstim(:,idx_drm_list),list_order(ilist));
    encstim1 = [encstim1; encstim(drm_list_mask,:)];
end
encstim1(:,idx_trial) = num2cell([1:size(encstim1,1)]'); % add trial number

% Pseudorandomization (no more than two repeating words of a given valence) and add trial number
retstim = retstim(randperm(size(retstim,1)),:); % pre-pseudorandomization randomization
pseudo_key = [];
for irand = 1:4 % 1 list per valence (only 2) and 4 item conditions
    x = randperm(num_emo);
    pseudo_key = [pseudo_key; x'];
end

retstim1 = cell(size(retstim));
for iemo = 1:num_emo
    mask1 = ismember(retstim(:,idx_emo),emo_cond(iemo));
    mask2 = ismember(pseudo_key,iemo);
    retstim1(mask2,:) = retstim(mask1,:);
end
retstim1(:,idx_trial) = num2cell([1:size(retstim1,1)]'); % add trial number

% Save
save(data_file,'encstim1','retstim1');
