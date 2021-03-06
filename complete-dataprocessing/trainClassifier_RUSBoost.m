function [trainedClassifier, validationAccuracy] = trainClassifier_RUSBoost(trainingData)
% [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
% returns a trained classifier and its accuracy. This code recreates the
% classification model trained in Classification Learner app. Use the
% generated code to automate training the same model with new data, or to
% learn how to programmatically train models.
%
%  Input:
%      trainingData: a table containing the same predictor and response
%       columns as imported into the app.
%
%  Output:
%      trainedClassifier: a struct containing the trained classifier. The
%       struct contains various fields with information about the trained
%       classifier.
%
%      trainedClassifier.predictFcn: a function to make predictions on new
%       data.
%
%      validationAccuracy: a double containing the accuracy in percent. In
%       the app, the History list displays this overall accuracy score for
%       each model.
%
% Use the code to train the model with new data. To retrain your
% classifier, call the function from the command line with your original
% data or new data as the input argument trainingData.
%
% For example, to retrain a classifier trained with the original data set
% T, enter:
%   [trainedClassifier, validationAccuracy] = trainClassifier(T)
%
% To make predictions with the returned 'trainedClassifier' on new data T2,
% use
%   yfit = trainedClassifier.predictFcn(T2)
%
% T2 must be a table containing at least the same predictor columns as used
% during training. For details, enter:
%   trainedClassifier.HowToPredict

% Auto-generated by MATLAB on 05-Dec-2018 11:21:20


% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'hour', 'heart', 'heart_diff', 'heart_diff_movmax', 'heart_diff_movmean', 'heart_diff_movmin', 'heart_movmedian_1h', 'heart_movmean_1h', 'heart_movmin_1h', 'heart_movmax_1h', 'heart_movstd_1h', 'delay_heart_5m', 'delay_heart_15m', 'delay_heart_1h', 'delay_heart_5h', 'steps', 'steps_diff', 'steps_movmean', 'steps_movmedian', 'steps_movmin', 'steps_movmax', 'steps_movstd', 'delay_steps_5m', 'delay_steps_15m', 'delay_steps_1h', 'delay_steps_5h', 'sleeptime', 'sleepaverage', 'delay_heart_diff_5m', 'delay_heart_diff_15m', 'delay_heart_diff_1h', 'delay_heart_diff_5h', 'delay_steps_diff_5m', 'delay_steps_diff_15m', 'delay_steps_diff_1h', 'delay_steps_diff_5h', 'heart_movmedian_15m', 'heart_movmean_15m', 'heart_movmin_15m', 'heart_movmax_15m', 'heart_movstd_15m', 'steps_movmean_15m', 'steps_movmedian_15m', 'steps_movmin_15m', 'steps_movmax_15m', 'steps_movstd_15m', 'heart_movstd_1m_delay_5m', 'heart_movstd_5m_delay_15m', 'heart_movstd_15m_delay_1h', 'heart_movstd_2h_delay_5h', 'heart_movmean_1m_delay_5m', 'heart_movmean_5m_delay_15m', 'heart_movmean_15m_delay_1h', 'heart_movmean_2h_delay_5h', 'step_movstd_1m_delay_5m', 'step_movstd_5m_delay_15m', 'step_movstd_15m_delay_1h', 'step_movstd_2h_delay_5h', 'step_movmean_1m_delay_5m', 'step_movmean_5m_delay_15m', 'step_movmean_15m_delay_1h', 'step_movmean_2h_delay_5h', 'fluidmodel'};
predictors = inputTable(:, predictorNames);
response = inputTable.headache;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

% Apply a PCA to the predictor matrix.
% Run PCA on numeric predictors only. Categorical predictors are passed through PCA untouched.
isCategoricalPredictorBeforePCA = isCategoricalPredictor;
numericPredictors = predictors(:, ~isCategoricalPredictor);
numericPredictors = table2array(varfun(@double, numericPredictors));
% 'inf' values have to be treated as missing data for PCA.
numericPredictors(isinf(numericPredictors)) = NaN;
numComponentsToKeep = min(size(numericPredictors,2), 5);
[pcaCoefficients, pcaScores, ~, ~, explained, pcaCenters] = pca(...
    numericPredictors, ...
    'NumComponents', numComponentsToKeep);
