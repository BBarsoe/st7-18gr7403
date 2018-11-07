 clear all
 close all
 clc
 %% Load heart data
imported_dataset = importfile('female_data_heart.csv',2,500000);%Importerer datasættet der bruges
imported_dataset.Properties.VariableNames{1} = 'Date';%Sørger for at kolonnerne har variabelnavne til scriptet
imported_dataset.Properties.VariableNames{2} = 'heart';
[minute_number1,minutes_time1] = discretize(imported_dataset.Date(1:400000),'minute');%Inddeler data i minut intervaller
[minute_number2,minutes_time2] = discretize(imported_dataset.Date(400001:end),'minute');%Inddeler data i minut intervaller
minutes_time1 = minutes_time1';%Vender matricen fra 1 række til 1 kolonne
minutes_time2 = minutes_time2';%Vender matricen fra 1 række til 1 kolonne
minute_number = [minute_number1;minute_number2];
minutes_time = [minutes_time1;minutes_time2];
%imported_dataset.minute = minute_number; Ved ikke lige hvorfor den her er der
G = findgroups(minute_number);%Grupperer heart data i minutter
heartsplit = splitapply(@mean,imported_dataset.heart,G);%gns heart pr. minut

k = 1;
tmp = 0;
lasttime = 2;
data = table(minutes_time,zeros(length(minutes_time),1));%Laver en matrice med minutter og nuller
for i = 2:height(imported_dataset)%Hele datasættet uden NaN på række 1
    
    if (minutes_time(k) >= imported_dataset.Date(i))%Hvis tiden er lavere end optællingsminuttet
        tmp = imported_dataset.heart(i)+tmp;%Lægger heart sammen med tidligere tal
        
    elseif (imported_dataset.Date(i) > minutes_time(k)+minutes(1))%Hvis der er mere end 1 minut mellem datapunkter
        while (imported_dataset.Date(i) > minutes_time(k)+minutes(1))
            tmp = imported_dataset.heart(i);
            k = k+1;%Tæller k op uden at inkrementere i så vi ikke kommer ud af sync
            lasttime = i;%Så der ikke divideres med den tidligere i (fra if->elseif)
        end
    else
        data{k,2} = tmp/(i-lasttime);%Tager gns af minuttets datapunkter
        tmp = imported_dataset.heart(i);%Nulstiller tmp til nuværende heart
        k = k+1;%Øger tællingsminuttet
        lasttime = i;%Nulstiller nævneren
    end
end
%% load step data
Step_Data = importfile('female_data_steps.csv',2,70561);
Step_Data.Properties.VariableNames{1} = 'Date';%Sørger for at kolonnerne har variabelnavne til scriptet
Step_Data.Properties.VariableNames{2} = 'steps';
%Dataset = importfile('Erik_dataset.csv',1,135762);
%Dataset = importfile('Jacob_0110_0410.csv',34702,153487);
%load 'Dataset.mat'
%% adding headache

data.Properties.VariableNames{1} = 'Date';
data.Properties.VariableNames{2} = 'heart';

ha = find(data.Date==('2018-09-14-14-00-00'));
hb = find(data.Date==('2018-09-14-15-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-09-15-18-00-00'));
hb = find(data.Date==('2018-09-15-22-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-09-19-19-00-00'));
hb = find(data.Date==('2018-09-19-22-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-09-21-16-30-00'));
hb = find(data.Date==('2018-09-21-22-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-09-24-09-00-00'));
hb = find(data.Date==('2018-09-24-22-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-09-27-09-00-00'));
hb = find(data.Date==('2018-09-27-22-00-00'));
data.headache(ha:hb )=ones;


ha = find(data.Date==('2018-09-28-05-30-00'));
hb = find(data.Date==('2018-09-28-07-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-10-03-10-00-00'));
hb = find(data.Date==('2018-10-03-15-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-10-07-19-00-00'));
hb = find(data.Date==('2018-10-07-20-00-00'));
data.headache(ha:hb )=ones;


