train_predictors = Training(:,2:63);
train_response = Training.headache;

test_prefictors = Testing(:,2:63);
test_response = Testing.headache;
%% Classification

% RUSBoost
template_RUSBoost = templateTree(...
    'MaxNumSplits', 20);
RUSBoost_model = fitcensemble(train_predictors,train_response,...
    'Method','RUSBoost',...
    'NumLearningCycles', 30,'Learners',...
    template_RUSBoost,...
    'LearnRate', 0.1, ...
    'ClassNames', [0; 1]);

% Random forest
template_forest = templateTree(...
    'MaxNumSplits', 56839);
RandomForest_model = fitcensemble(...
    train_predictors, ...
    train_response, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 30, ...
    'Learners', template_forest, ...
    'ClassNames', [0; 1]);


%% Perform cross-validation
partitionedModel_RUSBoost = crossval(RUSBoost_model, 'KFold', 5);
partitionedModel_forest = crossval(RandomForest_model, 'KFold', 5);

%% Compute validation predictions
[validationPredictions_RUSBoost, validationScores_RUSBoost] = kfoldPredict(partitionedModel_RUSBoost);
cp_RUSBoost = classperf(Training.headache);
classperf(cp_RUSBoost,validationPredictions_RUSBoost);
sen_spe_RUSBoost = [cp_RUSBoost.Sensitivity,cp_RUSBoost.Specificity]
[validationPredictions_forest, validationScores_forest] = kfoldPredict(partitionedModel_forest);
cp_forest = classperf(Training.headache);
classperf(cp_forest,validationPredictions_forest);
sen_spe_forest = [cp_forest.Sensitivity,cp_forest.Specificity]
%% Compute validation accuracy
validationAccuracy(1,1) = 1 - kfoldLoss(partitionedModel_RUSBoost, 'LossFun', 'ClassifError');
validationAccuracy(1,2) = 1 - kfoldLoss(partitionedModel_forest, 'LossFun', 'ClassifError')
 L(:,1) = (1-kfoldLoss(partitionedModel_RUSBoost,'mode','individual'));
 L(:,2) = (1-kfoldLoss(partitionedModel_forest,'mode','individual'));
 
 
%% Compareing classifications accuracy
close
figure;
boxplot(L,'Labels',{'RUSBoost' 'RandomForeset'})
title('Algorithm Comparison')


%% Predict on test set

