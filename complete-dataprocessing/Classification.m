%% Hour from datetime to hour
Training.hour = hour(Training.hour);
ValidationSet.hour = hour(ValidationSet.hour);
Test_set.hour = hour(Test_set.hour);
%% Creating trainingset and validationset
train_predictors = Training(:,1:63);
train_response = Training.headache;

validation_prefictors = ValidationSet(:,1:63);
validation_response = ValidationSet.headache;
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

%% PCA on RUSBoost
RUSBoost_pca = table2array(RUSBoost_model.X(:,1:63));
coeff = pca(RUSBoost_pca); %coeff = eigenvalues
[varians, feature_idx] = sort(coeff, 'descend');
selected_pca_RUSBoost = featuresData(:,feature_idx(1:20)); %Select twenty features with the highest varians.

%% PCA on Random Forest
RandomForest_pca = table2array(RandomForest_model.X(:,1:63));
coeff = pca(RandomForest_pca); %coeff = eigenvalues
[varians, feature_idx] = sort(coeff, 'descend');
selected_pca_RandomForest = featuresData(:,feature_idx(1:20)); %Select twenty features with the highest varians.

%% Predictor Importance on RUSBoost
imp_RUSBoost = predictorImportance(RUSBoost_model);
figure(1)
bar(imp_RUSBoost);
grid on;
title('RUSBoost');
xlabel('Predictors');
ylabel('Predictor importance estimates');
h =  gca;
h.XTick = 0:1:63;
h.XTickLabel = featuresData.Properties.VariableNames; %Denne skal rettes til, hvis plottet laves for et udvalgt antal features.
h.XTickLabelRotation = 45;

%% Predictor Importance on RandomForest
imp_RandomForest = predictorImportance(RandomForest_model);
figure(2)
bar(imp_RandomForest);
grid on;
title('RandomForest');
xlabel('Predictors');
ylabel('Predictor importance estimates');
h =  gca;
h.XTick = 0:1:63;
h.XTickLabel = featuresData.Properties.VariableNames; %Denne skal rettes til, hvis plottet laves for et udvalgt antal features.
h.XTickLabelRotation = 45;

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
figure(2)
boxplot(L,'Labels',{'RUSBoost' 'RandomForeset'})
title('Algorithm Comparison')


%% Predict on vaildation set
label_RandomForest = predict(RandomForest_model,ValidationSet(:,1:63));
label_RUSBoost = predict(RUSBoost_model,ValidationSet(:,1:63));

figure(3)
plotconfusion(label_RandomForest',ValidationSet.headache','Confusionmatrix using RandomForest Model');

figure(4)
plotconfusion(label_RUSBoost',ValidationSet.headache','Confusionmatirx using RUSBoost Model')

figure(5)
subplot(2,1,1)
cm_forset = confusionchart(ValidationSet.headache',label_RandomForest');
cm_forset.Title = 'Confusionmatrix using RandomForest Model';
cm_forset.RowSummary = 'row-normalized';
cm_forset.ColumnSummary = 'column-normalized';
subplot(2,1,2)
cm_RUSBoost = confusionchart(ValidationSet.headache',label_RUSBoost');
cm_RUSBoost.Title = 'Confusionmatrix using RUSBoost Model';
cm_RUSBoost.RowSummary = 'row-normalized';
cm_RUSBoost.ColumnSummary = 'column-normalized';
