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
mdl = fitcensemble(Xtrain,Ytrain,'Method','Bag','Learners',t)
%% Test the model on test data
y_pred3 = predict(mdl,Xtest);
confmat3 = confusionmat(Ytest,y_pred3)
disp('Confusion Matrix - with surrogates')
disp(confmat3)
%% PCA on classifier model
coeff = pca(mdl.X); %coeff = eigenvalues
[varians, feature_idx] = sort(coeff, 'descend');
selected_pcaData = featuresData(:,feature_idx(1:20)); %Select twenty features with the highest varians.
%% biplot of PCA
figure(3)
mapcaplot(coeff)
%biplot(coeff)
%% Predictor Importance
imp = predictorImportance(mdl);
figure(2)
bar(imp);
grid on;
xlabel('Predictor (features)');
ylabel('Predictor importance estimates');
h =  gca;
h.XTick = [1:2:62 63];
h.XTickLabel = featuresData.Properties.VariableNames;
h.XTickLabelRotation = 45;
z=1;
for i=1:length(imp)
    if imp(i) > 0.7*10^-5
        selected_predictorData(z) = featuresData(:,1); %Fejl her
        z = z+1;
    end
end
%Select the featuresData with importence higher than 0.7
