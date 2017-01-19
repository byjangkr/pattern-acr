function [outSpk, outMS, outHS] = run_dt(fluency_data,task_id,gNum,fid)

allDV = [];
allTest = [];
allSpk = [];
allW = [];
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
   
    tree = RegressionTree.fit(no_trainX,trainD);
    [dv, node] = predict(tree,no_testX);
     tree
    allDV = [allDV dv]; % decision value
    allTest = [allTest testD];
    allSpk = [allSpk test_id];

end

outMS = allDV;
outHS = allTest;
outSpk = allSpk;



end


