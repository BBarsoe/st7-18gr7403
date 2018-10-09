clear; close all; clc;
%% Steps
% Import data
rawStep = importSteps('Jacob_Steps.xlsx');

%% Convert to datetime
rawStep(1,:) = [];
stepData = table('Size',[height(rawStep) 2],'VariableTypes',["datetime","double"],'VariableNames',["Time","Steps"]);
for i = 1:height(rawStep)
   stepData{i,1} = datetime(rawStep{i,1},'InputFormat','yyyy-MM-dd HH:mm:ss');
   stepData{i,2} = rawStep{i,2};
end

%% Plot steps per time
figure(1)
plot(stepData{:,1},stepData{:,2});
grid on

%% Features
step = stepData{:,2};
step_diff = diff(step);
step_diff_movmean = movmean(step_diff,60);
step_diff_movmax = movmax(step_diff,60);
step_diff_movmin = movmin(step_diff,60);
step_median = movmedian(step,60);
step_movmean = movmean(step,60);
step_movmax = movmax(step,60);
step_movmin = movmin(step,60); %Denne vil altid være nul

Step_Data_table = table(step(1:end-1),step_diff, step_diff_movmean, step_diff_movmax, step_diff_movmin, step_median(1:end-1), step_movmean(1:end-1), step_movmax(1:end-1), step_movmin(1:end-1));
Step_Data_table.Properties.VariableNames{1} = 'step';
Step_Data_table.Properties.VariableNames{6} = 'step_median';
Step_Data_table.Properties.VariableNames{7} = 'step_movmean';
Step_Data_table.Properties.VariableNames{8} = 'step_movmax';
Step_Data_table.Properties.VariableNames{9} = 'step_movmin';