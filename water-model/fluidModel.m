clear; close all; clc;
%% Water Model based on fluid data and sleep time data
%% Load data
if isfile("rawData.mat")
    load("rawData.mat");
else 
    rawSleep = importSleepData('fitbit_sleep_jacob.xls');
    rawFluid = importFluidData('fluid_jacob.xlsx'); 
    rawHeart = importHeartRate('female_data_heart.csv',2,444978);
    save('rawData.mat','rawSleep','rawHeart','rawFluid');
end

%% Convert, trim and sort data raw data
%Table with sleepdate, the type of fluid is removed. 
rawSleep(1,:) = [];
sleepData = table('Size',[height(rawSleep) 2],'VariableTypes',["datetime","datetime"],'VariableNames',["BedTime","WakeTime"]);
sleepData{:,1} = datetime(datestr(datenum(rawSleep{:,1}, 'dd-mm-yyyy HH:MM AM'), 'yyyy-mm-dd HH:MM'),'Format', 'yyyy-MM-dd-HH-mm-ss','InputFormat','yyyy-MM-dd HH:mm');
sleepData{:,2} = datetime(datestr(datenum(rawSleep{:,2}, 'dd-mm-yyyy HH:MM AM'), 'yyyy-mm-dd HH:MM'),'Format', 'yyyy-MM-dd-HH-mm-ss','InputFormat','yyyy-MM-dd HH:mm');
clear rawSleep

%Table with fluiddata, the type of fluid is removed
fluidData = table('Size',[height(rawFluid) 2],'VariableTypes',["datetime","double"],'VariableNames',["Time","Amount"]);
fluidData{:,1} = rawFluid{:,1};
fluidData{:,2} = rawFluid{:,2};
startTime = fluidData{1,1};
endTime = fluidData{end,1} + duration(12,0,0);
clear rawFluid

%Table with heartRateData
rawHeartTimeTable = table2timetable(rawHeart);
resizedHeartTimeTable = retime(rawHeartTimeTable,'minutely','mean');
heartData = timetable2table(resizedHeartTimeTable);
clear rawHeart rawHeartTimeTable resizedHeartTimeTable

%% Syncing and cutting the data to match in time
% Takes a dataset, convertes it into a number, and examines if the secound
% number is contained in the dataset. If it is a member of, it returns the
% index in the dataset. Otherwise it returns an empty vector. If the vector
% is not empty the dataset is trimmed according to the found indexes.
if ~(isempty(find(ismember(datenum(sleepData{:,1}),datenum(startTime)),1)))
    sleepData(1:find(ismember(datenum(sleepData{:,1}),datenum(startTime)),1),:) = [];
end
if ~isempty(find(datenum(sleepData{:,1}) < datenum(startTime),1))
    sleepData(find(datenum(sleepData{:,1}) < datenum(startTime),1):end,:) = [];
end
if ~(isempty(find(ismember(datenum(sleepData{:,2}),datenum(endTime)),1)))
    sleepData(find(ismember(datenum(sleepData{:,2}),datenum(endTime)),1):end,:) = [];
end
if ~isempty(find(datenum(sleepData{:,2}) > datenum(endTime),1))
    sleepData(find(datenum(sleepData{:,2}) > datenum(endTime),1):end,:) = [];
end
if ~(isempty(find(ismember(datenum(heartData{:,1}),datenum(startTime)),1)))
    heartData(1:find(ismember(datenum(heartData{:,1}),datenum(startTime)),1),:) = [];
end
if ~(isempty(find(ismember(datenum(heartData{:,1}),datenum(endTime)),1)))
    heartData(find(ismember(datenum(heartData{:,1}),datenum(endTime)),1):end,:) = [];
end
%% Create 'eating'- and 'sleeping'-tables
%Eating table
eatingTimes = 0:1:23;
eatingDistribution = [0,0,0,0,0,0,1,4,2,2,2,2,4,2,2,2,2,1,4,1,1,1,0,0];
eatingDailyAmount = 1100;
eatingAmount = eatingDistribution * ((1/sum(eatingDistribution)) * eatingDailyAmount);
eatingAmountMinutes = 1:1440;
for  i = 1:1440
    eatingAmountMinutes(i) = (1/60) * eatingAmount(ceil(i/60));
