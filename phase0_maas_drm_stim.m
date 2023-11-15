%% Instructions to experimenter %%
% This script creates all stimuli and will only have to be run once per
% subject. It creates data frames with blanks for responses and stimulus
% onsets for all encoding session and all retrieval sessions. You will
% first be asked to enter a counterbalancing order followed by a subject
% number. Once stimuli are created, you cannot overwrite them unless you 
% manually go into the directory msdoss/data and remove the file created.
% Subject number 666 can be used for piloting, which allows you to
% overwrite the file created.
% This is the most recent version from 23/11/15

%% Prelim
clc; fclose('all'); clear; close all; rng('default'); rng('shuffle');

cb_order = input('What is the counterbalancing order? (1 or 2, no quotes) ');
if ~ismember(cb_order,[1,2]), error('Counterbalancing order must be 1 or 2!'); end

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
num_drug = 2;
num_emo = 3;
num_targ_enc = 10;
ret_targ_pos = 1;
emo_cond = {'negative' 'neutral' 'positive'};

%% File %%

% Read existing result file and prevent overwriting files from a previous subject (except for subject 666)
if ~isequal(subject,666) && fopen(data_file,'rt')~=-1
    fclose('all');
    error('Stimulus set already exists! Choose a different subject number.');
end

%% Create Stimuli %%
stimuli = readtable(stim_file);
stimuli = [num2cell(nan(size(stimuli,1),3)) table2cell(stimuli)];
stimuli(:,idx_sub) = {subject};

% Label sessions
if ismember(cb_order,1)
    stimuli(ismember(stimuli(:,idx_cb_list),'A'),idx_ses) = num2cell(1);
    stimuli(ismember(stimuli(:,idx_cb_list),'B'),idx_ses) = num2cell(2);
else
    stimuli(ismember(stimuli(:,idx_cb_list),'A'),idx_ses) = num2cell(2);
    stimuli(ismember(stimuli(:,idx_cb_list),'B'),idx_ses) = num2cell(1);
end

% Split stimuli for encoding and retrieval
targ_mask = ismember(stimuli(:,idx_item),'target');
encstim = stimuli(targ_mask,:);

targ_mask = ismember(cell2mat(stimuli(:,idx_list_pos)),ret_targ_pos);
crit_mask = ismember(cell2mat(stimuli(:,idx_list_pos)),0);
rel_mask = cell2mat(stimuli(:,idx_list_pos)) > num_targ_enc;
unrel_mask = isnan(cell2mat(stimuli(:,idx_list_pos)));
retstim = stimuli(targ_mask | crit_mask | rel_mask | unrel_mask,:);

% Fill cells for responses and onsets
encstim = [encstim cell(size(encstim,1),num_blank)];
retstim = [retstim cell(size(retstim,1),num_blank)];

% Split for session, pseudorandomize trial order based on emotion, and add trial number
allstim = cell(num_drug,1);
for idata = 1:num_drug % for encstim

    % split and randomize
    dat_tmp = encstim(ismember(cell2mat(encstim(:,idx_ses)),idata),:);
    [unique_drm, idx1] = unique(dat_tmp(:,idx_drm_list));
    num_drm_list = length(unique_drm);
    unique_drm = [unique_drm dat_tmp(idx1,idx_emo)];
    
    % pseudorandomization (no more than two repeating lists of a given valence)
    unique_drm = unique_drm(randperm(num_drm_list),:); % randomize here because unique sorts in alphabetical order
    pseudo_key = [];
    for irand = 1:9 % 9 lists per valence other than neutral
        x = randperm(num_emo);
        pseudo_key = [pseudo_key; x'];
    end
    
    list_order = cell(size(unique_drm,1),2);
    for iemo = 1:num_emo
        mask1 = ismember(unique_drm(:,2),emo_cond(iemo));
        mask2 = ismember(pseudo_key,iemo);
        list_order(mask2,:) = unique_drm(mask1,:);
    end

    encstim_tmp = [];
    for ilist = 1:num_drm_list
        drm_list_mask = ismember(dat_tmp(:,idx_drm_list),list_order(ilist));
        encstim_tmp = [encstim_tmp; dat_tmp(drm_list_mask,:)];
    end

    encstim_tmp(:,idx_trial) = num2cell([1:size(encstim_tmp,1)]'); % add trial number
    allstim{idata} = encstim_tmp;
end
encstim1 = allstim{1}; encstim2 = allstim{2};

retstim = retstim(randperm(size(retstim,1)),:); % pre-pseudorandomization randomization
allstim = cell(num_drug,1);
for idata = 1:num_drug % for retstim

    % split
    dat_tmp = retstim(ismember(cell2mat(retstim(:,idx_ses)),idata),:);
    
    % pseudorandomization (no more than two repeating words of a given valence)
    pseudo_key = [];
    for irand = 1:36 % 9 lists per valence and 4 item conditions
        x = randperm(num_emo);
        pseudo_key = [pseudo_key; x'];
    end
    
    retstim_tmp = cell(size(dat_tmp));
    for iemo = 1:num_emo
        mask1 = ismember(dat_tmp(:,idx_emo),emo_cond(iemo));
        mask2 = ismember(pseudo_key,iemo);
        retstim_tmp(mask2,:) = dat_tmp(mask1,:);
    end
    
    retstim_tmp(:,idx_trial) = num2cell([1:size(retstim_tmp,1)]'); % add trial number
    allstim{idata} = retstim_tmp;
end
retstim1 = allstim{1}; retstim2 = allstim{2};

save(data_file,'encstim1','encstim2','retstim1','retstim2'); % save
