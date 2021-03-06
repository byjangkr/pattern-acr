clear all; close all;
clc

%addpath('step3_svm');
addpath('func');
addpath('libsvm');


fn.spklistfile = '/home/byjang/corpus/EST/speakerA';
fn.scorefile = '/home/byjang/corpus/EST/score/score_flue.mat';
fn.flu_set = char('../exp_data/set1.feat','../exp_data/set2.feat','../exp_data/set3.feat');
%fn.flu_set = char('../exp_data/rmdsf_set1.feat','../exp_data/rmdsf_set2.feat','../exp_data/rmdsf_set3.feat');
fn.dsf_set = char('../exp_data/set1.feat_dsf','../exp_data/set2.feat_dsf','../exp_data/set3.feat_dsf');
fn.trans_dsflist = '/home/byjang/corpus/EST/tools/dsflist.log';

%% initial parameter

figNum = 0; % initial a figure number

para.gNum = 6; % number of people in a group (max : 48, min : 1) for cross-validation
para.flagCorr = 1; % print correlation value each feature with score -> 0 : not print 1 : print
para.corr_task_id = [2 3 4 5]; % using task index for correlation between score of raters and each features
para.maxEpoch = 1; % the number of epoch for regression
para.levelScale = 5;
para.set = [1 2 3];

para.selReg = 3; % select regression machine 
% 1: linear combination 2: decision tree
% 3: support vector regression 4: adaptive neuro-fuzzy imference system

para.fid = [1 2 4];
%para.fid = [1 2 3 4 5 6 7 8 9 10 11 12 13]; % all
%para.fid = [1 2 3 4 5 6 7]; % fluency
%para.fid = [8 9 10 11 12 13]; % disfluency
% para.fid = [11 12 13]; % repetition of disfluency
%para.fid = [1 2 3 4 5 6 7 11 12 13]; % flu + rep
%para.fid = [1 2 3 4 6 9 10 13 ]; % core (high corr)
para.task_id = [2 3 4 5]; % using task index for correlation between score of raters and each features

%% Make est data
para.tranneg = 1; % translate from negative feat to positive feat
para.scoretype = 'level'; % level or rubric (fluency score)
para.scoretypeinx = 0;
% if type is level, then 0 - task level, 1 - speaker level
% if type is rubric, then 0 - mean of rubrics, number is the order of rubric

para.useDff = 1; % using disfluency fesature ([8 9 10 11 12 13 14 15 16 17 18 19 20 21 22])
para.useTrandf = 0; % using directly extract the disfluency features from transcription

        
flu_data = make_est_data(fn.flu_set,fn.scorefile,para);
fludsf_data = add_est_data(flu_data,fn.scorefile,para,fn.dsf_set);
%fludsf_mdsf_data = add_est_data(fludsf_data,fn.scorefile,para,fn.trans_dsflist);

%% Correlation features
corr_data = [];
corr_feat = fludsf_data;
for itask=para.corr_task_id
    corr_data = [corr_data; corr_feat(corr_feat(:,3)==itask,:)];
end
for iSet = para.set
    fprintf('>> Correlation of SET%d between rater score(index:0) and each features\n',iSet);
    cdata = corr_data(corr_data(:,2)==iSet,4:end);
    corrm = analysis_correlation(cdata,0:(size(cdata,2)-1));
end


%% Regression & Classification
fluency_data_reg = fludsf_data;
corr_task_ary_set1 = []; corr_task_ary_set2 = []; corr_task_ary_set3 = [];
corr_spk_ary_set1 = []; corr_spk_ary_set2 = []; corr_spk_ary_set3 = [];
acc1 = []; acc2 = []; acc3 = [];
err1 = []; err2 = []; err3 = [];
% MS : Machine score, HS : Humman score
for epoch=1:para.maxEpoch

	switch para.selReg
        case 1
            [SPK1, MS1, HS1, W1] = run_ls(fluency_data_reg((fluency_data_reg(:,2)==1),:),para.task_id,para.gNum,para.fid);
            [SPK2, MS2, HS2, W2] = run_ls(fluency_data_reg((fluency_data_reg(:,2)==2),:),para.task_id,para.gNum,para.fid);
            [SPK3, MS3, HS3, W3] = run_ls(fluency_data_reg((fluency_data_reg(:,2)==3),:),para.task_id,para.gNum,para.fid);


        case 2
            [SPK1, MS1, HS1] = run_dt(fluency_data_reg((fluency_data_reg(:,2)==1),:),para.task_id,para.gNum,para.fid);
            [SPK2, MS2, HS2] = run_dt(fluency_data_reg((fluency_data_reg(:,2)==2),:),para.task_id,para.gNum,para.fid);
            [SPK3, MS3, HS3] = run_dt(fluency_data_reg((fluency_data_reg(:,2)==3),:),para.task_id,para.gNum,para.fid);

        case 3
