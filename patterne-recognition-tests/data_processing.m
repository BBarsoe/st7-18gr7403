 clear all
 close all
 clc
%% Load heart data
imported_dataset = importfile('female_heart_1509-2011.csv',2,608920);%Importerer datas�ttet der bruges
imported_dataset.Properties.VariableNames{1} = 'Date';%S�rger for at kolonnerne har variabelnavne til scriptet
imported_dataset.Properties.VariableNames{2} = 'heart';
[minute_number1,minutes_time1] = discretize(imported_dataset.Date(1:400000),'minute');%Inddeler data i minut intervaller
[minute_number2,minutes_time2] = discretize(imported_dataset.Date(400001:end),'minute');%Inddeler data i minut intervaller
minutes_time1 = minutes_time1';%Vender matricen fra 1 r�kke til 1 kolonne
minutes_time2 = minutes_time2';%Vender matricen fra 1 r�kke til 1 kolonne
minute_number = [minute_number1;minute_number2];
minutes_time = [minutes_time1;minutes_time2];
%imported_dataset.minute = minute_number; Ved ikke lige hvorfor den her er der
G = findgroups(minute_number);%Grupperer heart data i minutter
heartsplit = splitapply(@mean,imported_dataset.heart,G);%gns heart pr. minut

k = 1;
tmp = 0;
lasttime = 2;
data = table(minutes_time,zeros(length(minutes_time),1));%Laver en matrice med minutter og nuller
for i = 2:height(imported_dataset)%Hele datas�ttet uden NaN p� r�kke 1
    
    if (minutes_time(k) >= imported_dataset.Date(i))%Hvis tiden er lavere end opt�llingsminuttet
        tmp = imported_dataset.heart(i)+tmp;%L�gger heart sammen med tidligere tal
        
    elseif (imported_dataset.Date(i) > minutes_time(k)+minutes(1))%Hvis der er mere end 1 minut mellem datapunkter
        while (imported_dataset.Date(i) > minutes_time(k)+minutes(1))
            tmp = imported_dataset.heart(i);
            k = k+1;%T�ller k op uden at inkrementere i s� vi ikke kommer ud af sync
            lasttime = i;%S� der ikke divideres med den tidligere i (fra if->elseif)
        end
    else
        data{k,2} = tmp/(i-lasttime);%Tager gns af minuttets datapunkter
        tmp = imported_dataset.heart(i);%Nulstiller tmp til nuv�rende heart
        k = k+1;%�ger t�llingsminuttet
        lasttime = i;%Nulstiller n�vneren
    end
end
%% load step data
Step_Data = importfile('female_steps_1509-2011.csv',2,96481);
Step_Data.Properties.VariableNames{1} = 'Date';%S�rger for at kolonnerne har variabelnavne til scriptet
Step_Data.Properties.VariableNames{2} = 'steps';
%Dataset = importfile('Erik_dataset.csv',1,135762);
%Dataset = importfile('Jacob_0110_0410.csv',34702,153487);
%load 'Dataset.mat'
%% adding headache
data.headache(:) = ones;
data.Properties.VariableNames{1} = 'Date';
data.Properties.VariableNames{2} = 'heart';

ha = find(data.Date==('2018-09-14-14-00-00'));
hb = find(data.Date==('2018-09-14-15-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-09-15-18-00-00'));
hb = find(data.Date==('2018-09-15-22-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-09-19-19-00-00'));
hb = find(data.Date==('2018-09-19-22-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-09-21-16-30-00'));
hb = find(data.Date==('2018-09-21-22-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-09-24-09-00-00'));
hb = find(data.Date==('2018-09-24-22-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-09-27-09-00-00'));
hb = find(data.Date==('2018-09-27-22-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-09-28-05-30-00'));
hb = find(data.Date==('2018-09-28-07-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-03-10-00-00'));
hb = find(data.Date==('2018-10-03-15-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-06-08-00-00'));
hb = find(data.Date==('2018-10-06-15-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-07-18-30-00'));
hb = find(data.Date==('2018-10-07-19-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-10-18-00-00'));
hb = find(data.Date==('2018-10-10-21-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-11-20-00-00'));
hb = find(data.Date==('2018-10-11-22-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-12-07-00-00'));
hb = find(data.Date==('2018-10-12-10-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-13-08-00-00'));
hb = find(data.Date==('2018-10-13-19-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-15-17-30-00'));
hb = find(data.Date==('2018-10-15-20-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-19-10-00-00'));
hb = find(data.Date==('2018-10-19-16-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-31-18-30-00'));
hb = find(data.Date==('2018-10-31-19-30-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-04-19-00-00'));
hb = find(data.Date==('2018-11-04-22-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-08-07-00-00'));
hb = find(data.Date==('2018-11-08-22-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-09-07-00-00'));
hb = find(data.Date==('2018-11-09-10-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-12-10-00-00'));
hb = find(data.Date==('2018-11-12-19-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-18-19-00-00'));
hb = find(data.Date==('2018-11-18-22-00-00'));
data.headache(ha:hb )=zeros;

