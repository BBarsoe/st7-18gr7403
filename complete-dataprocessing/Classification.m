%% Hour from datetime to hour
Training.hour = hour(Training.hour);
ValidationSet.hour = hour(ValidationSet.hour);
Test_set.hour = hour(Test_set.hour);
%% Creating trainingset and validationset and testset
train_predictors = Training(:,1:63);
train_response = Training.headache;

validation_predictors = ValidationSet(:,1:63);
validation_response = ValidationSet.headache;

test_predictors = Test_set(:,1:63);
test_response = Test_set.headache;
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
 
%% Comparing classifications accuracy
close
figure(2)
boxplot(L,'Labels',{'RUSBoost' 'RandomForest'})
title('Algorithm Comparison')

%% PCA RUSBoost
RUSBoost_model_pca = trainClassifier_RUSBoost(Training);
RUSBoost_label_pca = RUSBoost_model_pca.predictFcn(validation_predictors);
figure(3)
plotconfusion(RUSBoost_label_pca',validation_response','Subject 3, RUSBoost Model, pca=5, validationset - ')

%% PCA RandomForest
RandomForest_model_pca = trainClassifier_RandomForest(Training);
RandomForest_label_pca = RandomForest_model_pca.predictFcn(validation_predictors);
figure(4)
plotconfusion(RandomForest_label_pca',validation_response','Subject 3, RandomForest Model, pca=5, validationset - ');

%% Confusionmatrix for both PCA and RandomForest
figure(5)
subplot(2,1,1)
cm_forset = confusionchart(validation_response,RandomForest_label_pca);
cm_forset.Title = 'Subject 3, Confusionmatrix using RandomForest Model, pca=5, validationset';
cm_forset.RowSummary = 'row-normalized';
cm_forset.ColumnSummary = 'column-normalized';
subplot(2,1,2)
cm_RUSBoost = confusionchart(validation_response,RUSBoost_label_pca);
cm_RUSBoost.Title = 'Subject 3, Confusionmatrix using RUSBoost Model, pca=5, validationset';
cm_RUSBoost.RowSummary = 'row-normalized';
cm_RUSBoost.ColumnSummary = 'column-normalized';

%% Predictor Importance on RUSBoost
imp_RUSBoost = predictorImportance(RUSBoost_model);
figure('Renderer', 'painters', 'Position', [10 10 600 300],'PaperSize',[15 8])
bar(imp_RUSBoost);
grid on;
title({'Predictor Importance using RUSBoost model on training data for subject 1',' '});
xlabel('Predictors');
ylabel('Predictor importance estimates');
h =  gca;
h.XTick = [1 5 10 15 20 25 30 35 40 45 50 55 60 63];
h.XMinorTick = 'on';
%h.XTickLabel = Training.Properties.VariableNames; %Denne skal rettes til, hvis plottet laves for et udvalgt antal features.
%h.XTickLabelRotation = 45;

%% Create table of important predictors
imp_RUSBoost_table = table(train_predictors.fluidmodel); %Ikke f�rdig
RUSBoost_model = fitcensemble(imp_RUSBoost_table,train_response,...
    'Method','RUSBoost',...
    'NumLearningCycles', 30,'Learners',...
    template_RUSBoost,...
    'LearnRate', 0.1, ...
    'ClassNames', [0; 1]);
%% Predictor Importance on RandomForest
imp_RandomForest = predictorImportance(RandomForest_model);
figure('Renderer', 'painters', 'Position', [10 10 600 300],'PaperSize',[16 8])
bar(imp_RandomForest);
grid on;
title('Predictor Importance using RandomForest model on training data for subject 1');
xlabel('Predictors');
ylabel('Predictor importance estimates');
h =  gca;
h.XTick = [1 5 10 15 20 25 30 35 40 45 50 55 60 63];
h.XMinorTick = 'on';
%h.XTickLabel = Training.Properties.VariableNames; %Denne skal rettes til, hvis plottet laves for et udvalgt antal features.
%h.XTickLabelRotation = 45;
%% Predictor Importance on RandomForest's and RUSBoost's two best predictors vs mean,std
imp_RandomForest = predictorImportance(RandomForest_model);
max_imp_RandomForest = imp_RandomForest;
RF_max1 = max(max_imp_RandomForest);
max_imp_RandomForest(max_imp_RandomForest==RF_max1) = [];
RF_max2 = max(max_imp_RandomForest);
max_imp_RandomForest(max_imp_RandomForest==RF_max2) = [];
RandomForest_mean = mean(max_imp_RandomForest);
RandomForest_std = std(max_imp_RandomForest);

