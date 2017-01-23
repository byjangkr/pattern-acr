function [outSpk, outMS, outHS] = run_svm_all(fluency_data,task_id,gNum,fid)
% calculate performance by svm
% data type : normalizing, cross validation
% input
% fluency_data : fluency data
% gNum : number of group 
% output
% outMS : Machine score using SVR 
%   - row : number of speaker in a group x number of used task that 1-5
%   - column : number of group
% outHS : Humman score of the corresponding MS
%addpath('./step3_svm/func');

allDV = [];
allTest = [];
allSpk = [];


speaker_id = 1:max(fluency_data(:,1));
[B,I]=sort(rand(length(speaker_id),1)); % suffle
speaker_id = reshape(speaker_id(I),length(speaker_id)/gNum,gNum);

for gNum_test=1:gNum % cross validation
    train_id = speaker_id(:,1:end~=gNum_test);
    train_id = reshape(train_id,size(train_id,1)*size(train_id,2),1); % speaker index for train
    test_id = speaker_id(:,gNum_test); % speaker index for test
    
    or_trainX = []; trainD = []; or_testX = []; testD = [];
    for i= task_id % using task number
       tempX = fluency_data((fluency_data(:,3)==i),fid+4);
       tempD = fluency_data((fluency_data(:,3)==i),4);
       or_trainX = [or_trainX; tempX(train_id,:)]; 
       trainD = [trainD; tempD(train_id,:)];
       or_testX = [or_testX; tempX(test_id,:)];
       testD = [testD; tempD(test_id,:)];
    end
    
    [no_trainX, train_mean, train_std] = transMat(or_trainX,2); % normalizing data
    no_testX = transMat(or_testX,2,train_mean,train_std); % normalizing data

    % svm train, test
% Usage: svm-train [options] training_set_file [model_file]
% options:
% -s svm_type : set type of SVM (default 0)
% 	0 -- C-SVC		(multi-class classification)
% 	1 -- nu-SVC		(multi-class classification)
% 	2 -- one-class SVM	
% 	3 -- epsilon-SVR	(regression)
% 	4 -- nu-SVR		(regression)
% -t kernel_type : set type of kernel function (default 2)
% 	0 -- linear: u'*v
% 	1 -- polynomial: (gamma*u'*v + coef0)^degree
% 	2 -- radial basis function: exp(-gamma*|u-v|^2)
% 	3 -- sigmoid: tanh(gamma*u'*v + coef0)
% 	4 -- precomputed kernel (kernel values in training_set_file)
% -d degree : set degree in kernel function (default 3)
% -g gamma : set gamma in kernel function (default 1/num_features)
% -r coef0 : set coef0 in kernel function (default 0)
% -c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
% -n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
% -p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)
% -m cachesize : set cache memory size in MB (default 100)
% -e epsilon : set tolerance of termination criterion (default 0.001)
% -h shrinking : whether to use the shrinking heuristics, 0 or 1 (default 1)
% -b probability_estimates : whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
% -wi weight : set the parameter C of class i to weight*C, for C-SVC (default 1)
% -v n: n-fold cross validation mode
% -q : quiet mode (no outputs)

%     model = svmtrain(trainD,no_trainX,'-s 3 -t 2 -p 0.001 -c 500 -g 0.0083 -q ');
    model = svmtrain(trainD,no_trainX,'-s 3 -t 0 -p 0.1 -c 10 -q ');
    [pl,acc,dv] = svmpredict(testD,no_testX,model,'-q');


    
    allDV = [allDV dv]; % decision value
    allTest = [allTest testD];
    allSpk = [allSpk test_id];
end

outMS = allDV;
outHS = allTest;
outSpk = allSpk;

end









