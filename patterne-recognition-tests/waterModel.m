clear; close all; clc;

%% Load data
rawSleep = importSleepData('fitbit_sleep_jacob.xls');
rawFluid = importFluidData('fluid_jacob.xlsx');
%% Convert, trim and sort data
rawSleep(1,:) = [];
sleepData = table('Size',[height(rawSleep) 2],'VariableTypes',["datetime","datetime"],'VariableNames',["BedTime","WakeTime"]);
for i = 1:height(rawSleep)
    sleepData{i,1} = datetime(datestr(datenum(rawSleep{i,1}, 'dd-mm-yyyy HH:MM AM'), 'yyyy-mm-dd HH:MM'),'InputFormat','yyyy-MM-dd HH:mm');
    sleepData{i,2} = datetime(datestr(datenum(rawSleep{i,2}, 'dd-mm-yyyy HH:MM AM'), 'yyyy-mm-dd HH:MM'),'InputFormat','yyyy-MM-dd HH:mm');
end
clear i rawSleep
sleepData = sortrows(sleepData);

fluidData = table('Size',[height(rawFluid) 2],'VariableTypes',["datetime","double"],'VariableNames',["Time","Amount"]);
for i = 1:height(rawFluid)
    fluidData{i,1} = rawFluid{i,1};
    fluidData{i,2} = rawFluid{i,2};
end
clear i rawFluid
%%
waterIntake = double(1:seconds(diff([fluidData{1,1} fluidData{height(fluidData),1}])));
waterIntake(:) = 1100/24/60/60;

%% Fordel mængde af væske
x = height(sleepData);
for i = height(fluidData):-1:2
   now = fluidData{i,1};
   nowWaterIntake = fluidData{i,2};
   prevousFluid = fluidData{i-1,1};
   wakeUp = sleepData{x,2};
   if(prevousFluid < wakeUp) 
        timeSince = seconds(diff([wakeUp now]));
        x = x - 1;
   else
        timeSince = seconds(diff([prevousFluid now]));
   end
   waterIntake(seconds(diff([fluidData{1,1} now])) - timeSince + 1:seconds(diff([fluidData{1,1} now]))) = nowWaterIntake/timeSince;
end

%% Simuler væske balance
waterBalance = double(1:seconds(diff([fluidData{1,1} fluidData{height(fluidData),1}])));
waterBalance(:) = 0;
waterBalance(1) = 0;

for i = 1:length(waterBalance)
    if(waterBalance(i) > 0)
       waterOuttake = dayToSecond(2600);
    else
       waterOuttake = dayToSecond((2/9)*waterBalance(i)+2600);
    end
    
    waterBalance(i+1) = waterBalance(i) + waterIntake(i) - waterOuttake;
    
    if(waterBalance(i+1) > 2000)
       waterBalance(i+1) = 2000;
    end
    if(waterBalance(i+1) < -3600) 
       waterBalance(i+1) = -3600;
    end
end

%% Plot
S = fluidData{1,1}:seconds(1):fluidData{end,1};
plot(S,waterBalance)
