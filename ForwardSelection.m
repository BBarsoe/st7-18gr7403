%% Seguential feature selevtion
X = testSamples;
Y = testLabelVec;

sbs = sequentialfs(@critfunc,X,Y,...
    'cv','none',...
    'nullmodel',true,...
    'options',opt,...
    'direction','backward');
%%
model = fitglm(X(:,sbs),Y,'Distribution','binomial')
%% Function
function dev = critfunc(X,Y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
model = fitglm(X,Y,'Distribution', 'binomial');
dev = model.Deviance;
end

