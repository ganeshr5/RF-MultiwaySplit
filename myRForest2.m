
function myRForest2(filename,Mset)

B=100; % Decision Trees
% import dataset
allData = importdata(filename); % Import Mushroom Data
allData = allData(randperm(size(allData,1)),:); % random permutation

Yall = allData(:,1); % Class labels
nRecords = length(Yall); % lentgh of class label vector

Xall = allData(:,2:end); % features
nFeatures = size(Xall,2); % no of features

classLabels=unique(Yall); % Total no of class labels

nCV=10;

setSize= floor(nRecords/nCV);

MtrainErrors = zeros(length(Mset),1);
MtestErrors =  zeros(length(Mset),1);

Mi=1;

for M = Mset
fprintf('Value of M = %d \n',M);
PtrainError = zeros(nCV,1);
PtestError = zeros(nCV,1);

for i=1:nCV
    %Train Set
    X1 = Xall(1: (i-1)*setSize , :);
    X2 = Xall((i*setSize) + 1: nCV*setSize, :);
    Y1 = Yall(1: (i-1)*setSize , :);
    Y2 = Yall((i*setSize) + 1: nCV*setSize, :);
    Xtrain = [X1;X2];
    Ytrain = [Y1;Y2];
    
    %Test Set
    Xtest = Xall(((i-1)*setSize + 1):(i*setSize) , :);
    Ytest = Yall(((i-1)*setSize + 1):(i*setSize) , :);
    nTrain= size(Xtrain,1);
    Weights = ones(nTrain,1);
    
    clfr_alpha= zeros(B,1);
    clfr_root = cell(B,1);
    clfr_trainIndices = cell(B,1);
    
    for classifier_no=1:B
        
        % Boot Strapping 
        chosenSample = randsample(nTrain,nTrain,true);
        XtrainLocal = Xtrain(chosenSample,:);
        YtrainLocal = Ytrain(chosenSample);
        selFeature = randsample(nFeatures,M);
        % claculate Information Gain
        InfoGains = Info(YtrainLocal) - InfoRem(XtrainLocal(:,selFeature), YtrainLocal);
        
        % Select from specified features
        [maxgain,feature_no] = max(InfoGains);
        feature_no = selFeature(feature_no);
        
        %Split with feature number
        splitting_feature = XtrainLocal(:,feature_no);
        allVals = unique(splitting_feature);
        % claculate cardinality
        cardinality = length(allVals);      
        %MAX
        branch_op = zeros(cardinality,1);
        
        % 1st Layer nodes
        root = node(0,feature_no,allVals);
        
        % 2nd layer nodes
        for v  = 1:cardinality
            branchedDataIndices = find(splitting_feature==allVals(v));
            
            % if Gini Gain is 0
            if std(YtrainLocal(branchedDataIndices)) == 0
                % Make output node
                root.addLeafChild(allVals(v), mode(YtrainLocal(branchedDataIndices)));
            else
                % 2nd Layer Data
                Xtrain2=XtrainLocal(branchedDataIndices,:);
                Ytrain2=YtrainLocal(branchedDataIndices);
                
                selFeature = randsample(nFeatures,M);
                % Calculate Information Gain
                InfoGains2 = Info(Ytrain2) - InfoRem(Xtrain2(:,selFeature), Ytrain2);
                
                [maxgain,feature_no2] = max(InfoGains2);
                feature_no2 = selFeature(feature_no2);
                
                % Split on another feature no
                splitting_feature2 = Xtrain2(:,feature_no2);
                allVals2 = unique(splitting_feature2);
                % claculate cardinality
                cardinality2 = length(allVals2);
                
                root.addChild(allVals(v), feature_no2, allVals2);
                for v2  = 1:cardinality2
                    branchedDataIndices2 = find(splitting_feature2==allVals2(v2));
                    root.childern{v}.addLeafChild(allVals2(v2), mode(Ytrain2(branchedDataIndices2)))
                end
            end      
        end 
        
        % Add less than node
        clfr_alpha(classifier_no) = 1/B;
        clfr_root{classifier_no} = root;
        clfr_trainIndices{classifier_no} = allVals;
    end
    
    % Predict
    Ytrain_predicted = zeros(size(Ytrain));
    for ii=1:size(Xtrain,1)
        op=0;
        for classifier_no=1:B
            cnode = clfr_root{classifier_no};
            while cnode.isLeafNode==0
                val = Xtrain(ii,cnode.feature_no);
                fvals= cnode.FeatureVals;
                [mindiff, valindex] = min(abs(fvals - val));
                val = fvals(valindex);
                cnode = cnode.getChild(val);
            end
            op = op + clfr_alpha(classifier_no)*(cnode.branchOutput);
        end
        [mindiff, labelindex] = min(abs(classLabels - op));
        Ytrain_predicted(ii) = classLabels(labelindex);
    end
    
    testError = sum(Ytrain~=Ytrain_predicted);
    PtrainError(i) = testError/length(Ytrain);
    Ytest_predicted = zeros(size(Ytest));
    
    for ii=1:size(Xtest,1)
        op=0;
        for classifier_no=1:B
            cnode = clfr_root{classifier_no};
            while cnode.isLeafNode==0
                val = Xtest(ii,cnode.feature_no);
                fvals= cnode.FeatureVals;
                [mindiff, valindex] = min(abs(fvals - val));
                val = fvals(valindex);
                cnode = cnode.getChild(val);
            end
            op = op + clfr_alpha(classifier_no)*(cnode.branchOutput);
        end
        [mindiff, labelindex] = min(abs(classLabels - op));
        Ytest_predicted(ii) = classLabels(labelindex);
    end
    
    testError = sum(Ytest~=Ytest_predicted);
    PtestError(i) = testError/length(Ytest);
    fprintf('Fold = %d, TrainError = %f, TestError = %f \n',i, PtrainError(i),PtestError(i));
end

MtrainErrors(Mi) = mean(PtrainError);
MtestErrors(Mi) =  mean(PtestError);
fprintf('Mean TrainError = %f, Mean TestError = %f \n',MtrainErrors(Mi),MtestErrors(Mi));
fprintf('Std Deviation TrainError = %f, Std Deviation TestError = %f, \n',std(PtrainError), std(PtestError));
Mi=Mi+1;
end

subplot(2,1,1);
plot(Mset,MtrainErrors);
title('Train Error Vs No. of selected features');
ylabel('TrainError');
xlabel('M');
subplot(2,1,2);
plot(Mset,MtestErrors);
title('Test Error Vs No. of selected features');
ylabel('TestError');
xlabel('M');
