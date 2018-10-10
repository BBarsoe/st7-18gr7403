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
step_diff_movmean = movmean(step_diff,240);
step_diff_movmax = movmax(step_diff,60);
step_diff_movmin = movmin(step_diff,60);
step_median = movmedian(step,60);
step_movmean = movmean(step,240);
step_movmax = movmax(step,60);
step_movmin = movmin(step,60); %Denne vil altid være nul

Step_Data_table = table(step(1:end-1),step_diff, step_diff_movmean, step_diff_movmax, step_diff_movmin, step_median(1:end-1), step_movmean(1:end-1), step_movmax(1:end-1), step_movmin(1:end-1));
Step_Data_table.Properties.VariableNames{1} = 'step';
Step_Data_table.Properties.VariableNames{6} = 'step_median';
Step_Data_table.Properties.VariableNames{7} = 'step_movmean';
Step_Data_table.Properties.VariableNames{8} = 'step_movmax';
Step_Data_table.Properties.VariableNames{9} = 'step_movmin';

%% Number of steps per hour - Didn't sum correct
sumStepsHour = table('Size',[292 1],'VariableTypes',("double"),'VariableNames',("Number"));
y=1;
z=0;
for i=1:size(sumStepsHour)
   sumStepsHour{y,1} = sum(stepData{z+1:z+59,2});
   z = z+60;
   y = y+1;
end

%% Second and third differential
step_diffSecond = diff(step_diff);
step_diffThird = diff(step_diffSecond);

figure(3)
plot(stepData{1:end-3,1},step_diffThird,'r');
grid on; hold on; xlabel('Time'); ylabel('Steps');
plot(stepData{1:end-2,1},step_diffSecond,'g');
%hold on;
plot(stepData{1:end-1,1},step_diff);

%% 25th and 75th percentile + Standard Deviation
prctile_25 = prctile(step_movmean,25);
prctile_75 = prctile(step_movmean,75);
step_sd = std(step);
step_mean = mean(step);

%% Slope sign change
step_SSC = SlopeSignChange(step_diff);
step_logical = logical(step_diff);
Step_Data_table.step_logical = step_logical;

%% Plot 
figure(2)
plot(stepData{1:end-1,1},step_diff);
grid on; hold on; xlabel('Time'); ylabel('Steps');
plot(stepData{1:end-1,1},step_diff_movmean,'r');
hold on;
plot(stepData{:,1},step_median,'g');
hold on;
plot(stepData{1:end-1,1},step_logical,'b');

%% Remove row where steps is zero - It didn't give a better picture
stepRemoveZero = table('Size',[height(stepData) 2],'VariableTypes',["datetime","double"],'VariableNames',["Time","Steps"]); 
x = 1;
for i=1:size(stepData)
   if stepData{i,2} > 0
      stepRemoveZero{x,1} = stepData{i,1};
      stepRemoveZero{x,2} = stepData{i,2};
      x=x+1;
   end
end

%% Slope sign change function
function ssc = SlopeSignChange(x)
ssc=0;
for i=2:length(x)-1;
temp = sign((x(i)-x(i-1)) * (x(i)-x(i+1)));
    if temp > 0
        ssc = ssc + 1;
    end
end
end
