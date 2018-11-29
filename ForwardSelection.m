%% Seguential feature selection
%X = testSamples;
%Y = testLabelVec;

n = 100;
m = 10;
X = rand(n,m);
b = [1 0 0 2 .5 0 0 0.1 0 1];
Xb = X*b';
p = 1./(1+exp(-Xb));
N = 50;
y = binornd(N,p);
Y = [y N*ones(size(y))];

%%
%c = cvpartition(Y,'k',5);
maxdev = chi2inv(.95,1);
opt = statset('display','iter',...
                'Tolfun',maxdev,...
                'TolTypeFun','abs');

[fs,history] = sequentialfs(@critfunc,X,Y,...
    'cv','none',...
    'nullmodel',true,...
    'options',opt,...
    'direction','forward');
%%
%model = fitglm(X(:,fs),Y,'Distribution','binomial')
%% Function
function dev = critfunc(X,Y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[b,dev] = glmfit(X,Y, 'binomial');
end

