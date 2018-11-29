%% Headache Subject 3 - Copy to processing file

data.headache(:) = ones;
data.Properties.VariableNames{1} = 'Date';
data.Properties.VariableNames{2} = 'heart';

ha = find(data.Date==('2018-10-23-13-35-00'));
hb = find(data.Date==('2018-10-24-01-19-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-27-15-03-00'));
hb = find(data.Date==('2018-10-27-19-15-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-29-15-11-00'));
hb = find(data.Date==('2018-10-29-19-05-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-31-20-13-00'));
hb = find(data.Date==('2018-10-31-22-59-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-01-09-40-00'));
hb = find(data.Date==('2018-11-01-13-28-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-05-11-46-00'));
hb = find(data.Date==('2018-11-05-23-10-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-12-07-40-00'));
hb = find(data.Date==('2018-11-13-20-44-00'));
data.headache(ha:hb )=zeros;