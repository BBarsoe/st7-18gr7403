clear
close all
clc 
%% Section anvendes kun til test - Classification
% Change Datetime to hour in the feature table
Date_time = hms(heartData.timestamp(1:end-302));
featuresData.hour = Date_time;
% Save data in X and Y
X = table2array(featuresData(:,1:63));
Y = featuresData.headache;
% 70/30 split random in Training og Test
cv = cvpartition(Y,'holdout',0.3);
Xtrain = X(training(cv),:);
Ytrain = Y(training(cv));
Xtest = X(test(cv),:);
Ytest = Y(test(cv));
%% Make treeTemplate
t = templateTree('Surrogate','on')
%% Train the model - Random Forest
mdl = fitcensemble(Xtrain,Ytrain,'Method','Bag','Learners',t)
%% Train the model - RusBoost
mdl = fitcensemble(Xtrain,Ytrain,'Method','RUSBoost','Learners',t)
%% Test the model on test data
y_pred = predict(mdl,Xtest);
confmat = confusionmat(Ytest,y_pred);
disp('Confusion Matrix - with surrogates')
disp(confmat)
%% PCA on classifier model
coeff = pca(mdl.X); %coeff = eigenvalues
[varians, feature_idx] = sort(coeff, 'descend');
selected_pcaData = featuresData(:,feature_idx(1:20)); %Select twenty features with the highest varians.
%% Predictor Importance
imp = predictorImportance(mdl);
figure(2)
bar(imp);
grid on;
xlabel('Predictor (features)');
ylabel('Predictor importance estimates');
h =  gca;
h.XTick = 0:1:62;
h.XTickLabel = featuresData.Properties.VariableNames; %Denne skal rettes til, hvis plottet laves for et udvalgt antal features.
h.XTickLabelRotation = 45;

% Nedenstående er et forsøg på at udvælge de features, vis importance
% højere end 0.7*10^-5. Fejler inde i IF-løkken.
% z=1;
% for i=1:length(imp)
%     if imp(i) > 0.7*10^-5
%         selected_predictorData(z) = featuresData(:,1); %Fejl her
%         z = z+1;
%     end
% end
