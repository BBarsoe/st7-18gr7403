 clear
 close all
 clc
 
%% %% %% %% %% %% %% %%
%% Adding paths
addpath(genpath('data'));
addpath(genpath('water-model'));
%% Choose subject
prompt = ['Which subject would you like to import data for?\nChoose 1 2 or 3\n'];
subjectNumber = input(prompt);
clear prompt
clc
switch subjectNumber
    case 1
        [rawSteps, rawHeart, rawSleep, rawFluid, rawHeadache] = importSubject1();
        gender = "female";
        fluidModelFileName = "data/fluidModelResultSubject1.mat";
        featuresFileName = "data/featuresSubject1";
    case 2
        [rawSteps, rawHeart, rawSleep, rawFluid, rawHeadache] = importSubject2();
        gender = "female";
        fluidModelFileName = "data/fluidModelResultSubject2.mat";
        featuresFileName = "data/featuresSubject2";
    case 3
        [rawSteps, rawHeart, rawSleep, rawFluid, rawHeadache] = importSubject3();
        gender = "male";
        fluidModelFileName = "data/fluidModelResultSubject3.mat";
        featuresFileName = "data/featuresSubject3";
    otherwise
    error("No subject found with that number")
    finish
end
clear subjectNumber
%% Convert, trim and sort data raw data
%Create a table with stepdata. 
stepsData = table(...
    'Size',[height(rawSteps) 2],...
    'VariableTypes',["datetime","double"],...
    'VariableNames',["timestamp","value"]);
stepsData{:,1} = rawSteps{:,1};
stepsData{:,2} = rawSteps{:,2};
clear rawSteps

%Table with heartRateData
rawHeartTimeTable = table2timetable(rawHeart);
resizedHeartTimeTable = retime(rawHeartTimeTable,'minutely','mean'); 
heartDataTimeTable = timetable2table(resizedHeartTimeTable);

idx = (~isnan(heartDataTimeTable{:,2})); %non nans
vr = heartDataTimeTable{idx,2}; %v non nan
v2 = vr(cumsum(idx)); %use cumsum to build index into vr

heartData = table(...
    'Size',[length(heartDataTimeTable{:,1}) 2],...
    'VariableTypes',["datetime","double"],...
    'VariableNames',["timestamp","value"]);
heartData{:,1} = heartDataTimeTable{:,1};
heartData{:,2} = v2;
clear rawHeart rawHeartTimeTable resizedHeartTimeTable heartDataTimeTable

%Create a table with sleepdata.
rawSleep.Properties.VariableNames{1} = 'bedTime';
rawSleep.Properties.VariableNames{2} = 'wakeTime';
sleepData = table(...
    'Size',[height(rawSleep) 2],...
    'VariableTypes',["datetime","datetime"],...
    'VariableNames',["bedTime","wakeTime"]);
sleepData{:,1} = rawSleep{:,1};
sleepData{:,2} = rawSleep{:,2};

isSleepingData = table(...
     'Size',[length(heartData.timestamp) 2],...
     'VariableTypes',["datetime","double"],...
     'VariableNames',["timestamp","value"]);
isSleepingData{:,1} = heartData{:,1};
isSleepingData{:,2} = 0;

sleepingAverageData = table(...
     'Size',[length(heartData.timestamp) 2],...
     'VariableTypes',["datetime","double"],...
     'VariableNames',["timestamp","value"]);
sleepingAverageData{:,1} = heartData{:,1};
sleepingAverageData{:,2} = 0;

%Create a table with fluid journal data
fluidData = table(...
    'Size',[height(rawFluid) 2],...
    'VariableTypes',["datetime","double"],...
    'VariableNames',["timestamp","value"]);
fluidData{:,1} = rawFluid{:,1};
fluidData{:,2} = rawFluid{:,2};
clear rawFluid

