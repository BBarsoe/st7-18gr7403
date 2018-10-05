clear; close all; clc;
%% Water Model based on fluid data and sleep time data
%% Load data
rawSleep = importSleepData('fitbit_sleep_jacob.xls'); %Table, used columns: [StartTime EndTime]
rawFluid = importFluidData('fluid_jacob.xlsx'); %Table, Columns: [Date Amount Type]
%% Convert, trim and sort data raw data
rawSleep(1,:) = [];
sleepData = table('Size',[height(rawSleep) 2],'VariableTypes',["datetime","datetime"],'VariableNames',["BedTime","WakeTime"]);
for i = 1:height(rawSleep) %The for-loop converts time from type String to DateTime, and from AM/PM to 24h.
    sleepData{i,1} = datetime(datestr(datenum(rawSleep{i,1}, 'dd-mm-yyyy HH:MM AM'), 'yyyy-mm-dd HH:MM'),'InputFormat','yyyy-MM-dd HH:mm');
    sleepData{i,2} = datetime(datestr(datenum(rawSleep{i,2}, 'dd-mm-yyyy HH:MM AM'), 'yyyy-mm-dd HH:MM'),'InputFormat','yyyy-MM-dd HH:mm');
end
clear i rawSleep
sleepData = sortrows(sleepData); %Sort the columns "Ascend"

%Table with fluiddata, the type of fluid is removed. 
fluidData = table('Size',[height(rawFluid) 2],'VariableTypes',["datetime","double"],'VariableNames',["Time","Amount"]);
for i = 1:height(rawFluid)
    fluidData{i,1} = rawFluid{i,1};
    fluidData{i,2} = rawFluid{i,2};
end
clear i rawFluid
%% Fluid Intake 
%Define a double array from one to the difference between the first date and last date in seconds
fluidIntake = double(1:seconds(diff([fluidData{1,1} fluidData{height(fluidData),1}])));
%1100ml per day is the amount of fluid a person get from food, therefor it
%is added to the waterIntake. Source: 
fluidIntake(:) = 1100/24/60/60; 

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
        timeSince = seconds(diff([wakeUpTime nowTime]));
        x = x - 1;
   else
        timeSince = seconds(diff([previousFluid nowTime]));
   end
   %Calculate the average fluid intake pr. second
   fluidIntake(seconds(diff([fluidData{1,1} nowTime])) - timeSince + 1:seconds(diff([fluidData{1,1} nowTime]))) = nowFluidIntake/timeSince;
end

%% Simulate the fluid balance
%Define a double array from one to the difference between the first date and last date in seconds
fluidBalance = double(1:seconds(diff([fluidData{1,1} fluidData{height(fluidData),1}])));
fluidBalance(:) = 0; 
%Premise in the model: The person have a fluidBalance at zero in the
%beginning.

for i = 1:length(fluidBalance)
    if(fluidBalance(i) > 0)
       fluidOuttake = dayToSecond(2600); %2600ml is the average amount of fluid segregation per day for a person in rest. 1100ml from food, see line 28. Source:
    else
       fluidOuttake = dayToSecond((2/9)*fluidBalance(i)+2600);
    end %The absorption in the body as a linear regression. Source:
    
    %Calculate the new fluidBalance
    fluidBalance(i+1) = fluidBalance(i) + fluidIntake(i) - fluidOuttake;
    
    if(fluidBalance(i+1) > 2000) %2000ml is the amount of fluid a human body can store in the stomach/intensine. Source:
       fluidBalance(i+1) = 2000; %All fluid over 2000ml is removed, because there isn't space to absorb it in the body.
    end
    if(fluidBalance(i+1) < -3600) %The lowest level of fluid in the human body, 11 precent of body weight. Source:
       fluidBalance(i+1) = -3600;
    end
end

%% Plot
S = fluidData{1,1}:seconds(1):fluidData{end,1};
plot(S,fluidBalance)
grid on;
xlabel('Time (second)'); ylabel('Fluid balance (ml)');
title('Model of Jacobs Fluid Balance');
