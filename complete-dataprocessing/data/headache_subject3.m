%% Headache Subject 3 - Copy to processing file

data.headache(:) = ones;
data.Properties.VariableNames{1} = 'Date';
data.Properties.VariableNames{2} = 'heart';

ha = find(data.Date==('2018-10-23-13-35-12'));
hb = find(data.Date==('2018-10-24-01-19-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-27-15-03-50'));
hb = find(data.Date==('2018-10-27-19-15-40'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-29-15-11-18'));
hb = find(data.Date==('2018-10-29-19-05-29'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-31-20-13-45'));
hb = find(data.Date==('2018-10-31-22-59-22'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-01-09-40-25'));
hb = find(data.Date==('2018-11-01-13-28-38'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-05-11-46-10'));
hb = find(data.Date==('2018-11-05-23-10-39'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-12-07-40-55'));
hb = find(data.Date==('2018-11-13-20-44-01'));
data.headache(ha:hb )=zeros;