%Create a table with headache data
rawHeadache.Properties.VariableNames{1} = 'headacheStartTime';
rawHeadache.Properties.VariableNames{2} = 'headacheEndTime';
headacheData = table(...
     'Size',[length(heartData.timestamp) 2],...
     'VariableTypes',["datetime","double"],...
     'VariableNames',["timestamp","value"]);
headacheData{:,1} = heartData{:,1};
headacheData{:,2} = ones;

%% Finding the start and ending times of the simulation.
% Neither fluid, sleep or heart data has the same exsact beginning. A
% identic start time is needed as guessing whats happenening at time
% without data is a bad ideá. As all three datasets begin within a couble
% of day of eachother, the latest start time is found and chosen as the
% offcial start time.

startTime = max([...
    stepsData.timestamp(1) ...
    heartData.timestamp(1) ...
    sleepData.bedTime(1)   ...
    fluidData.timestamp(1) ]);

% The same problem persistest with the ending, whereas guessing the missing
% values in some dataset is a bad ideá. Here the official ending is chosen
% as being the earliest time.
endTime = min([...
    stepsData.timestamp(end) ...
    heartData.timestamp(end) ...
    sleepData.bedTime(end)   ...
    fluidData.timestamp(end) ]);

%% Syncing and cutting the data to match in time
% To make sure the data has the same start time and end time, all data 
% prior to startTime is removed, and the same with all data after endTime.
% This is done by first comparing the startTime with a complete date 
% dataset, which returns a vector, the same size as the original date 
% dataset, with one and zeroes stateing which date are before the 
% startTime. Then the function find() is used which searches for the last 
% instance of the values 1, and returns it's index. Then whether or not 
% that vector is empty or not, determins if the specific dataset needs 
% trimming or not. This process repeated for endTime, as well the two other
% datasets.

% The dataset of steps is tested and if nececary, trimmed.
if ~isempty(find(stepsData.timestamp(:) < startTime,1,'last'))
    stepsData(1:find(stepsData.timestamp(:) < startTime,1,'last'),:) = [];
end
if ~isempty(find(stepsData.timestamp(:) > endTime,1,'first'))
    stepsData(find(stepsData.timestamp(:) > endTime,1,'first'):end,:) = [];
end

% The dataset of heart rate data is tested and if nececary, trimmed.
if ~isempty(find(heartData.timestamp(:) < startTime,1,'last'))
    heartData(1:find(heartData.timestamp(:) < startTime,1,'last'),:) = [];
end
if ~isempty(find(heartData.timestamp(:) > endTime,1,'first'))
    heartData(find(heartData.timestamp(:) > endTime,1,'first'):end,:) = [];
end

% The dataset of sleep is tested and if nececary, trimmed.
if ~isempty(find(sleepData.bedTime(:) < startTime,1,'last'))
    sleepData(1:find(sleepData.bedTime(:) < startTime,1,'last'),:) = [];
end
if ~isempty(find(sleepData.bedTime(:) > endTime,1,'first'))
    sleepData(find(sleepData.bedTime(:) > endTime,1,'first'):end,:) = [];
end

% The dataset of fluid jounrnal data is tested and if nececary, trimmed.
if ~isempty(find(fluidData.timestamp(:) < startTime,1,'last'))
    fluidData(1:find(fluidData.timestamp(:) < startTime,1,'last'),:) = [];
end
if ~isempty(find(fluidData.timestamp(:) > endTime,1,'first'))
    fluidData(find(fluidData.timestamp(:) > endTime,1,'first'):end,:) = [];
end

% The dataset of headache data is tested and if nececary, trimmed.
if ~isempty(find(headacheData.timestamp(:) < startTime,1,'last'))
    headacheData(1:find(headacheData.timestamp(:) < startTime,1,'last'),:) = [];
end
if ~isempty(find(headacheData.timestamp(:) > endTime,1,'first'))
    headacheData(find(headacheData.timestamp(:) > endTime,1,'first'):end,:) = [];
end

