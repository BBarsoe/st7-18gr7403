%% TreeBagger - Bagged Tree - Confusion Matrix
%% Load data
X = trainSamples(:,1:62);
y = trainLabelVec;
%Z = Data_table(:,1:62);
%W = Data_table(:,63);
%% TreeBagger
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
%% 70/30 split random in Training og Test
cv = cvpartition(y,'holdout',0.3);
Xtrain = X(training(cv),:);
Ytrain = y(training(cv));
Xtest = X(test(cv),:);
Ytest = y(test(cv));
%% Train model
mdl1 = ClassificationTree.template('NVarToSample','all');
RF1 = fitensemble(Xtrain,Ytrain,'Bag',50,mdl1, 'type','classification');
%% Train model with surrogate
mdl2 = ClassificationTree.template('NVarToSample','all','surrogate','on');
RF2 = fitensemble(Xtrain,Ytrain,'Bag',50,mdl2,'type','classification');
%% Confusion matrix in Command Window
y_pred1 = predict(RF1,Xtest);
confmat1 = confusionmat(Ytest,y_pred1);
disp('Confusion Matrix - without surrogates')
disp(confmat1)

y_pred2 = predict(RF2,Xtest);
confmat2 = confusionmat(Ytest,y_pred2);
disp('Confusion Matrix - with surrogates')
disp(confmat2)

%% The new way to make treeTemplate
%t = templateTree('Surrogate','on')
mdl3 = fitcensemble(Xtrain,Ytrain,'Method','Bag','Learners',t)

%%
y_pred3 = predict(mdl3,Xtest);
confmat3 = confusionmat(Ytest,y_pred3);
disp('Confusion Matrix - with surrogates')
disp(confmat3)
