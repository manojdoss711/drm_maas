%% Initialize
clear
CLOBBER = 0;

all_subs = [10,12];
pla_first = [10];

exp_path = fullfile('~','Dropbox','drm2104');
data_dir = fullfile(exp_path,'data');
data_file = 'drm2104_data_s%d.mat';
hitfa_file = fullfile(exp_path,'analysis','hitfa_data.mat');

idx_sub = 1;
idx_trial = 2;
idx_list = 3;
idx_drm_list = 4;
idx_word = 5;
idx_list_pos = 6;
idx_item = 7;
idx_sesh = 8;
idx_resp1 = 9;
idx_resp2 = 10;
idx_stim1_onset = 11;
idx_stim2_onset = 12;
idx_stim3_onset = 13;
idx_fix_onset = 14;
idx_resp1_onset = 15;
idx_resp2_onset = 16;
idx_trig_onset = 17;

drug_conds = 1:2; num_drug = length(drug_conds);
item_conds = 1:3; num_item = length(item_conds);
resp1_opts = {'z' 'm'}; num_resp1 = length(resp1_opts);
resp2_opts = {'1!' '2@' '3#' '4$'}; num_resp2 = length(resp2_opts);
high_conf = 4; % change for what is considered high confidence

hitfa_data.enc_raw = []; hitfa_data.ret_raw = [];
for isub = 1:length(all_subs)
    load(fullfile(data_dir,sprintf(data_file,all_subs(isub))));
    encstim = [encstim1; encstim2];
    retstim = [retstim1; retstim2];
    hitfa_data.enc_raw = [hitfa_data.enc_raw; encstim];
    hitfa_data.ret_raw = [hitfa_data.ret_raw; retstim];

% SAVE FOR UNBLINDING
%     % Masks
%     if ismember(isub,plc_first_subs)
%         plc_mask = ismember(cell2mat(retstim(:,col_sesh)),1);
%         drug_mask = ismember(cell2mat(retstim(:,col_sesh)),2);
%     else
%         plc_mask = ismember(cell2mat(retstim(:,col_sesh)),2);
%         drug_mask = ismember(cell2mat(retstim(:,col_sesh)),1);
%     end
        
    hitfa = nan(num_drug,num_item);
    hitfa_high = hitfa;
    old_mask = ismember(retstim(:,idx_resp1),'z');
    high_mask = ismember(retstim(:,idx_resp2),resp2_opts(high_conf));

    for idrug = 1:num_drug
        drug_mask = ismember(cell2mat(retstim(:,idx_sesh)),drug_conds(idrug));
        for iitem = 1:num_item
            item_mask = ismember(cell2mat(retstim(:,idx_item)),item_conds(iitem));
            hitfa(idrug,iitem) = sum(old_mask & drug_mask & item_mask)/...
                sum(drug_mask & item_mask);
            hitfa_high(idrug,iitem) = sum(old_mask & high_mask & drug_mask & item_mask)/...
                sum(drug_mask & item_mask);
        end % for iitem
    end % for idrug
    
    hitfa_data.hitfa_rate(isub,:) = [hitfa(1,:) hitfa(2,:)];
    hitfa_data.hiconf_hitfa_rate(isub,:) = [hitfa_high(1,:) hitfa_high(2,:)];
    
end
