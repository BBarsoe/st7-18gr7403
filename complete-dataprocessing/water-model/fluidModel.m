function fluidModel = fluidModel(sleepData,fluidData,heartData,gender,startTime,endTime)
% %% Convert, trim and sort data raw data
% %Create a table with sleepdata. 
% sleepData = table(...
%     'Size',[height(rawSleep) 2],...
%     'VariableTypes',["datetime","datetime"],...
%     'VariableNames',["BedTime","WakeTime"]);
% sleepData{:,1} = rawSleep{:,1};
% sleepData{:,2} = rawSleep{:,2};
% clear rawSleep
% 
% %Create a table with fluid journal data
% fluidData = table(...
%     'Size',[height(rawFluid) 2],...
%     'VariableTypes',["datetime","double"],...
%     'VariableNames',["Time","Amount"]);
% fluidData{:,1} = rawFluid{:,1};
% fluidData{:,2} = rawFluid{:,2};
% clear rawFluid
% 
% %Table with heartRateData
% rawHeartTimeTable = table2timetable(rawHeart);
% resizedHeartTimeTable = retime(rawHeartTimeTable,'minutely','mean');
% heartData = timetable2table(resizedHeartTimeTable);
% clear rawHeart rawHeartTimeTable resizedHeartTimeTable
% 
% %% Finding the start and ending times of the simulation.
% % Neither fluid, sleep or heart data has the same exsact beginning. A
% % identic start time is needed as guessing whats happenening at time
% % without data is a bad ideá. As all three datasets begin within a couble
% % of day of eachother, the latest start time is found and chosen as the
% % offcial start time.
% 
% startTime = max([sleepData{1,2} fluidData{1,1} heartData{1,1}]);
% 
% % The same problem persistest with the ending, whereas guessing the missing
% % values in some dataset is a bad ideá. Here the official ending is chosen
% % as being the earliest time.
% endTime = min([sleepData{end,2} fluidData{end,1} heartData{end,1}]);
% 
% %% Syncing and cutting the data to match in time
% % To make sure the data has the same start time and end time, all data 
% % prior to startTime is removed, and the same with all data after endTime.
% % This is done by first comparing the startTime with a complete date 
% % dataset, which returns a vector, the same size as the original date 
% % dataset, with one and zeroes stateing which date are before the 
% % startTime. Then the function find() is used which searches for the last 
% % instance of the values 1, and returns it's index. Then whether or not 
% % that vector is empty or not, determins if the specific dataset needs 
% % trimming or not. This process repeated for endTime, as well the two other
% % datasets.
% 
% % The dataset of sleep is tested and if nececary, trimmed.
% if ~isempty(find(sleepData{:,2} < startTime,1,'last'))
%     sleepData(1:find(sleepData{:,2} < startTime,1,'last'),:) = [];
% end
% if ~isempty(find(sleepData{:,2} > endTime,1,'last'))
%     sleepData(find(sleepData{:,2} > startTime,1,'last'):end,:) = [];
% end
% 
% % The dataset of fluid jounrnal data is tested and if nececary, trimmed.
% if ~isempty(find(fluidData{:,1} < startTime,1,'last'))
%     fluidData(1:find(fluidData{:,1} < startTime,1,'last'),:) = [];
% end
% if ~isempty(find(fluidData{:,1} > endTime,1,'last'))
%     fluidData(find(fluidData{:,1} > endTime,1,'last'):end,:) = [];
% end
% 
% % The dataset of heart rate data is tested and if nececary, trimmed.
% if ~isempty(find(heartData{:,1} < startTime,1,'last'))
%     heartData(1:find(heartData{:,1} < startTime,1,'last'),:) = [];
% end
% if ~isempty(find(heartData{:,1} > endTime,1,'last'))
%     heartData(find(heartData{:,1} > endTime,1,'last'):end,:) = [];
% end

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


%% Plot
S = startTime:minutes(1):endTime;
fluidModel = table(S,bodyWaterVolume);
% plot(S,bodyWaterVolume)
% grid on;
% xlabel('Time (minutes)'); ylabel('Fluid balance (ml)');
% title('Model of Jacobs Fluid Balance');
end