%             original
            [SPK1, MS1, HS1] = run_svm_all(fluency_data_reg((fluency_data_reg(:,2)==1),:),para.task_id,para.gNum,para.fid);
            [SPK2, MS2, HS2] = run_svm_all(fluency_data_reg((fluency_data_reg(:,2)==2),:),para.task_id,para.gNum,para.fid);
            [SPK3, MS3, HS3] = run_svm_all(fluency_data_reg((fluency_data_reg(:,2)==3),:),para.task_id,para.gNum,para.fid);

%             % with item
%             [SPK1, MS1, HS1] = run_svm_with_item(fluency_data((fluency_data(:,2)==1),:),score((score(:,2)==1),:),para.task_id,para.gNum,para.fid);
%             [SPK2, MS2, HS2] = run_svm_with_item(fluency_data((fluency_data(:,2)==2),:),score((score(:,2)==2),:),para.task_id,para.gNum,para.fid);
%             [SPK3, MS3, HS3] = run_svm_with_item(fluency_data((fluency_data(:,2)==3),:),score((score(:,2)==3),:),para.task_id,para.gNum,para.fid);
        
        case 4
            [SPK1, MS1, HS1] = run_anfis(fluency_data_reg((fluency_data_reg(:,2)==1),:),para.task_id,para.gNum,para.fid);
            [SPK2, MS2, HS2] = run_anfis(fluency_data_reg((fluency_data_reg(:,2)==2),:),para.task_id,para.gNum,para.fid);
            [SPK3, MS3, HS3] = run_anfis(fluency_data_reg((fluency_data_reg(:,2)==3),:),para.task_id,para.gNum,para.fid);
                      
        otherwise
            fprintf('error!! incorrect seleted number of regression machine\n');
            return;
    end

    % performance
    numSpk = 48/para.gNum;
    %numSpk = size(stdSpkCell,1)/para.gNum;
    spkMS1=[];  spkMS2=[];  spkMS3=[]; % combine score of each task
    spkHS1=[];  spkHS2=[];  spkHS3=[];
    
    usedTask = size(MS1,1)/numSpk;
    for i=1:para.gNum
        spkMS1 = [spkMS1 mean(reshape(MS1(:,i),numSpk,size(MS1,1)/numSpk),2)]; 
        spkMS2 = [spkMS2 mean(reshape(MS2(:,i),numSpk,size(MS2,1)/numSpk),2)]; 
        spkMS3 = [spkMS3 mean(reshape(MS3(:,i),numSpk,size(MS3,1)/numSpk),2)]; 
        spkHS1 = [spkHS1 mean(reshape(HS1(:,i),numSpk,size(HS1,1)/numSpk),2)];
        spkHS2 = [spkHS2 mean(reshape(HS2(:,i),numSpk,size(HS2,1)/numSpk),2)];
        spkHS3 = [spkHS3 mean(reshape(HS3(:,i),numSpk,size(HS3,1)/numSpk),2)]; 
    end
    
    corr_task_set1 = corr(reshape(MS1,numSpk*usedTask*para.gNum,1),reshape(HS1,numSpk*usedTask*para.gNum,1));
    corr_task_set2 = corr(reshape(MS2,numSpk*usedTask*para.gNum,1),reshape(HS2,numSpk*usedTask*para.gNum,1));
    corr_task_set3 = corr(reshape(MS3,numSpk*usedTask*para.gNum,1),reshape(HS3,numSpk*usedTask*para.gNum,1));
    
    corr_task_ary_set1 = [corr_task_ary_set1; corr_task_set1];
    corr_task_ary_set2 = [corr_task_ary_set2; corr_task_set2];
    corr_task_ary_set3 = [corr_task_ary_set3; corr_task_set3];
    
    
    % correlation between SVR score and humman score of each set
    perOfSet1 = corr(reshape(spkMS1,para.gNum*numSpk,1),reshape(spkHS1,para.gNum*numSpk,1));
    perOfSet2 = corr(reshape(spkMS2,para.gNum*numSpk,1),reshape(spkHS2,para.gNum*numSpk,1));
    perOfSet3 = corr(reshape(spkMS3,para.gNum*numSpk,1),reshape(spkHS3,para.gNum*numSpk,1));

    corr_spk_ary_set1 = [corr_spk_ary_set1; perOfSet1];
    corr_spk_ary_set2 = [corr_spk_ary_set2; perOfSet2];
    corr_spk_ary_set3 = [corr_spk_ary_set3; perOfSet3];

    errOfSet1 = abs(reshape(spkMS1,para.gNum*numSpk,1)-reshape(spkHS1,para.gNum*numSpk,1));
    errOfSet2 = abs(reshape(spkMS2,para.gNum*numSpk,1)-reshape(spkHS2,para.gNum*numSpk,1));
    errOfSet3 = abs(reshape(spkMS3,para.gNum*numSpk,1)-reshape(spkHS3,para.gNum*numSpk,1));
    
    err1 = [err1; sum(errOfSet1)/length(errOfSet1)];
    err2 = [err2; sum(errOfSet2)/length(errOfSet2)];
    err3 = [err3; sum(errOfSet3)/length(errOfSet3)];
    
    % classification
    cHS1 = [];  cHS2 = [];  cHS3 = [];
    cMS1 = [];  cMS2 = [];  cMS3 = [];
    for j=1:para.gNum
        cHS1 = [cHS1; reshape(ceil(HS1(:,j)./para.levelScale),numSpk,size(HS1,1)/numSpk)];
        cHS2 = [cHS2; reshape(ceil(HS2(:,j)./para.levelScale),numSpk,size(HS2,1)/numSpk)];
        cHS3 = [cHS3; reshape(ceil(HS3(:,j)./para.levelScale),numSpk,size(HS3,1)/numSpk)];
        cMS1 = [cMS1; reshape(ceil(MS1(:,j)./para.levelScale),numSpk,size(MS1,1)/numSpk)];
        cMS2 = [cMS2; reshape(ceil(MS2(:,j)./para.levelScale),numSpk,size(MS2,1)/numSpk)];
        cMS3 = [cMS3; reshape(ceil(MS3(:,j)./para.levelScale),numSpk,size(MS3,1)/numSpk)];
    end

    cHS1 = round(mean(cHS1,2));
    cHS2 = round(mean(cHS2,2));
    cHS3 = round(mean(cHS3,2));
    cMS1 = round(mean(cMS1,2));
    cMS2 = round(mean(cMS2,2));
    cMS3 = round(mean(cMS3,2));

    acc1 = [acc1; length(find((cHS1-cMS1)==0))/size(cHS1,1)*100];
    acc2 = [acc2; length(find((cHS2-cMS2)==0))/size(cHS2,1)*100];
    acc3 = [acc3; length(find((cHS3-cMS3)==0))/size(cHS3,1)*100];