predictors = [array2table(pcaScores(:,:)), predictors(:, isCategoricalPredictor)];
isCategoricalPredictor = [false(1,numComponentsToKeep), true(1,sum(isCategoricalPredictor))];

% Train a classifier
% This code specifies all the classifier options and trains the classifier.
template = templateTree(...
    'MaxNumSplits', 20);
classificationEnsemble = fitcensemble(...
    predictors, ...
    response, ...
    'Method', 'RUSBoost', ...
    'NumLearningCycles', 30, ...
    'Learners', template, ...
    'LearnRate', 0.1, ...
    'ClassNames', [0; 1]);

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
pcaTransformationFcn = @(x) [ array2table((table2array(varfun(@double, x(:, ~isCategoricalPredictorBeforePCA))) - pcaCenters) * pcaCoefficients), x(:,isCategoricalPredictorBeforePCA) ];
ensemblePredictFcn = @(x) predict(classificationEnsemble, x);
trainedClassifier.predictFcn = @(x) ensemblePredictFcn(pcaTransformationFcn(predictorExtractionFcn(x)));

% Add additional fields to the result struct
trainedClassifier.RequiredVariables = {'hour', 'heart', 'heart_diff', 'heart_diff_movmax', 'heart_diff_movmean', 'heart_diff_movmin', 'heart_movmedian_1h', 'heart_movmean_1h', 'heart_movmin_1h', 'heart_movmax_1h', 'heart_movstd_1h', 'delay_heart_5m', 'delay_heart_15m', 'delay_heart_1h', 'delay_heart_5h', 'steps', 'steps_diff', 'steps_movmean', 'steps_movmedian', 'steps_movmin', 'steps_movmax', 'steps_movstd', 'delay_steps_5m', 'delay_steps_15m', 'delay_steps_1h', 'delay_steps_5h', 'sleeptime', 'sleepaverage', 'delay_heart_diff_5m', 'delay_heart_diff_15m', 'delay_heart_diff_1h', 'delay_heart_diff_5h', 'delay_steps_diff_5m', 'delay_steps_diff_15m', 'delay_steps_diff_1h', 'delay_steps_diff_5h', 'heart_movmedian_15m', 'heart_movmean_15m', 'heart_movmin_15m', 'heart_movmax_15m', 'heart_movstd_15m', 'steps_movmean_15m', 'steps_movmedian_15m', 'steps_movmin_15m', 'steps_movmax_15m', 'steps_movstd_15m', 'heart_movstd_1m_delay_5m', 'heart_movstd_5m_delay_15m', 'heart_movstd_15m_delay_1h', 'heart_movstd_2h_delay_5h', 'heart_movmean_1m_delay_5m', 'heart_movmean_5m_delay_15m', 'heart_movmean_15m_delay_1h', 'heart_movmean_2h_delay_5h', 'step_movstd_1m_delay_5m', 'step_movstd_5m_delay_15m', 'step_movstd_15m_delay_1h', 'step_movstd_2h_delay_5h', 'step_movmean_1m_delay_5m', 'step_movmean_5m_delay_15m', 'step_movmean_15m_delay_1h', 'step_movmean_2h_delay_5h', 'fluidmodel'};
trainedClassifier.PCACenters = pcaCenters;
trainedClassifier.PCACoefficients = pcaCoefficients;
trainedClassifier.ClassificationEnsemble = classificationEnsemble;
trainedClassifier.About = 'This struct is a trained model exported from Classification Learner R2018b.';
trainedClassifier.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = trainingData;
predictorNames = {'hour', 'heart', 'heart_diff', 'heart_diff_movmax', 'heart_diff_movmean', 'heart_diff_movmin', 'heart_movmedian_1h', 'heart_movmean_1h', 'heart_movmin_1h', 'heart_movmax_1h', 'heart_movstd_1h', 'delay_heart_5m', 'delay_heart_15m', 'delay_heart_1h', 'delay_heart_5h', 'steps', 'steps_diff', 'steps_movmean', 'steps_movmedian', 'steps_movmin', 'steps_movmax', 'steps_movstd', 'delay_steps_5m', 'delay_steps_15m', 'delay_steps_1h', 'delay_steps_5h', 'sleeptime', 'sleepaverage', 'delay_heart_diff_5m', 'delay_heart_diff_15m', 'delay_heart_diff_1h', 'delay_heart_diff_5h', 'delay_steps_diff_5m', 'delay_steps_diff_15m', 'delay_steps_diff_1h', 'delay_steps_diff_5h', 'heart_movmedian_15m', 'heart_movmean_15m', 'heart_movmin_15m', 'heart_movmax_15m', 'heart_movstd_15m', 'steps_movmean_15m', 'steps_movmedian_15m', 'steps_movmin_15m', 'steps_movmax_15m', 'steps_movstd_15m', 'heart_movstd_1m_delay_5m', 'heart_movstd_5m_delay_15m', 'heart_movstd_15m_delay_1h', 'heart_movstd_2h_delay_5h', 'heart_movmean_1m_delay_5m', 'heart_movmean_5m_delay_15m', 'heart_movmean_15m_delay_1h', 'heart_movmean_2h_delay_5h', 'step_movstd_1m_delay_5m', 'step_movstd_5m_delay_15m', 'step_movstd_15m_delay_1h', 'step_movstd_2h_delay_5h', 'step_movmean_1m_delay_5m', 'step_movmean_5m_delay_15m', 'step_movmean_15m_delay_1h', 'step_movmean_2h_delay_5h', 'fluidmodel'};
predictors = inputTable(:, predictorNames);
response = inputTable.headache;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