data(62093,:) = [];%Slet overlap mellem de to minutes_time
data(62094,:) = [];

table_heart_step = table(data.Date,data.heart,Step_Data.steps,data.headache);
table_heart_step.Properties.VariableNames{1} = 'Date';
table_heart_step.Properties.VariableNames{2} = 'heart';
table_heart_step.Properties.VariableNames{3} = 'steps';
table_heart_step.Properties.VariableNames{4} = 'headache';
%% Load Sleep data
sleep_file = importfile_sleep('female_sleep.csv',3,53);
sleepData = table('Size',[height(sleep_file) 2],'VariableTypes',["datetime","datetime"],'VariableNames',["BedTime","WakeTime"]);
for i = 1:height(sleep_file) %The for-loop converts time from type String to DateTime, and from AM/PM to 24h.
    sleepData{i,1} = datetime(datestr(datenum(sleep_file{i,1}, 'dd-mm-yyyy HH:MM AM'), 'yyyy-mm-dd-HH-MM-SS'),'InputFormat','yyyy-MM-dd-HH-mm-ss');
    sleepData{i,2} = datetime(datestr(datenum(sleep_file{i,2}, 'dd-mm-yyyy HH:MM AM'), 'yyyy-mm-dd-HH-MM-SS'),'InputFormat','yyyy-MM-dd-HH-mm-ss');
end
clear i sleep_file
sleepData = sortrows(sleepData); %Sort the columns "Ascend"
%% Features of sleeptime
%1 when sleeping, 0 when awake
for i= 1:height(sleepData)
    s_s = find(data.Date==(sleepData{i,1}));
    s_e = find(data.Date==(sleepData{i,2}));
    data.sleep(s_s:s_e)=ones;
end
% Movingsum, last seven days
sleeptime = data.sleep;
data.SleepAverage = movsum(sleeptime,10080)/7/60; %In hours

