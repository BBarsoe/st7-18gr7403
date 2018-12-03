%% making a list of all days in the dataset
TT2 = timetable(featuresData.hour,featuresData.heart);
Days = retime(TT2,'daily');
%% making a variable of all days on form dd-MM-uuuu
All_dates = datetime(Days.Time,'Format','dd-MMM-uuuu');
All_dates = All_dates';
%% selecting one day randomly from x numbers of 7 days perioeds
k=1;
for i=1:round(length(All_dates)/7)
    if (((length(All_dates)-k)< 7))
        dates_to_validations_set(i,:) = All_dates(1,(randi([k length(All_dates)],1)));
    end
    if (k==1)
        dates_to_validations_set(i,:) = All_dates(1,(randi([k (k+6)],1)));
        k=8; 
    end
    if (((length(All_dates)-k)>6) && i>1)
       dates_to_validations_set(i,:) = All_dates(1,(randi([k (k+6)],1)));
       k=k+7; 
    end
end
%% extrating data from featuresData to validation set based on days randomly picked in dates_to_validations_set
k=1;
for i=1:(length(dates_to_validations_set))
    for j=1:length(featuresData.hour)
        if (day(dates_to_validations_set(i,1),'dayofyear') == day(featuresData.hour(j),'dayofyear'))
            validation_set(k,:) = table(featuresData.hour(j),featuresData.heart(j),featuresData.heart_diff(j),...
                featuresData.heart_diff_movmax(j),featuresData.heart_diff_movmean(j),featuresData.heart_diff_movmin(j),...
                featuresData.heart_movmedian_1h(j),featuresData.heart_movmean_1h(j),featuresData.heart_movmin_1h(j),...
                featuresData.heart_movmax_1h(j),featuresData.heart_movstd_1h(j),featuresData.delay_heart_5m(j),...
                featuresData.delay_heart_15m(j),featuresData.delay_heart_1h(j),featuresData.delay_heart_5h(j),...
                featuresData.steps(j),featuresData.steps_diff(j),featuresData.steps_movmean(j),featuresData.steps_movmedian(j),...
                featuresData.steps_movmin(j),featuresData.steps_movmax(j),featuresData.steps_movstd(j),...
                featuresData.delay_steps_5m(j),featuresData.delay_steps_15m(j),featuresData.delay_steps_1h(j),...
                featuresData.delay_steps_5h(j),featuresData.sleeptime(j),featuresData.sleepaverage(j),...
                featuresData.delay_heart_diff_5m(j),featuresData.delay_heart_diff_15m(j),featuresData.delay_heart_diff_1h(j),...
                featuresData.delay_heart_diff_5h(j),featuresData.delay_steps_diff_5m(j),featuresData.delay_steps_diff_15m(j),...
                featuresData.delay_steps_diff_1h(j),featuresData.delay_steps_diff_5h(j),featuresData.heart_movmedian_15m(j),...
                featuresData.heart_movmean_15m(j),featuresData.heart_movmin_15m(j),featuresData.heart_movmax_15m(j),...
                featuresData.heart_movstd_15m(j),featuresData.steps_movmean_15m(j),featuresData.steps_movmedian_15m(j),...
                featuresData.steps_movmin_15m(j),featuresData.steps_movmax_15m(j),featuresData.steps_movstd_15m(j),...
                featuresData.heart_movstd_1m_delay_5m(j),featuresData.heart_movstd_5m_delay_15m(j),...
                featuresData.heart_movstd_15m_delay_1h(j),featuresData.heart_movstd_2h_delay_5h(j),...
                featuresData.heart_movmean_1m_delay_5m(j),featuresData.heart_movmean_5m_delay_15m(j),...
                featuresData.heart_movmean_15m_delay_1h(j),...
                featuresData.heart_movmean_2h_delay_5h(j),featuresData.step_movstd_1m_delay_5m(j),...
                featuresData.step_movstd_5m_delay_15m(j),featuresData.step_movstd_15m_delay_1h(j),...
                featuresData.step_movstd_2h_delay_5h(j),featuresData.step_movmean_1m_delay_5m(j),...
                featuresData.step_movmean_5m_delay_15m(j),featuresData.step_movmean_15m_delay_1h(j),...
                featuresData.step_movmean_2h_delay_5h(j),featuresData.fluidmodel(j),featuresData.headache(j));
            row_number(k,1) = j;
            k=k+1;
        end
    end
        
end
%%
validation_set.Properties.VariableNames{1} = 'hour';
validation_set.Properties.VariableNames{2} = 'heart';
validation_set.Properties.VariableNames{3} = 'heart_diff'; 
validation_set.Properties.VariableNames{4} = 'heart_diff_movmax'; 
validation_set.Properties.VariableNames{5} = 'heart_diff_movmean';
validation_set.Properties.VariableNames{6} = 'heart_diff_movmin'; 
validation_set.Properties.VariableNames{7} = 'heart_movmedian_1h';
validation_set.Properties.VariableNames{8} = 'heart_movmean_1h';
validation_set.Properties.VariableNames{9} = 'heart_movmin_1h';
validation_set.Properties.VariableNames{10} = 'heart_movmax_1h';
validation_set.Properties.VariableNames{11} = 'heart_movstd_1h';
validation_set.Properties.VariableNames{12} = 'delay_heart_5m'; 
validation_set.Properties.VariableNames{13} = 'delay_heart_15m';
validation_set.Properties.VariableNames{14} = 'delay_heart_1h'; 
validation_set.Properties.VariableNames{15} = 'delay_heart_5h'; 

