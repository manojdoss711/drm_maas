clc;
fclose('all');
clear all;
close all;

subjects = [1:7,9:24];
plc_first_subs = [1,2,14,13,9,21,22,4,17,11,24,12];

all_encstim = [];
all_retstim = [];

for isub = subjects
    
    data_file = ...
        ['/Users/manojdoss/Dropbox/TARE/drm/data/drm_TARE_data_s',num2str(isub),'.mat'];
    load(data_file)
    
    if ismember(isub,plc_first_subs)
        drug_cond = {'plc_first'};
    else
        drug_cond = {'thc_first'};
    end
    
    encstim = [encstim1; encstim2];
    sub_id = {['s',num2str(isub)]};
    sub_id = repmat(sub_id,length(encstim),1);
    drug_id = repmat(drug_cond,length(encstim),1);
    encstim = [sub_id drug_id encstim];
    all_encstim = [all_encstim; encstim];
    
    retstim = [retstim1; retstim2];
    sub_id = {['s',num2str(isub)]};
    sub_id = repmat(sub_id,length(retstim),1);
    drug_id = repmat(drug_cond,length(retstim),1);
    retstim = [sub_id drug_id retstim];
    all_retstim = [all_retstim; retstim];
                
end