end
clear eatingTimes eatingDistribution eatingDailyAmount eatingAmount

%Sleeping table


%% Fluid Intake 
%Define a double array from one to the difference between the first date
%and last date in minutes
fluidJournalIntake = double(1:minutes(diff([startTime endTime])));
fluidJournalIntake(:) = 0;
%1100ml per day is the amount of fluid a person get from food, therefor it
%is added to the waterIntake. Source:

%% Distribute the fluid
x = height(sleepData);
for i = height(fluidData):-1:2 %Loop through the FluidData table from the end to row 2 
   nowTime = fluidData{i,1}; %Time to row i
   nowFluidIntake = fluidData{i,2}; %Fluid amount to row i
   previousFluid = fluidData{i-1,1}; %Fluid amount to row i-1
   wakeUpTime = sleepData{x,2}; %wakeUp to place x, start in the last row in sleepData
   %Compare the wakeUp time and previousFluid time to calculate the
   %timeSince last fluid intake.
   %Premise in the model: The first fluid intake amount in each day is
   %distributed equal from the sleep EndTime to the time in the fluidData
   %table.
   if(previousFluid < wakeUpTime) 
        timeSince = minutes(diff([wakeUpTime nowTime]));
        x = x - 1;
   else
        timeSince = minutes(diff([previousFluid nowTime]));
   end
   %Calculate the average fluid intake pr. second
   fluidIntake(minutes(diff([fluidData{1,1} nowTime])) - timeSince + 1:minutes(diff([fluidData{1,1} nowTime]))) = nowFluidIntake/timeSince;
end
fluidJournalIntake(1:length(fluidIntake)) = fluidIntake;
%% Setup simulation
timeOfDayMinutes = minutes(timeofday(startTime));
%% Simulate the fluid balance
%Define a double array from one to the difference between the first date and last date in seconds
bodyWaterVolume = double(1:minutes(diff([startTime endTime])));
bodyWaterVolume(:) = 0; 
%Premise in the model: The person have a fluidBalance at zero in the
%beginning.
for i = 1:length(bodyWaterVolume)-1
    %Calculate the new fluidBalance
    bodyWaterVolume(i+1) = bodyWaterVolume(i)...
        + fluidJournalIntake(i)...
        + eatingAmountMinutes(timeOfDayMinutes)...
        - sweatOutput(heartData{i,2},bodyWaterVolume(i),"male")...
        - urineOutput(heartData{i,2},bodyWaterVolume(i));
    
    if(bodyWaterVolume(i+1) > 2000) %2000ml is the amount of fluid a human body can store in the stomach/intensine. Source:
       bodyWaterVolume(i+1) = 2000; %All fluid over 2000ml is removed, because there isn't space to absorb it in the body.
    end
    if(bodyWaterVolume(i+1) < -3600) %The lowest level of fluid in the human body, 11 precent of body weight. Source:
       bodyWaterVolume(i+1) = -3600;
    end
    timeOfDayMinutes = timeOfDayMinutes + 1;
    %Incrementing the time of day
    if timeOfDayMinutes == 1441
       timeOfDayMinutes = 1; 
    end
%     clc;
%     S = "BW = " + bodyWaterVolume(i) + ...
%     " | FJI = " + fluidJournalIntake(i) + ...
%     " | EAM = " + eatingAmountMinutes(timeOfDayMinutes) + ...
%     " | SWO = " + sweatOutput(heartData{i,2},bodyWaterVolume(i),"male") + ...
%     " | UO = " + urineOutput(heartData{i,2},bodyWaterVolume(i))
end


%% Plot
S = startTime+minutes(1):minutes(1):endTime;
plot(S,bodyWaterVolume)
grid on;
xlabel('Time (minutes)'); ylabel('Fluid balance (ml)');
title('Model of Jacobs Fluid Balance');