% The dataset of isSleepingData data is tested and if nececary, trimmed.
if ~isempty(find(isSleepingData.timestamp(:) < startTime,1,'last'))
    isSleepingData(1:find(isSleepingData.timestamp(:) < startTime,1,'last'),:) = [];
end
if ~isempty(find(isSleepingData.timestamp(:) > endTime,1,'first'))
    isSleepingData(find(isSleepingData.timestamp(:) > endTime,1,'first'):end,:) = [];
end

% The dataset of the sleeping average data is tested and if nececary, trimmed.
if ~isempty(find(sleepingAverageData.timestamp(:) < startTime,1,'last'))
    sleepingAverageData(1:find(sleepingAverageData.timestamp(:) < startTime,1,'last'),:) = [];
end
if ~isempty(find(sleepingAverageData.timestamp(:) > endTime,1,'first'))
    sleepingAverageData(find(sleepingAverageData.timestamp(:) > endTime,1,'first'):end,:) = [];
end


%% Run the fluid model
if isfile(fluidModelFileName)
    load(fluidModelFileName);
else
    res = fluidModel(sleepData,fluidData,heartData,gender,startTime,endTime);
    fluidModelResult = table(...
        res.S',res.bodyWaterVolume',...
        'VariableNames',["timestamp","value"]);
    save(fluidModelFileName,'fluidModelResult');
end
clear fluidData gender fluidModelFile
%% adding headache
for i = 1:height(rawHeadache)
    ha = find(headacheData.timestamp == rawHeadache.headacheStartTime(i));
    hb = find(headacheData.timestamp == rawHeadache.headacheEndTime(i));
    headacheData.value(ha:hb) = zeros;
end
clear ha hb i
%% Features of sleeptime
%1 when sleeping, 0 when awake
for i = 1:height(sleepData)
    s_s = find(isSleepingData.timestamp == (sleepData.bedTime(i)));
    s_e = find(isSleepingData.timestamp == (sleepData.wakeTime(i)));
    isSleepingData.value(s_s:s_e)=1;
end
% Movingsum, last seven days
sleepingAverageData.value = movsum(isSleepingData.value,10080)/7/60; %In hours

%% features for heart
window_size_1h = 60;
window_size_15m = 15;
% heart = heartData.;
heart_diff = diff(heartData.value);
heart_diff_movmax = movmax(heart_diff,window_size_1h);
heart_diff_movmean = movmean(heart_diff,window_size_1h);
heart_diff_movmin = movmin(heart_diff,window_size_1h);
heart_movmedian_1h = movmedian(heartData.value,window_size_1h);
heart_movmean_1h = movmean(heartData.value,window_size_1h);
heart_movmin_1h = movmin(heartData.value,window_size_1h);
heart_movmax_1h = movmax(heartData.value,window_size_1h);
heart_movstd_1h = movstd(heartData.value,window_size_1h);
% window size 15m
heart_movmedian_15m = movmedian(heartData.value,window_size_15m);
heart_movmean_15m = movmean(heartData.value,window_size_15m);
heart_movmin_15m = movmin(heartData.value,window_size_15m);
heart_movmax_15m = movmax(heartData.value,window_size_15m);
heart_movstd_15m = movstd(heartData.value,window_size_15m);
% delay heart features 
delay_heart_5m = delayseq(heartData.value(2:end),5); % delay heart 5 min
delay_heart_15m = delayseq(heartData.value(2:end),15); % delay heart 15 min
delay_heart_1h = delayseq(heartData.value(2:end),60); % delay heart 1 hour
delay_heart_5h = delayseq(heartData.value(2:end),300); % delay heart 5 hours
delay_heart_diff_5m = delayseq(heart_diff(2:end),5); 
delay_heart_diff_15m = delayseq(heart_diff(2:end),15);
delay_heart_diff_1h = delayseq(heart_diff(2:end),60);
delay_heart_diff_5h = delayseq(heart_diff(2:end),300);
% Moving at delay features
heart_movstd_1m_delay_5m = movstd(delay_heart_5m,1);
heart_movstd_5m_delay_15m = movstd(delay_heart_15m,5);
heart_movstd_15m_delay_1h = movstd(delay_heart_1h,15);
heart_movstd_2h_delay_5h = movstd(delay_heart_5h,120);
heart_movmean_1m_delay_5m = movmean(delay_heart_5m,1);
heart_movmean_5m_delay_15m = movmean(delay_heart_15m,5);
heart_movmean_15m_delay_1h = movmean(delay_heart_1h,15);
heart_movmean_2h_delay_5h = movmean(delay_heart_5h,120);

