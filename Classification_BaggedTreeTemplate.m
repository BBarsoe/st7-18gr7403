%% Classification
%% Change Datetime to hour in the feature table
Date_time = hms(heartData.timestamp(1:end-302));
featuresData.hour = Date_time;
%% Save data in X and Y
X = table2array(featuresData(:,1:63));
Y = featuresData.headache;
%% 70/30 split random in Training og Test
cv = cvpartition(Y,'holdout',0.3);
Xtrain = X(training(cv),:);
Ytrain = Y(training(cv));
Xtest = X(test(cv),:);
Ytest = Y(test(cv));
%% Make treeTemplate of type BaggedTree
t = templateTree('Surrogate','on')
%% Train the model
mdl3 = fitcensemble(Xtrain,Ytrain,'Method','Bag','Learners',t)
%% Test the model on test data
y_pred3 = predict(mdl3,Xtest);
confmat3 = confusionmat(Ytest,y_pred3);
disp('Confusion Matrix - with surrogates')

%% TreeBagger - Importance
Mdl = TreeBagger(50,X,y,'Method','classification',...
    'PredictorSelection','curvature','OOBPredictorImportance','on');
%% Feature importance
imp = Mdl.OOBPermutedPredictorDeltaError;
figure;
bar(imp);
xlabel('Features');
ylabel('Feature importance estimates');
h = gca;
h.XTickLabel = Mdl.PredictorNames;
h.XTickLabelRotation = 45;
disp(confmat3)