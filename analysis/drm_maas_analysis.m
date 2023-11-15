%% Initialize
clear
CLOBBER = 0;

all_subs = {'pilot1','pilot2'};
drug_first = {};

exp_path = fullfile('~','Dropbox','drm_maas');
data_dir = fullfile(exp_path,'data');
data_file = 'drm_maas_data_s%s.mat';
hitfa_file = fullfile(exp_path,'analysis','hitfa_data.mat');

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
idx_drug = 24;

drug_conds = {'placebo','JWH-018'}; num_drug = length(drug_conds);
item_conds = {'target','critical','related','unrelated'}; num_item = length(item_conds);
emo_conds = {'negative' 'neutral' 'positive'}; num_emo = length(emo_conds);
enc_resp = {'a' 's' 'l' 'k' 'none'}; num_enc_resp = length(enc_resp);
resp1_opts = {'z' 'm'}; num_resp1 = length(resp1_opts);
resp2_opts = {'1!' '2@' '3#' '4$'}; num_resp2 = length(resp2_opts); num_conf = num_resp1*num_resp2;
high_conf = 4; % change for what is considered high confidence

hitfa_data.enc_raw = []; hitfa_data.ret_raw = [];
for isub = 1:length(all_subs)
    load(fullfile(data_dir,sprintf(data_file,num2str(all_subs{isub}))));
    if ismember(all_subs(isub),drug_first) % which drug in which session
        encstim1(:,idx_drug) = drug_conds(2); encstim2(:,idx_drug) = drug_conds(1);
        retstim1(:,idx_drug) = drug_conds(2); retstim2(:,idx_drug) = drug_conds(1);
    else
        encstim1(:,idx_drug) = drug_conds(1); encstim2(:,idx_drug) = drug_conds(2);
        retstim1(:,idx_drug) = drug_conds(1); retstim2(:,idx_drug) = drug_conds(2);
    end
    encstim = [encstim1; encstim2];
    retstim = [retstim1; retstim2];
    hitfa_data.enc_raw = [hitfa_data.enc_raw; encstim];
    hitfa_data.ret_raw = [hitfa_data.ret_raw; retstim];

    % valence ratings at encoding
    val_ratings = nan(num_drug,num_emo); miss_rate = val_ratings;
    for idrug = 1:num_drug
        drug_mask = ismember(encstim(:,idx_drug),drug_conds(idrug));
        for iemo = 1:num_emo
            emo_mask = ismember(encstim(:,idx_emo),emo_conds(iemo));
            val_vec = zeros(size(encstim,1),1);
            for iresp = 1:num_enc_resp
                resp_mask = ismember(encstim(:,idx_resp1),enc_resp(iresp));
                if iresp ~= num_enc_resp
                    val_vec = val_vec + (drug_mask & emo_mask & resp_mask)*iresp;
                else
                    miss_rate(idrug,iemo) = sum(drug_mask & emo_mask & resp_mask)/sum(drug_mask & emo_mask);
                end
            end
            val_ratings(idrug,iemo) = mean(val_vec(drug_mask & emo_mask & ~resp_mask));
        end % for iemo
    end % for idrug
    hitfa_data.val_ratings(isub,:) = [val_ratings(1,:) val_ratings(2,:)];
    hitfa_data.miss_rate(isub,:) = [miss_rate(1,:) miss_rate(2,:)];

    % Hit and FA rates at retrieval
    hitfa = nan(num_drug,num_emo,num_item);
    hitfa_high = hitfa;
    high_mask = ismember(retstim(:,idx_resp2),resp2_opts(high_conf));
    targf_luref = nan(num_emo*num_drug,num_conf,num_item);
    for idrug = 1:num_drug
        drug_mask = ismember(retstim(:,idx_drug),drug_conds(idrug));
        for iitem = 1:num_item
            item_mask = ismember(retstim(:,idx_item),item_conds(iitem));
            for iemo = 1:num_emo
                emo_mask = ismember(retstim(:,idx_emo),emo_conds(iemo));
                for iresp1 = 1:num_resp1
                    resp1_mask = ismember(retstim(:,idx_resp1),resp1_opts(iresp1));
                    if iresp1 == 1 % only need hit/fa rates
                        hitfa(idrug,iemo,iitem) = sum(drug_mask & item_mask & emo_mask & resp1_mask)/...
                            sum(drug_mask & item_mask & emo_mask);
                        hitfa_high(idrug,iemo,iitem) = sum(drug_mask & item_mask & emo_mask & resp1_mask & high_mask)/...
                            sum(drug_mask & item_mask & emo_mask);
                    end
                    for iresp2 = 1:num_resp2
                        resp2_mask = ismember(retstim(:,idx_resp2),resp2_opts(iresp2));
                        idx1 = iemo+(idrug-1)*num_emo;
                        idx2 = iresp2+(iresp1-1)*num_resp2;
                        targf_luref(idx1,idx2,iitem) = sum(drug_mask & item_mask & emo_mask & resp1_mask & resp2_mask);
                    end % for iresp2
                end % for iresp1
            end % for iemo
        end % for iitem
    end % for idrug
    targf_luref = targf_luref(:,[num_conf/2:-1:1 num_conf/2+1:num_conf],:); % reverse score "yes" responses

    % Store data
    hitfa_data.hit_rate(isub,:) = [hitfa(1,:,1) hitfa(2,:,1)];
    hitfa_data.crit_fa_rate(isub,:) = [hitfa(1,:,2) hitfa(2,:,2)];
    hitfa_data.rel_fa_rate(isub,:) = [hitfa(1,:,3) hitfa(2,:,3)];
    hitfa_data.unrel_fa_rate(isub,:) = [hitfa(1,:,4) hitfa(2,:,4)];
    hitfa_data.prec(isub,:) = hitfa_data.hit_rate(isub,:) - hitfa_data.crit_fa_rate(isub,:);
    hitfa_data.acc(isub,:) = hitfa_data.hit_rate(isub,:) - hitfa_data.unrel_fa_rate(isub,:);
    hitfa_data.crit_rel(isub,:) = hitfa_data.crit_fa_rate(isub,:) - hitfa_data.rel_fa_rate(isub,:);
    hitfa_data.crit_unrel(isub,:) = hitfa_data.crit_fa_rate(isub,:) - hitfa_data.unrel_fa_rate(isub,:);
    hitfa_data.rel_unrel(isub,:) = hitfa_data.rel_fa_rate(isub,:) - hitfa_data.unrel_fa_rate(isub,:);

    hitfa_data.hi_hit_rate(isub,:) = [hitfa_high(1,:,1) hitfa_high(2,:,1)];
    hitfa_data.hi_crit_fa_rate(isub,:) = [hitfa_high(1,:,2) hitfa_high(2,:,2)];
    hitfa_data.hi_rel_fa_rate(isub,:) = [hitfa_high(1,:,3) hitfa_high(2,:,3)];
    hitfa_data.hi_unrel_fa_rate(isub,:) = [hitfa_high(1,:,4) hitfa_high(2,:,4)];
    hitfa_data.hi_prec(isub,:) = hitfa_data.hi_hit_rate(isub,:) - hitfa_data.hi_crit_fa_rate(isub,:);
    hitfa_data.hi_acc(isub,:) = hitfa_data.hi_hit_rate(isub,:) - hitfa_data.hi_unrel_fa_rate(isub,:);
    hitfa_data.hi_crit_rel(isub,:) = hitfa_data.hi_crit_fa_rate(isub,:) - hitfa_data.hi_rel_fa_rate(isub,:);
    hitfa_data.hi_crit_unrel(isub,:) = hitfa_data.hi_crit_fa_rate(isub,:) - hitfa_data.hi_unrel_fa_rate(isub,:);
    hitfa_data.hi_rel_unrel(isub,:) = hitfa_data.hi_rel_fa_rate(isub,:) - hitfa_data.hi_unrel_fa_rate(isub,:);

    hitfa_data.targf(:,:,isub) = targf_luref(:,:,1);
    hitfa_data.crit_luref(:,:,isub) = targf_luref(:,:,2);
    hitfa_data.rel_luref(:,:,isub) = targf_luref(:,:,3);
    hitfa_data.unrel_luref(:,:,isub) = targf_luref(:,:,4);

end % for isub