validation_set.Properties.VariableNames{16} = 'steps';
validation_set.Properties.VariableNames{17} = 'steps_diff'; 
validation_set.Properties.VariableNames{18} = 'steps_movmean';
validation_set.Properties.VariableNames{19} = 'steps_movmedian';
validation_set.Properties.VariableNames{20} = 'steps_movmin';
validation_set.Properties.VariableNames{21} = 'steps_movmax';
validation_set.Properties.VariableNames{22} = 'steps_movstd';
validation_set.Properties.VariableNames{23} = 'delay_steps_5m'; 
validation_set.Properties.VariableNames{24} = 'delay_steps_15m';
validation_set.Properties.VariableNames{25} = 'delay_steps_1h'; 
validation_set.Properties.VariableNames{26} = 'delay_steps_5h'; 

validation_set.Properties.VariableNames{27} = 'sleeptime';
validation_set.Properties.VariableNames{28} = 'sleepaverage';

% Delay at diff features
validation_set.Properties.VariableNames{29} = 'delay_heart_diff_5m'; 
validation_set.Properties.VariableNames{30} = 'delay_heart_diff_15m';
validation_set.Properties.VariableNames{31} = 'delay_heart_diff_1h'; 
validation_set.Properties.VariableNames{32} = 'delay_heart_diff_5h'; 
validation_set.Properties.VariableNames{33} = 'delay_steps_diff_5m'; 
validation_set.Properties.VariableNames{34} = 'delay_steps_diff_15m';
validation_set.Properties.VariableNames{35} = 'delay_steps_diff_1h'; 
validation_set.Properties.VariableNames{36} = 'delay_steps_diff_5h'; 

% Window size 15m features
validation_set.Properties.VariableNames{37} = 'heart_movmedian_15m';
validation_set.Properties.VariableNames{38} = 'heart_movmean_15m';
validation_set.Properties.VariableNames{39} = 'heart_movmin_15m';
validation_set.Properties.VariableNames{40} = 'heart_movmax_15m';
validation_set.Properties.VariableNames{41} = 'heart_movstd_15m';
validation_set.Properties.VariableNames{42} = 'steps_movmean_15m';
validation_set.Properties.VariableNames{43} = 'steps_movmedian_15m';
validation_set.Properties.VariableNames{44} = 'steps_movmin_15m';
validation_set.Properties.VariableNames{45} = 'steps_movmax_15m';
validation_set.Properties.VariableNames{46} = 'steps_movstd_15m';

% Moving at delay features
% heart
validation_set.Properties.VariableNames{47} ='heart_movstd_1m_delay_5m';
validation_set.Properties.VariableNames{48} ='heart_movstd_5m_delay_15m';
validation_set.Properties.VariableNames{49} ='heart_movstd_15m_delay_1h';
validation_set.Properties.VariableNames{50} ='heart_movstd_2h_delay_5h';
validation_set.Properties.VariableNames{51} ='heart_movmean_1m_delay_5m';
validation_set.Properties.VariableNames{52} ='heart_movmean_5m_delay_15m';
validation_set.Properties.VariableNames{53} ='heart_movmean_15m_delay_1h';
validation_set.Properties.VariableNames{54} ='heart_movmean_2h_delay_5h';
% step
validation_set.Properties.VariableNames{55} ='step_movstd_1m_delay_5m';
validation_set.Properties.VariableNames{56} ='step_movstd_5m_delay_15m';
validation_set.Properties.VariableNames{57} ='step_movstd_15m_delay_1h';
validation_set.Properties.VariableNames{58} ='step_movstd_2h_delay_5h';
validation_set.Properties.VariableNames{59} ='step_movmean_1m_delay_5m';
validation_set.Properties.VariableNames{60} ='step_movmean_5m_delay_15m';
validation_set.Properties.VariableNames{61} ='step_movmean_15m_delay_1h';
validation_set.Properties.VariableNames{62} ='step_movmean_2h_delay_5h';
validation_set.Properties.VariableNames{63} ='fluidmodel';
% Headache
validation_set.Properties.VariableNames{64} = 'headache';
%% Delete valdiation data from featuresData
row_number = flip(row_number);  
for i=1:length(row_number)
    featuresData(row_number(i),:) = [];
end
%% Splitting featuresData into training and test 
[m,n] = size(featuresData) ;
P = 0.70 ; % train = 70% of data and test = 30%
idx = randperm(m)  ; % scrambling the data
Training = featuresData(idx(1:round(P*m)),:) ;
Testing = featuresData(idx(round(P*m)+1:end),:) ;

%%
% clearvars -except  