%% FFT
% Fs = 100;   
% L = length(Dataset.heart(2:end));
% T = 1/Fs;
% t = (0:L-1)*T;
% f = Fs*(0:(L/2))/L;
% Y = fft(Dataset.heart(2:end));
% P2 = abs(Y/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% 
% plot(f,P1) 
% title('Single-Sided Amplitude Spectrum of S(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
% FFT_Power_spec = abs(Y);

%%
%Slope_change = diff(sign(diff(diffHeart)))~=0;
%% features for heart
window_size_1h = 60;
window_size_15m = 15;
heart = data.heart;
heart_diff = diff(heart);
heart_diff_movmax = movmax(heart_diff,window_size_1h);
heart_diff_movmean = movmean(heart_diff,window_size_1h);
heart_diff_movmin = movmin(heart_diff,window_size_1h);
heart_movmedian_1h = movmedian(heart,window_size_1h);
heart_movmean_1h = movmean(heart,window_size_1h);
heart_movmin_1h = movmin(heart,window_size_1h);
heart_movmax_1h = movmax(heart,window_size_1h);
heart_movstd_1h = movstd(heart,window_size_1h);
Date_time = hms(data.Date);
% window size 15m
heart_movmedian_15m = movmedian(heart,window_size_15m);
heart_movmean_15m = movmean(heart,window_size_15m);
heart_movmin_15m = movmin(heart,window_size_15m);
heart_movmax_15m = movmax(heart,window_size_15m);
heart_movstd_15m = movstd(heart,window_size_15m);
% delay heart features 
delay_heart_5m = delayseq(heart(2:end),5); % delay heart 5 min
delay_heart_15m = delayseq(heart(2:end),15); % delay heart 15 min
delay_heart_1h = delayseq(heart(2:end),60); % delay heart 1 hour
delay_heart_5h = delayseq(heart(2:end),300); % delay heart 5 hours
delay_heart_diff_5m = delayseq(heart_diff(2:end),5); 
delay_heart_diff_15m = delayseq(heart_diff(2:end),15);
delay_heart_diff_1h = delayseq(heart_diff(2:end),60);
delay_heart_diff_5h = delayseq(heart_diff(2:end),300);
% Moving at delay features
heart_movstd_1m_delay_5m = movstd(delay_heart_5m,1); %Tilf�jet
heart_movstd_5m_delay_15m = movstd(delay_heart_15m,5); %Tilf�jet
heart_movstd_15m_delay_1h = movstd(delay_heart_1h,15); %Tilf�jet
heart_movstd_2h_delay_5h = movstd(delay_heart_5h,120); %Tilf�jet
heart_movmean_1m_delay_5m = movmean(delay_heart_5m,1); %Tilf�jet
heart_movmean_5m_delay_15m = movmean(delay_heart_15m,5); %Tilf�jet
heart_movmean_15m_delay_1h = movmean(delay_heart_1h,15); %Tilf�jet
heart_movmean_2h_delay_5h = movmean(delay_heart_5h,120); %Tilf�jet

%% features for steps
steps = Step_Data.steps(1:end);
steps_diff = diff(steps);
steps_movmean_1h = movmean(steps,window_size_1h);
steps_movmedian_1h = movmedian(steps,window_size_1h);
steps_movmin_1h = movmin(steps,window_size_1h);
steps_movmax_1h = movmax(steps,window_size_1h);
steps_movstd_1h = movstd(steps,window_size_1h);
% window size 15m
steps_movmedian_15m = movmedian(steps,window_size_15m);
steps_movmean_15m = movmean(steps,window_size_15m);
steps_movmin_15m = movmin(steps,window_size_15m);
steps_movmax_15m = movmax(steps,window_size_15m);
steps_movstd_15m = movstd(steps,window_size_15m);
% delay step feature
delay_steps_5m = delayseq(steps,5); % delay step 5 min
delay_steps_15m = delayseq(steps,15); % delay step 15 min
delay_steps_1h = delayseq(steps,60); % delay step 1 hour
delay_steps_5h = delayseq(steps,300); % delay step 5 hours
delay_steps_diff_5m = delayseq(steps_diff(1:end),5);
delay_steps_diff_15m = delayseq(steps_diff(1:end),15);
delay_steps_diff_1h = delayseq(steps_diff(1:end),60);
delay_steps_diff_5h = delayseq(steps_diff(1:end),300);
% Moving at delay features
step_movstd_1m_delay_5m = movstd(delay_steps_5m,1); %Tilf�jet
step_movstd_5m_delay_15m = movstd(delay_steps_15m,5); %Tilf�jet
step_movstd_15m_delay_1h = movstd(delay_steps_1h,15); %Tilf�jet
step_movstd_2h_delay_5h = movstd(delay_steps_5h,120); %Tilf�jet
step_movmean_1m_delay_5m = movmean(delay_steps_5m,1); %Tilf�jet
step_movmean_5m_delay_15m = movmean(delay_steps_15m,5); %Tilf�jet
step_movmean_15m_delay_1h = movmean(delay_steps_1h,15); %Tilf�jet
step_movmean_2h_delay_5h = movmean(delay_steps_5h,120); %Tilf�jet

%% Make a table
Data_table = table(Date_time(1:end-2),heart(1:end-2),heart_diff(1:end-1), heart_diff_movmax(1:end-1),heart_diff_movmean(1:end-1),heart_diff_movmin(1:end-1),...
    heart_movmedian_1h(1:end-2),heart_movmean_1h(1:end-2),heart_movmin_1h(1:end-2),heart_movmax_1h(1:end-2),heart_movstd_1h(1:end-2),...
    delay_heart_5m(1:end-1),delay_heart_15m(1:end-1),delay_heart_1h(1:end-1),delay_heart_5h(1:end-1),...
    steps(1:end-2),steps_diff(1:end-1),...
    steps_movmean_1h(1:end-2),steps_movmedian_1h(1:end-2),steps_movmin_1h(1:end-2),steps_movmax_1h(1:end-2),steps_movstd_1h(1:end-2),...
    delay_steps_5m(1:end-2),delay_steps_15m(1:end-2),delay_steps_1h(1:end-2),delay_steps_5h(1:end-2),...
    sleeptime(1:end-2),data.SleepAverage(1:end-2),...
    delay_heart_diff_5m,delay_heart_diff_15m,delay_heart_diff_1h,delay_heart_diff_5h,...
    delay_steps_diff_5m(1:end-1),delay_steps_diff_15m(1:end-1),delay_steps_diff_1h(1:end-1),delay_steps_diff_5h(1:end-1),...
    heart_movmedian_15m(1:end-2),heart_movmean_15m(1:end-2),heart_movmin_15m(1:end-2),heart_movmax_15m(1:end-2),heart_movstd_15m(1:end-2),...
    steps_movmean_15m(1:end-2),steps_movmedian_15m(1:end-2),steps_movmin_15m(1:end-2),steps_movmax_15m(1:end-2),steps_movstd_15m(1:end-2),...
    heart_movstd_1m_delay_5m(1:end-1),heart_movstd_5m_delay_15m(1:end-1),heart_movstd_15m_delay_1h(1:end-1),heart_movstd_2h_delay_5h(1:end-1),...
    heart_movmean_1m_delay_5m(1:end-1),heart_movmean_5m_delay_15m(1:end-1),heart_movmean_15m_delay_1h(1:end-1),heart_movmean_2h_delay_5h(1:end-1),...
    step_movstd_1m_delay_5m(1:end-2),step_movstd_5m_delay_15m(1:end-2),step_movstd_15m_delay_1h(1:end-2),step_movstd_2h_delay_5h(1:end-2),...
    step_movmean_1m_delay_5m(1:end-2),step_movmean_5m_delay_15m(1:end-2),step_movmean_15m_delay_1h(1:end-2),step_movmean_2h_delay_5h(1:end-2),...
    data.headache(1:end-2));
Data_table.Properties.VariableNames{1} = 'hour';
Data_table.Properties.VariableNames{2} = 'heart';
Data_table.Properties.VariableNames{3} = 'heart_diff'; 
Data_table.Properties.VariableNames{4} = 'heart_diff_movmax'; 
Data_table.Properties.VariableNames{5} = 'heart_diff_movmean';
Data_table.Properties.VariableNames{6} = 'heart_diff_movmin'; 
Data_table.Properties.VariableNames{7} = 'heart_movmedian_1h';
Data_table.Properties.VariableNames{8} = 'heart_movmean_1h';
Data_table.Properties.VariableNames{9} = 'heart_movmin_1h';
Data_table.Properties.VariableNames{10} = 'heart_movmax_1h';
Data_table.Properties.VariableNames{11} = 'heart_movstd_1h';
Data_table.Properties.VariableNames{12} = 'delay_heart_5m'; 
Data_table.Properties.VariableNames{13} = 'delay_heart_15m';
Data_table.Properties.VariableNames{14} = 'delay_heart_1h'; 
Data_table.Properties.VariableNames{15} = 'delay_heart_5h'; 

Data_table.Properties.VariableNames{16} = 'steps';
Data_table.Properties.VariableNames{17} = 'steps_diff'; 
Data_table.Properties.VariableNames{18} = 'steps_movmean';
Data_table.Properties.VariableNames{19} = 'steps_movmedian';
Data_table.Properties.VariableNames{20} = 'steps_movmin';
Data_table.Properties.VariableNames{21} = 'steps_movmax';
Data_table.Properties.VariableNames{22} = 'steps_movstd';
Data_table.Properties.VariableNames{23} = 'delay_steps_5m'; 
Data_table.Properties.VariableNames{24} = 'delay_steps_15m';
Data_table.Properties.VariableNames{25} = 'delay_steps_1h'; 
Data_table.Properties.VariableNames{26} = 'delay_steps_5h'; 

Data_table.Properties.VariableNames{27} = 'sleeptime';
Data_table.Properties.VariableNames{28} = 'sleepaverage';

% Delay at diff features
Data_table.Properties.VariableNames{29} = 'delay_heart_diff_5m'; 
Data_table.Properties.VariableNames{30} = 'delay_heart_diff_15m';
Data_table.Properties.VariableNames{31} = 'delay_heart_diff_1h'; 
Data_table.Properties.VariableNames{32} = 'delay_heart_diff_5h'; 
Data_table.Properties.VariableNames{33} = 'delay_steps_diff_5m'; 
Data_table.Properties.VariableNames{34} = 'delay_steps_diff_15m';
Data_table.Properties.VariableNames{35} = 'delay_steps_diff_1h'; 
Data_table.Properties.VariableNames{36} = 'delay_steps_diff_5h'; 

% Window size 15m features
Data_table.Properties.VariableNames{37} = 'heart_movmedian_15m';
Data_table.Properties.VariableNames{38} = 'heart_movmean_15m';
Data_table.Properties.VariableNames{39} = 'heart_movmin_15m';
Data_table.Properties.VariableNames{40} = 'heart_movmax_15m';
Data_table.Properties.VariableNames{41} = 'heart_movstd_15m';
Data_table.Properties.VariableNames{42} = 'steps_movmean_15m';
Data_table.Properties.VariableNames{43} = 'steps_movmedian_15m';
Data_table.Properties.VariableNames{44} = 'steps_movmin_15m';
Data_table.Properties.VariableNames{45} = 'steps_movmax_15m';
Data_table.Properties.VariableNames{46} = 'steps_movstd_15m';

% Moving at delay features
% heart
Data_table.Properties.VariableNames{47} ='heart_movstd_1m_delay_5m';
Data_table.Properties.VariableNames{48} ='heart_movstd_5m_delay_15m';
Data_table.Properties.VariableNames{49} ='heart_movstd_15m_delay_1h';
Data_table.Properties.VariableNames{50} ='heart_movstd_2h_delay_5h';
Data_table.Properties.VariableNames{51} ='heart_movmean_1m_delay_5m';
Data_table.Properties.VariableNames{52} ='heart_movmean_5m_delay_15m';
Data_table.Properties.VariableNames{53} ='heart_movmean_15m_delay_1h';
Data_table.Properties.VariableNames{54} ='heart_movmean_2h_delay_5h';
% step
Data_table.Properties.VariableNames{55} ='step_movstd_1m_delay_5m';
Data_table.Properties.VariableNames{56} ='step_movstd_5m_delay_15m';
Data_table.Properties.VariableNames{57} ='step_movstd_15m_delay_1h';
Data_table.Properties.VariableNames{58} ='step_movstd_2h_delay_5h';
Data_table.Properties.VariableNames{59} ='step_movmean_1m_delay_5m';
Data_table.Properties.VariableNames{60} ='step_movmean_5m_delay_15m';
Data_table.Properties.VariableNames{61} ='step_movmean_15m_delay_1h';
Data_table.Properties.VariableNames{62} ='step_movmean_2h_delay_5h';

% Headache
Data_table.Properties.VariableNames{63} = 'headache';

% Data_table(1:5,:) =[]; % Delete the first 5 miniuts of data 
% Data_table(1:15,:) =[]; % Delete the first 15 miniuts of data 
% Data_table(1:60,:) =[]; % Delete the first 60 miniuts of data 
Data_table(1:300,:) =[]; % Delete the first 5 hours of data 
%% Remove data where subject is sleeping
Data_table(ismember(Data_table.sleeptime,1),:) = [];
%% Train and test split, when sleep is removed - Create a copy of next Section
trainSamples2 = table2array(Data_table(1:25000,1:63));
testLabelVec2 = Data_table.headache(25001:end);
testSamples2 = table2array(Data_table(25001:end,1:62));

%% splitting the data into train and test dataset
trainLabelVec = (Data_table.headache(1:45000));
trainSamples = table2array(Data_table(1:45000,1:63));
testLabelVec = Data_table.headache(45001:end);
testSamples = table2array(Data_table(45001:end,1:62)); %Her skal kolonne med headache ikke med.
%% Classify
treeModel = fitctree(trainSamples,trainLabelVec); %% using decission tree as a classifiyer 
partitionedModel = crossval(treeModel, 'KFold', 5); %% using cross validation to validate the classifiyer
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');