%% features for steps
steps_diff = diff(stepsData.value);
steps_movmean_1h = movmean(stepsData.value,window_size_1h);
steps_movmedian_1h = movmedian(stepsData.value,window_size_1h);
steps_movmin_1h = movmin(stepsData.value,window_size_1h);
steps_movmax_1h = movmax(stepsData.value,window_size_1h);
steps_movstd_1h = movstd(stepsData.value,window_size_1h);
% window size 15m
steps_movmedian_15m = movmedian(stepsData.value,window_size_15m);
steps_movmean_15m = movmean(stepsData.value,window_size_15m);
steps_movmin_15m = movmin(stepsData.value,window_size_15m);
steps_movmax_15m = movmax(stepsData.value,window_size_15m);
steps_movstd_15m = movstd(stepsData.value,window_size_15m);
% delay step feature
delay_steps_5m = delayseq(stepsData.value,5); % delay step 5 min
delay_steps_15m = delayseq(stepsData.value,15); % delay step 15 min
delay_steps_1h = delayseq(stepsData.value,60); % delay step 1 hour
delay_steps_5h = delayseq(stepsData.value,300); % delay step 5 hours
delay_steps_diff_5m = delayseq(steps_diff(1:end),5);
delay_steps_diff_15m = delayseq(steps_diff(1:end),15);
delay_steps_diff_1h = delayseq(steps_diff(1:end),60);
delay_steps_diff_5h = delayseq(steps_diff(1:end),300);
% Moving at delay features
step_movstd_1m_delay_5m = movstd(delay_steps_5m,1); %Tilføjet
step_movstd_5m_delay_15m = movstd(delay_steps_15m,5); %Tilføjet
step_movstd_15m_delay_1h = movstd(delay_steps_1h,15); %Tilføjet
step_movstd_2h_delay_5h = movstd(delay_steps_5h,120); %Tilføjet
step_movmean_1m_delay_5m = movmean(delay_steps_5m,1); %Tilføjet
step_movmean_5m_delay_15m = movmean(delay_steps_15m,5); %Tilføjet
step_movmean_15m_delay_1h = movmean(delay_steps_1h,15); %Tilføjet
step_movmean_2h_delay_5h = movmean(delay_steps_5h,120); %Tilføjet

