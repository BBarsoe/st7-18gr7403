% clear;clc;close all;
%Jacob_dataset = importfile('Fitbit-dataset-Jacob.csv',1,393683);
[minute_number,minutes_time] = discretize(Jacob_dataset.Date,'minute');
minutes_time = minutes_time';
Jacob_dataset.minute = minute_number;
 G = findgroups(Jacob_dataset.minute);
 heartsplit = splitapply(@mean,Jacob_dataset.heart,G);
 
k = 1;
tmp = 0;
lasttime = 2;
data = table(minutes_time,zeros(17280,1));
for i = 2:10000
    
    if(minutes_time(k)>Jacob_dataset.Date(i))
        tmp = Jacob_dataset.heart(i)+tmp;
    else
            data{k,2} = tmp/(i-lasttime);
            tmp = Jacob_dataset.heart(i);
            k = k+1;
            lasttime = i;
    end
end