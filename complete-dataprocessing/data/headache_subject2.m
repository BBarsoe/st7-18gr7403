%% Headache Subject 2 - Copy to processing file

data.headache(:) = ones;
data.Properties.VariableNames{1} = 'Date';
data.Properties.VariableNames{2} = 'heart';

ha = find(data.Date==('2018-09-22-08-00-00'));
hb = find(data.Date==('2018-09-22-09-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-09-24-13-00-00'));
hb = find(data.Date==('2018-09-24-14-30-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-09-28-07-00-00'));
hb = find(data.Date==('2018-09-28-22-30-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-09-30-15-30-00'));
hb = find(data.Date==('2018-09-30-22-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-10-01-07-00-00'));
hb = find(data.Date==('2018-10-01-10-30-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-10-08-00-00'));
hb = find(data.Date==('2018-11-10-09-00-00'));
data.headache(ha:hb )=zeros;

ha = find(data.Date==('2018-11-16-07-00-00'));
hb = find(data.Date==('2018-11-16-16-00-00'));
data.headache(ha:hb )=zeros;
