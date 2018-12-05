function fluidModel = fluidModel(sleepData,fluidData,heartData,gender,startTime,endTime)
%% Create 'eating'- and 'sleeping'-tables
%Eating table
eatingDistribution = [0,0,0,0,0,0,1,4,2,2,2,2,4,2,2,2,2,1,4,1,1,1,0,0];
eatingDailyAmount = 1100;
eatingAmount = eatingDistribution * ((1/sum(eatingDistribution)) * eatingDailyAmount);
eatingAmountMinutes = 1:1440;
for  i = 1:60:1440
    eatingAmountMinutes(i:i+59) = (1/60) * eatingAmount(ceil(i/60));
end
clear eatingTimes eatingDistribution eatingDailyAmount eatingAmount i

% for i = 1:height(sleepData(:,1))-1
%     wakeupTime = sleepData{i,2};
%     bedTime = sleepData{i+1,1};
%     totaltTimeAwoke = minutes(diff([wakeupTime bedTime]));
% end

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
   if x == 0
      x = 2; 
   end
   wakeUpTime = sleepData{x,2}; %wakeUp to place x, start in the last row in sleepData
   %Compare the wakeUp time and previousFluid time to calculate the
   %timeSince last fluid intake.
   %Premise in the model: The first fluid intake amount in each day is
   %distributed equal from the sleep EndTime to the time in the fluidData
   %table.
%    s = table (nowTime,nowFluidIntake,previousFluid,wakeUpTime)
   if(previousFluid < wakeUpTime) 
        timeSince = minutes(diff([wakeUpTime nowTime]));
        x = x - 1;
   else
        timeSince = minutes(diff([previousFluid nowTime]));
   end
   if timeSince > 240
       timeSince = 240;
   end
   %Calculate the average fluid intake pr. second
   fluidIntake(minutes(diff([startTime nowTime])) - timeSince + 1:minutes(diff([startTime nowTime]))) = nowFluidIntake/timeSince;
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
for i = 1:length(bodyWaterVolume)
    %Calculate the new fluidBalance
    bodyWaterVolume(i+1) = bodyWaterVolume(i)...
        + fluidJournalIntake(i)...
        + eatingAmountMinutes(timeOfDayMinutes)...
        - sweatOutput(heartData{i,2},bodyWaterVolume(i),gender)...
        - urineOutput(heartData{i,2},bodyWaterVolume(i));
    
    if(bodyWaterVolume(i+1) > 2000) %2000ml is the amount of fluid a human body can store in the stomach/intensine. Source:
       bodyWaterVolume(i+1) = 2000; %All fluid over 2000ml is removed, because there isn't space to absorb it in the body.
    end
    if(bodyWaterVolume(i+1) < -9900) %The lowest level of fluid in the human body, 11 precent of body weight. Source:
       bodyWaterVolume(i+1) = -9900;
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

S = startTime:minutes(1):endTime;
fluidModel = table(S,bodyWaterVolume);
end
