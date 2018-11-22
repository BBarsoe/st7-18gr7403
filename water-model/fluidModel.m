clear; close all; clc;
%% Water Model based on fluid data and sleep time data
%% Load data
if isfile("rawData.mat")
    load("rawData.mat");
else 
    rawSleep = importSleepData('fitbit_sleep_jacob.xls');
    rawFluid = importFluidData('fluid_jacob.xlsx'); 
    rawHeart = importHeartRate('female_data_heart.csv',2,444978);
    save('rawData.mat','rawFluid','rawHeart','rawFluid');
end

%% Convert, trim and sort data raw data
%Table with sleepdate, the type of fluid is removed. 
rawSleep(1,:) = [];
sleepData = table('Size',[height(rawSleep) 2],'VariableTypes',["datetime","datetime"],'VariableNames',["BedTime","WakeTime"]);
sleepData{:,1} = datetime(datestr(datenum(rawSleep{:,1}, 'dd-mm-yyyy HH:MM AM'), 'yyyy-mm-dd HH:MM'),'InputFormat','yyyy-MM-dd HH:mm');
sleepData{:,2} = datetime(datestr(datenum(rawSleep{:,2}, 'dd-mm-yyyy HH:MM AM'), 'yyyy-mm-dd HH:MM'),'InputFormat','yyyy-MM-dd HH:mm');
clear rawSleep

%Table with fluiddata, the type of fluid is removed. 
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

%% Create 'eating'- and 'sleeping'-tables
%Eating table
eatingTimes = 0:1:23;
eatingDistribution = [0,0,0,0,0,0,1,4,2,2,2,2,4,2,2,2,2,1,4,1,1,1,0,0];
eatingDailyAmount = 1100;
eatingAmount = eatingDistribution * ((1/sum(eatingDistribution)) * eatingDailyAmount);
eatingAmountMinutes = 1:1440;
for  i = 1:1440
    eatingAmountMinutes(i) = eatingDistribution(ceil(i/60))* ((1/60) * eatingAmount(ceil(i/60)));
end

eatingAmountMinutes = 1:eatingDistribution * eatingAmount:60;
eatingTable = table(eatingTimes',eatingDistribution',eatingAmount',eatingAmountMinutes','VariableNames',["Time","Distribution","Amount","AmountMinutes"]);
clear eatingTimes eatingDistribution eatingDailyAmount eatingAmount

%Sleeping table


%% Fluid Intake 
%Define a double array from one to the difference between the first date
%and last date in minutes
fluidIntake = double(1:minutes(diff([startTime endTime])));
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

%% Simulate the fluid balance
%Define a double array from one to the difference between the first date and last date in seconds
fluidBalance = double(1:minutes(diff([fluidData{1,1} fluidData{height(fluidData),1}])));
fluidBalance(:) = 0; 
%Premise in the model: The person have a fluidBalance at zero in the
%beginning.

for i = 1:length(fluidBalance)
    %Calculate the new fluidBalance
    fluidBalance(i+1) = fluidBalance(i) + fluidIntake(i);
    
    if(fluidBalance(i+1) > 2000) %2000ml is the amount of fluid a human body can store in the stomach/intensine. Source:
       fluidBalance(i+1) = 2000; %All fluid over 2000ml is removed, because there isn't space to absorb it in the body.
    end
    if(fluidBalance(i+1) < -3600) %The lowest level of fluid in the human body, 11 precent of body weight. Source:
       fluidBalance(i+1) = -3600;
    end
end

%% Plot
S = fluidData{1,1}:minutes(1):fluidData{end,1};
plot(S,fluidBalance)
grid on;
xlabel('Time (minutes)'); ylabel('Fluid balance (ml)');
title('Model of Jacobs Fluid Balance');