imp_RUSBoost = predictorImportance(RUSBoost_model);
max_imp_RUSBoost = imp_RUSBoost;
RB_max1 = max(max_imp_RUSBoost);
max_imp_RUSBoost(max_imp_RUSBoost==RB_max1) = [];
RB_max2 = max(max_imp_RUSBoost);
max_imp_RUSBoost(max_imp_RUSBoost==RB_max2) = [];
RUSBoost_mean = mean(max_imp_RUSBoost);
RUSBoostt_std = std(max_imp_RUSBoost);
figure('Renderer', 'painters', 'Position', [10 10 300 300],'PaperSize',[8 8])
subplot(1,2,1)
hold on
bar(1:3,[RF_max1 RF_max2 RandomForest_mean])
errorbar(3,[RandomForest_mean],[RandomForest_std], '.');
grid on;
title({'RF for subject 2',' '});
xlabel('Predictors');
ylabel('Predictor importance estimates');
h =  gca;
h.XTick = [1 2 3];
h.XTickLabel = [{'Sleep','Fluid','Other'}];
h.XLim = [0.5 3.5];
h.YLim = [0 RF_max1+1/5*RF_max1];
h.XTickLabelRotation = 45;
subplot(1,2,2)
hold on
bar(1:3,[RB_max1 RB_max2 RUSBoost_mean])
errorbar(3,[RUSBoost_mean],[RUSBoostt_std], '.');
grid on;
title({'RB for subject 2',' '});
xlabel('Predictors');
ylabel('Predictor importance estimates');
h =  gca;
h.XTick = [1 2 3];
h.XTickLabel = [{'Sleep','Fluid','Other'}];
h.XLim = [0.5 3.5];
h.YLim = [0 RB_max1+1/5*RB_max1];
h.YAxis.Exponent = -3;
h.XTickLabelRotation = 45;
%h.XTickLabel = Training.Properties.VariableNames; %Denne skal rettes til, hvis plottet laves for et udvalgt antal features.
%h.XTickLabelRotation = 45;
%% Create table of important predictors
imp_RUSBoost_table = table(train_predictors.fluidmodel,train_predictors.sleepaverage,train_predictors.hour,train_predictors.heart_diff_movmin,train_predictors.heart_movstd_2h_delay_5h,train_predictors.heart_movmin_1h,train_predictors.heart_diff_movmax,train_predictors.heart_movmean_2h_delay_5h,train_predictors.steps_movmax,train_predictors.step_movmean_2h_delay_5h,train_predictors.step_movstd_2h_delay_5h,train_predictors.heart_movmax_1h,train_predictors.heart_movmedian_1h,train_predictors.heart_movmean_15m_delay_1h,train_predictors.heart_movstd_1h); 
RandomForest_model = fitcensemble(...
    imp_RUSBoost_table, ...
    train_response, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 30, ...
    'Learners', template_forest, ...
    'ClassNames', [0; 1]);
%% Predict on vaildation set
label_RandomForest = predict(RandomForest_model,ValidationSet(:,1:63));
label_RUSBoost = predict(RUSBoost_model,ValidationSet(:,1:63));

figure(3)
plotconfusion(label_RandomForest',ValidationSet.headache','Subject 3, Confusionmatrix using RandomForest Model');

figure(4)
plotconfusion(label_RUSBoost',validation_response','Subject 3, Confusionmatrix using RUSBoost Model')

figure(5)
subplot(2,1,1)
cm_forset = confusionchart(ValidationSet.headache,label_RandomForest);
cm_forset.Title = 'Subject 3, Confusionmatrix using RandomForest Model';
cm_forset.RowSummary = 'row-normalized';
cm_forset.ColumnSummary = 'column-normalized';
subplot(2,1,2)
cm_RUSBoost = confusionchart(ValidationSet.headache,label_RUSBoost);
cm_RUSBoost.Title = 'Subject 3, Confusionmatrix using RUSBoost Model';
cm_RUSBoost.RowSummary = 'row-normalized';
cm_RUSBoost.ColumnSummary = 'column-normalized';