% Perform cross-validation
KFolds = 5;
cvp = cvpartition(response, 'KFold', KFolds);
% Initialize the predictions to the proper sizes
validationPredictions = response;
numObservations = size(predictors, 1);
numClasses = 2;
validationScores = NaN(numObservations, numClasses);
for fold = 1:KFolds
    trainingPredictors = predictors(cvp.training(fold), :);
    trainingResponse = response(cvp.training(fold), :);
    foldIsCategoricalPredictor = isCategoricalPredictor;
    
    % Apply a PCA to the predictor matrix.
    % Run PCA on numeric predictors only. Categorical predictors are passed through PCA untouched.
    isCategoricalPredictorBeforePCA = foldIsCategoricalPredictor;
    numericPredictors = trainingPredictors(:, ~foldIsCategoricalPredictor);
    numericPredictors = table2array(varfun(@double, numericPredictors));
    % 'inf' values have to be treated as missing data for PCA.
    numericPredictors(isinf(numericPredictors)) = NaN;
    numComponentsToKeep = min(size(numericPredictors,2), 15);
    [pcaCoefficients, pcaScores, ~, ~, explained, pcaCenters] = pca(...
        numericPredictors, ...
        'NumComponents', numComponentsToKeep);
    trainingPredictors = [array2table(pcaScores(:,:)), trainingPredictors(:, foldIsCategoricalPredictor)];
    foldIsCategoricalPredictor = [false(1,numComponentsToKeep), true(1,sum(foldIsCategoricalPredictor))];
    
    % Train a classifier
    % This code specifies all the classifier options and trains the classifier.
    template = templateTree(...
        'MaxNumSplits', 20);
    classificationEnsemble = fitcensemble(...
        trainingPredictors, ...
        trainingResponse, ...
        'Method', 'RUSBoost', ...
        'NumLearningCycles', 30, ...
        'Learners', template, ...
        'LearnRate', 0.1, ...
        'ClassNames', [0; 1]);
    
    % Create the result struct with predict function
    pcaTransformationFcn = @(x) [ array2table((table2array(varfun(@double, x(:, ~isCategoricalPredictorBeforePCA))) - pcaCenters) * pcaCoefficients), x(:,isCategoricalPredictorBeforePCA) ];
    ensemblePredictFcn = @(x) predict(classificationEnsemble, x);
    validationPredictFcn = @(x) ensemblePredictFcn(pcaTransformationFcn(x));
    
    % Add additional fields to the result struct
    
    % Compute validation predictions
    validationPredictors = predictors(cvp.test(fold), :);
    [foldPredictions, foldScores] = validationPredictFcn(validationPredictors);
    
    % Store predictions in the original order
    validationPredictions(cvp.test(fold), :) = foldPredictions;
    validationScores(cvp.test(fold), :) = foldScores;
end

% Compute validation accuracy
correctPredictions = (validationPredictions == response);
isMissing = isnan(response);
correctPredictions = correctPredictions(~isMissing);
validationAccuracy = sum(correctPredictions)/length(correctPredictions);