%% Make a table
featuresData = table(...
    heartData.timestamp(1:end-2),...
    heartData.value(1:end-2),...
    heart_diff(1:end-1),...
    heart_diff_movmax(1:end-1),...
    heart_diff_movmean(1:end-1),...
    heart_diff_movmin(1:end-1),...
    heart_movmedian_1h(1:end-2),...
    heart_movmean_1h(1:end-2),...
    heart_movmin_1h(1:end-2),...
    heart_movmax_1h(1:end-2),...
    heart_movstd_1h(1:end-2),...
    delay_heart_5m(1:end-1),...
    delay_heart_15m(1:end-1),...
    delay_heart_1h(1:end-1),...
    delay_heart_5h(1:end-1),...
    stepsData.value(1:end-2),...
    steps_diff(1:end-1),...
    steps_movmean_1h(1:end-2),...
    steps_movmedian_1h(1:end-2),...
    steps_movmin_1h(1:end-2),...
    steps_movmax_1h(1:end-2),...
    steps_movstd_1h(1:end-2),...
    delay_steps_5m(1:end-2),...
    delay_steps_15m(1:end-2),...
    delay_steps_1h(1:end-2),...
    delay_steps_5h(1:end-2),...
    isSleepingData.value(1:end-2),...
    sleepingAverageData.value(1:end-2),...
    delay_heart_diff_5m,...
    delay_heart_diff_15m,...
    delay_heart_diff_1h,...
    delay_heart_diff_5h,...
    delay_steps_diff_5m(1:end-1),...
    delay_steps_diff_15m(1:end-1),...
    delay_steps_diff_1h(1:end-1),...
    delay_steps_diff_5h(1:end-1),...
    heart_movmedian_15m(1:end-2),...
    heart_movmean_15m(1:end-2),...
    heart_movmin_15m(1:end-2),...
    heart_movmax_15m(1:end-2),...
    heart_movstd_15m(1:end-2),...
    steps_movmean_15m(1:end-2),...
    steps_movmedian_15m(1:end-2),...
    steps_movmin_15m(1:end-2),...
    steps_movmax_15m(1:end-2),...
    steps_movstd_15m(1:end-2),...
    heart_movstd_1m_delay_5m(1:end-1),...
    heart_movstd_5m_delay_15m(1:end-1),...
    heart_movstd_15m_delay_1h(1:end-1),...
    heart_movstd_2h_delay_5h(1:end-1),...
    heart_movmean_1m_delay_5m(1:end-1),...
    heart_movmean_5m_delay_15m(1:end-1),...
    heart_movmean_15m_delay_1h(1:end-1),...
    heart_movmean_2h_delay_5h(1:end-1),...
    step_movstd_1m_delay_5m(1:end-2),...
    step_movstd_5m_delay_15m(1:end-2),...
    step_movstd_15m_delay_1h(1:end-2),...
    step_movstd_2h_delay_5h(1:end-2),...
    step_movmean_1m_delay_5m(1:end-2),...
    step_movmean_5m_delay_15m(1:end-2),...
    step_movmean_15m_delay_1h(1:end-2),...
    step_movmean_2h_delay_5h(1:end-2),...
    fluidModelResult.value(1:end-2),...
    headacheData.value(1:end-2));
featuresData.Properties.VariableNames{1} = 'hour';
featuresData.Properties.VariableNames{2} = 'heart';
featuresData.Properties.VariableNames{3} = 'heart_diff'; 
featuresData.Properties.VariableNames{4} = 'heart_diff_movmax'; 
featuresData.Properties.VariableNames{5} = 'heart_diff_movmean';
featuresData.Properties.VariableNames{6} = 'heart_diff_movmin'; 
featuresData.Properties.VariableNames{7} = 'heart_movmedian_1h';
featuresData.Properties.VariableNames{8} = 'heart_movmean_1h';
featuresData.Properties.VariableNames{9} = 'heart_movmin_1h';
featuresData.Properties.VariableNames{10} = 'heart_movmax_1h';
featuresData.Properties.VariableNames{11} = 'heart_movstd_1h';
featuresData.Properties.VariableNames{12} = 'delay_heart_5m'; 
featuresData.Properties.VariableNames{13} = 'delay_heart_15m';
featuresData.Properties.VariableNames{14} = 'delay_heart_1h'; 
featuresData.Properties.VariableNames{15} = 'delay_heart_5h'; 

featuresData.Properties.VariableNames{16} = 'steps';
featuresData.Properties.VariableNames{17} = 'steps_diff'; 
featuresData.Properties.VariableNames{18} = 'steps_movmean';
featuresData.Properties.VariableNames{19} = 'steps_movmedian';
featuresData.Properties.VariableNames{20} = 'steps_movmin';
featuresData.Properties.VariableNames{21} = 'steps_movmax';
featuresData.Properties.VariableNames{22} = 'steps_movstd';
featuresData.Properties.VariableNames{23} = 'delay_steps_5m'; 
featuresData.Properties.VariableNames{24} = 'delay_steps_15m';
featuresData.Properties.VariableNames{25} = 'delay_steps_1h'; 
featuresData.Properties.VariableNames{26} = 'delay_steps_5h'; 

