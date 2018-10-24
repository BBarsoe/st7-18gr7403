clear all
close all
clc
%% Load data

imported_dataset = importfile('Heart_2009-0110_Jacob.csv',1,393684);%Importerer datasættet der bruges
imported_dataset.Properties.VariableNames{1} = 'Date';%Sørger for at kolonnerne har variabelnavne til scriptet
imported_dataset.Properties.VariableNames{2} = 'heart';
[minute_number,minutes_time] = discretize(imported_dataset.Date,'minute');%Inddeler data i minut intervaller
minutes_time = minutes_time';%Vender matricen fra 1 række til 1 kolonne
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

Step_Data = importSteps('Step_2009-0110_Jacob.xlsx',1,17281);
%Dataset = importfile('Erik_dataset.csv',1,135762);
%Dataset = importfile('Jacob_0110_0410.csv',34702,153487);
%load 'Dataset.mat'
%% adding sleep

data.Properties.VariableNames{1} = 'Date';
data.Properties.VariableNames{2} = 'heart';

ha = find(data.Date==('2018-09-20-00-00-00'));
hb = find(data.Date==('2018-09-20-07-40-00'));
data.sleep(ha:hb )=ones;

ha = find(data.Date==('2018-09-20-23-37-00'));
hb = find(data.Date==('2018-09-21-07-08-00'));
data.sleep(ha:hb )=ones;

ha = find(data.Date==('2018-09-22-00-14-00'));
hb = find(data.Date==('2018-09-22-07-52-00'));
data.sleep(ha:hb )=ones;

ha = find(data.Date==('2018-09-23-00-40-00'));
hb = find(data.Date==('2018-09-23-09-22-00'));
data.sleep(ha:hb )=ones;

ha = find(data.Date==('2018-09-23-23-27-00'));
hb = find(data.Date==('2018-09-24-07-04-00'));
data.sleep(ha:hb )=ones;

ha = find(data.Date==('2018-09-24-23-10-00'));
hb = find(data.Date==('2018-09-25-06-58-00'));
data.sleep(ha:hb )=ones;


ha = find(data.Date==('2018-09-25-23-14-00'));
hb = find(data.Date==('2018-09-26-04-52-00'));
data.sleep(ha:hb )=ones;

ha = find(data.Date==('2018-09-26-23-23-00'));
hb = find(data.Date==('2018-09-27-07-06-00'));
data.sleep(ha:hb )=ones;

ha = find(data.Date==('2018-09-27-23-33-00'));
hb = find(data.Date==('2018-09-28-07-01-00'));
data.sleep(ha:hb )=ones;


ha = find(data.Date==('2018-09-28-23-25-00'));
hb = find(data.Date==('2018-09-29-09-52-00'));
data.sleep(ha:hb )=ones;

ha = find(data.Date==('2018-09-30-00-59-00'));
hb = find(data.Date==('2018-09-30-09-11-00'));
data.sleep(ha:hb )=ones;

ha = find(data.Date==('2018-09-30-22-31-00'));
hb = find(data.Date==('2018-10-01-06-59-00'));
data.sleep(ha:hb )=ones;

table_heart_step = table(data.Date,data.heart,Step_Data.steps,data.sleep);
table_heart_step.Properties.VariableNames{1} = 'Date';
table_heart_step.Properties.VariableNames{2} = 'heart';
table_heart_step.Properties.VariableNames{3} = 'steps';
table_heart_step.Properties.VariableNames{4} = 'sleep';
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
heart = data.heart;
heart_diff = diff(heart);
heart_diff_movmax = movmax(heart_diff,60);
heart_diff_movmean = movmean(heart_diff,60);
heart_diff_movmin = movmin(heart_diff,60);
heart_median = movmedian(heart,60);
heart_movmean = movmean(heart,60);
heart_movmin = movmin(heart,60);
heart_movmax = movmax(heart,60);
heart_movstd = movstd(heart,60);
Date_time = hms(data.Date);

%% features for steps
steps = Step_Data.steps(1:17280);
steps_movmean = movmean(steps,60);
steps_movmin = movmin(steps,60);
steps_movmax = movmax(steps,60);
steps_movstd = movstd(steps,60);
%% Make a table
Data_table = table(Date_time(1:end-1),heart(1:end-1),heart_diff, heart_diff_movmax,heart_diff_movmean,heart_diff_movmin,heart_median(1:end-1),heart_movmean(1:end-1),heart_movmin(1:end-1),heart_movmax(1:end-1),heart_movstd(1:end-1),steps(1:end-1),steps_movmean(1:end-1),steps_movmin(1:end-1),steps_movmax(1:end-1),steps_movstd(1:end-1),data.sleep(1:end-1));
Data_table.Properties.VariableNames{1} = 'hour';
Data_table.Properties.VariableNames{2} = 'heart';
Data_table.Properties.VariableNames{7} = 'heart_median';
Data_table.Properties.VariableNames{8} = 'heart_movmean';
Data_table.Properties.VariableNames{9} = 'heart_movmin';
Data_table.Properties.VariableNames{10} = 'heart_movmax';
Data_table.Properties.VariableNames{11} = 'heart_movstd';
Data_table.Properties.VariableNames{12} = 'steps';
Data_table.Properties.VariableNames{13} = 'steps_movmean';
Data_table.Properties.VariableNames{14} = 'steps_movmin';
Data_table.Properties.VariableNames{15} = 'steps_movmax';
Data_table.Properties.VariableNames{16} = 'steps_movstd';
Data_table.Properties.VariableNames{17} = 'sleep';
