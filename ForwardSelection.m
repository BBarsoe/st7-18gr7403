%% Seguential feature selection
X = testSamples;
Y = testLabelVec;

c = cvpartition(Y,'k',5);
opts = statset('display','iter');

[fs,history] = sequentialfs(@critfunc,X,Y,...
    'cv',c,...
    'nullmodel',true,...
    'options',opts,...
    'direction','forward');
%%
model = fitglm(X(:,fs),Y,'Distribution','binomial')
%% Function
function dev = critfunc(X,Y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
model = fitglm(X,Y,'Distribution', 'binomial');
dev = model.Deviance;
end