ha = find(data.Date==('2018-10-10-18-00-00'));
hb = find(data.Date==('2018-10-10-21-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-10-11-20-00-00'));
hb = find(data.Date==('2018-10-11-22-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-10-13-08-00-00'));
hb = find(data.Date==('2018-10-13-19-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-10-15-17-30-00'));
hb = find(data.Date==('2018-10-15-20-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-10-19-10-00-00'));
hb = find(data.Date==('2018-10-19-16-00-00'));
data.headache(ha:hb )=ones;

ha = find(data.Date==('2018-10-31-18-30-00'));
hb = find(data.Date==('2018-10-31-19-30-00'));
data.headache(ha:hb )=ones;

data(62093,:) = [];%Slet overlap mellem de to minutes_time
data(62094,:) = [];

table_heart_step = table(data.Date,data.heart,Step_Data.steps,data.headache);
table_heart_step.Properties.VariableNames{1} = 'Date';
table_heart_step.Properties.VariableNames{2} = 'heart';
table_heart_step.Properties.VariableNames{3} = 'steps';
table_heart_step.Properties.VariableNames{4} = 'headache';
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
window_size = 60;
heart = data.heart;
heart_diff = diff(heart);
heart_diff_movmax = movmax(heart_diff,window_size);
heart_diff_movmean = movmean(heart_diff,window_size);
heart_diff_movmin = movmin(heart_diff,window_size);
heart_median = movmedian(heart,window_size);
heart_movmean = movmean(heart,window_size);
heart_movmin = movmin(heart,window_size);
heart_movmax = movmax(heart,window_size);
heart_movstd = movstd(heart,window_size);
Date_time = hms(data.Date);
% delay heart features
delay_heart_data = delayseq(heart,15); % delay heart 15 min 

%% features for steps
steps = Step_Data.steps(1:end);
steps_diff = diff(steps); %Tilføjet
steps_movmean = movmean(steps,window_size);
steps_movmedian = movmedian(steps,window_size); %Tilføjet
steps_movmin = movmin(steps,window_size);
steps_movmax = movmax(steps,window_size);
steps_movstd = movstd(steps,window_size);
% delay step feature
delay_steps_data = delayseq(steps,15); % delay step 15 min
%% Make a table
Data_table = table(Date_time(1:end-1),heart(1:end-1),heart_diff, heart_diff_movmax,heart_diff_movmean,heart_diff_movmin,heart_median(1:end-1),heart_movmean(1:end-1),heart_movmin(1:end-1),heart_movmax(1:end-1),heart_movstd(1:end-1),steps(1:end-1),steps_diff,steps_movmean(1:end-1),steps_movmedian(1:end-1),steps_movmin(1:end-1),steps_movmax(1:end-1),steps_movstd(1:end-1),data.headache(1:end-1));
Data_table.Properties.VariableNames{1} = 'hour';
Data_table.Properties.VariableNames{2} = 'heart';
Data_table.Properties.VariableNames{7} = 'heart_median';
Data_table.Properties.VariableNames{8} = 'heart_movmean';
Data_table.Properties.VariableNames{9} = 'heart_movmin';
Data_table.Properties.VariableNames{10} = 'heart_movmax';
Data_table.Properties.VariableNames{11} = 'heart_movstd';
Data_table.Properties.VariableNames{12} = 'steps';
Data_table.Properties.VariableNames{14} = 'steps_movmean';
Data_table.Properties.VariableNames{15} = 'steps_movmedian'; %Tilføjet
Data_table.Properties.VariableNames{16} = 'steps_movmin';
Data_table.Properties.VariableNames{17} = 'steps_movmax';
Data_table.Properties.VariableNames{18} = 'steps_movstd';
Data_table.Properties.VariableNames{19} = 'headache';
%% splitting the data into train and test dataset
trainLabelVec = (Data_table.headache(1:35000));
trainSamples = table2array(Data_table(1:35000,1:16));
testLabelVec = Data_table.headache(35001:end);
testSamples = table2array(Data_table(35001:end,1:16));
%% Classify
treeModel = fitctree(trainSamples,trainLabelVec); %% using decission tree as a classifiyer 
partitionedModel = crossval(treeModel, 'KFold', 5); %% using cross validation to validate the classifiyer
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');