featuresData.Properties.VariableNames{27} = 'sleeptime';
featuresData.Properties.VariableNames{28} = 'sleepaverage';

% Delay at diff features
featuresData.Properties.VariableNames{29} = 'delay_heart_diff_5m'; 
featuresData.Properties.VariableNames{30} = 'delay_heart_diff_15m';
featuresData.Properties.VariableNames{31} = 'delay_heart_diff_1h'; 
featuresData.Properties.VariableNames{32} = 'delay_heart_diff_5h'; 
featuresData.Properties.VariableNames{33} = 'delay_steps_diff_5m'; 
featuresData.Properties.VariableNames{34} = 'delay_steps_diff_15m';
featuresData.Properties.VariableNames{35} = 'delay_steps_diff_1h'; 
featuresData.Properties.VariableNames{36} = 'delay_steps_diff_5h'; 

% Window size 15m features
featuresData.Properties.VariableNames{37} = 'heart_movmedian_15m';
featuresData.Properties.VariableNames{38} = 'heart_movmean_15m';
featuresData.Properties.VariableNames{39} = 'heart_movmin_15m';
featuresData.Properties.VariableNames{40} = 'heart_movmax_15m';
featuresData.Properties.VariableNames{41} = 'heart_movstd_15m';
featuresData.Properties.VariableNames{42} = 'steps_movmean_15m';
featuresData.Properties.VariableNames{43} = 'steps_movmedian_15m';
featuresData.Properties.VariableNames{44} = 'steps_movmin_15m';
featuresData.Properties.VariableNames{45} = 'steps_movmax_15m';
featuresData.Properties.VariableNames{46} = 'steps_movstd_15m';

% Moving at delay features
% heart
featuresData.Properties.VariableNames{47} ='heart_movstd_1m_delay_5m';
featuresData.Properties.VariableNames{48} ='heart_movstd_5m_delay_15m';
featuresData.Properties.VariableNames{49} ='heart_movstd_15m_delay_1h';
featuresData.Properties.VariableNames{50} ='heart_movstd_2h_delay_5h';
featuresData.Properties.VariableNames{51} ='heart_movmean_1m_delay_5m';
featuresData.Properties.VariableNames{52} ='heart_movmean_5m_delay_15m';
featuresData.Properties.VariableNames{53} ='heart_movmean_15m_delay_1h';
featuresData.Properties.VariableNames{54} ='heart_movmean_2h_delay_5h';
% step
featuresData.Properties.VariableNames{55} ='step_movstd_1m_delay_5m';
featuresData.Properties.VariableNames{56} ='step_movstd_5m_delay_15m';
featuresData.Properties.VariableNames{57} ='step_movstd_15m_delay_1h';
featuresData.Properties.VariableNames{58} ='step_movstd_2h_delay_5h';
featuresData.Properties.VariableNames{59} ='step_movmean_1m_delay_5m';
featuresData.Properties.VariableNames{60} ='step_movmean_5m_delay_15m';
featuresData.Properties.VariableNames{61} ='step_movmean_15m_delay_1h';
featuresData.Properties.VariableNames{62} ='step_movmean_2h_delay_5h';
featuresData.Properties.VariableNames{63} ='fluidmodel';
% Headache
featuresData.Properties.VariableNames{64} = 'headache';

% Data_table(1:5,:) =[]; % Delete the first 5 miniuts of data 
% Data_table(1:15,:) =[]; % Delete the first 15 miniuts of data 
% Data_table(1:60,:) =[]; % Delete the first 60 miniuts of data 
featuresData(1:300,:) =[]; % Delete the first 5 hours of data

%% Saveing the table
save(featuresFileName,'featuresData');