end

mean_corr_spk_set1 = mean(corr_spk_ary_set1);
mean_corr_spk_set2 = mean(corr_spk_ary_set2);
mean_corr_spk_set3 = mean(corr_spk_ary_set3);

mean_corr_task_set1 = mean(corr_task_ary_set1);
mean_corr_task_set2 = mean(corr_task_ary_set2);
mean_corr_task_set3 = mean(corr_task_ary_set3);

meanAccOfSet1 = mean(acc1);
meanAccOfSet2 = mean(acc2);
meanAccOfSet3 = mean(acc3);

meanErrOfSet1 = mean(err1);
meanErrOfSet2 = mean(err2);
meanErrOfSet3 = mean(err3);

fprintf('>> correlation of each set between raters and SVR scores(normalizing data type)\n');
fprintf('Number of used task : %d\n',usedTask);
fprintf('\tSet1\tSet2\tSet3\t| Mean\n');
fprintf('Spk :\t%0.2f',mean_corr_spk_set1);
fprintf('\t%0.2f',mean_corr_spk_set2);
fprintf('\t%0.2f',mean_corr_spk_set3);
fprintf('\t| %0.2f\n',mean([mean_corr_spk_set1 mean_corr_spk_set2 mean_corr_spk_set3]));
fprintf('Task :\t%0.2f',mean_corr_task_set1);
fprintf('\t%0.2f',mean_corr_task_set2);
fprintf('\t%0.2f',mean_corr_task_set3);
fprintf('\t| %0.2f\n',mean([mean_corr_task_set1 mean_corr_task_set2 mean_corr_task_set3]));

fprintf('>> classification accuracy of each set between raters and SVR scores(normalizing data type)\n');
fprintf('Number of used task : %d\t\tNumber of class : %d\n',usedTask,100/para.levelScale);
fprintf('\tSet1\tSet2\tSet3\t| Mean\n');
fprintf('Acc. :\t%0.2f',meanAccOfSet1);
fprintf('\t%0.2f',meanAccOfSet2);
fprintf('\t%0.2f',meanAccOfSet3);
fprintf('\t| %0.2f\n',mean([meanAccOfSet1 meanAccOfSet2 meanAccOfSet3]));

fprintf('>> error score of each set between raters and SVR scores(normalizing data type)\n');
fprintf('Number of used task : %d\t\tNumber of class : %d\n',usedTask,100/para.levelScale);
fprintf('\t\tSet1\tSet2\tSet3\t| Mean\n');
fprintf('Err. :\t%0.2f',meanErrOfSet1);
fprintf('\t%0.2f',meanErrOfSet2);
fprintf('\t%0.2f',meanErrOfSet3);
fprintf('\t| %0.2f\n',mean([meanErrOfSet1 meanErrOfSet2 meanErrOfSet3]));



