clear; close all; clc;
%% Water Model based on fluid data and sleep time data
%% Load data
rawSleep = importSleepData('fitbit_sleep_jacob.xls'); %Table, used columns: [StartTime EndTime]
rawFluid = importFluidData('fluid_jacob.xlsx'); %Table, Columns: [Date Amount Type]
rawHeart = importHeartRate('female_data_heart.csv',2);
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
%% Load heart data
rawHeart.Properties.VariableNames{1} = 'Date';%Sørger for at kolonnerne har variabelnavne til scriptet
rawHeart.Properties.VariableNames{2} = 'heart';
[minute_number1,minutes_time1] = discretize(rawHeart.Date(1:400000),'minute');%Inddeler data i minut intervaller
[minute_number2,minutes_time2] = discretize(rawHeart.Date(400001:end),'minute');%Inddeler data i minut intervaller
minutes_time1 = minutes_time1';%Vender matricen fra 1 række til 1 kolonne
minutes_time2 = minutes_time2';%Vender matricen fra 1 række til 1 kolonne
minute_number = [minute_number1;minute_number2];
minutes_time = [minutes_time1;minutes_time2];
%imported_dataset.minute = minute_number; Ved ikke lige hvorfor den her er der
G = findgroups(minute_number);%Grupperer heart data i minutter
heartsplit = splitapply(@mean,rawHeart.heart,G);%gns heart pr. minut

k = 1;
tmp = 0;
lasttime = 2;
data = table(minutes_time,zeros(length(minutes_time),1));%Laver en matrice med minutter og nuller
for i = 2:height(rawHeart)%Hele datasættet uden NaN på række 1
    
    if (minutes_time(k) >= rawHeart.Date(i))%Hvis tiden er lavere end optællingsminuttet
        tmp = rawHeart.heart(i)+tmp;%Lægger heart sammen med tidligere tal
        
    elseif (rawHeart.Date(i) > minutes_time(k)+minutes(1))%Hvis der er mere end 1 minut mellem datapunkter
        while (rawHeart.Date(i) > minutes_time(k)+minutes(1))
            tmp = rawHeart.heart(i);
            k = k+1;%Tæller k op uden at inkrementere i så vi ikke kommer ud af sync
            lasttime = i;%Så der ikke divideres med den tidligere i (fra if->elseif)
        end
    else
        data{k,2} = tmp/(i-lasttime);%Tager gns af minuttets datapunkter
        tmp = rawHeart.heart(i);%Nulstiller tmp til nuværende heart
        k = k+1;%Øger tællingsminuttet
        lasttime = i;%Nulstiller nævneren
    end
end
heartRateData = data.heart;
clear G heartsplit i k minute_number minute_number1 minute_number2 ...
    minutes_time minutes_time1 minutes_time2 rawHeart tmp 
%% Create 'eating'- and 'sleeping'-tables


%% Fluid Intake 
%Define a double array from one to the difference between the first date
%and last date in minutes
fluidIntake = double(1:minutes(diff([fluidData{1,1} fluidData{height(fluidData),1}])));
%1100ml per day is the amount of fluid a person get from food, therefor it
%is added to the waterIntake. Source: 
fluidIntake(:) = dayToMinute(1100); 

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
    if(fluidBalance(i) > 0)
       fluidOuttake = dayToMinute(2600); %2600ml is the average amount of fluid segregation per day for a person in rest. 1100ml from food, see line 28. Source:
    else
       fluidOuttake = dayToMinute((2/9)*fluidBalance(i)+2600);
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
S = fluidData{1,1}:minutes(1):fluidData{end,1};
plot(S,fluidBalance)
grid on;
xlabel('Time (minutes)'); ylabel('Fluid balance (ml)');
title('Model of Jacobs Fluid Balance');
