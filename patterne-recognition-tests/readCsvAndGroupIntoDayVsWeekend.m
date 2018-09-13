clear;close all;clc;
%% Import data
fitbitExportData = importfile('fitbit_export_20180913.xls','Activities',1,32);

%% Group data
for i = 2:size(fitbitExportData)
    dayChar = cell2mat(fitbitExportData{i,1});
    dayDatetime = datetime(dayChar,'InputFormat','dd-mm-yyyy')
    if  isweekend(dayDatetime)
        weekendData(size(weekendData),:) = fitbitExportData(i,:);
    else 
        weekdayData(size(weekdayData),:) = fitbitExportData(i,:);
    end   
end


function tableout = importfile(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE Import data from a spreadsheet
%   DATA = IMPORTFILE(FILE) reads data from the first worksheet in the
%   Microsoft Excel spreadsheet file named FILE and returns the data as a
%   table.
%
%   DATA = IMPORTFILE(FILE,SHEET) reads from the specified worksheet.
%
%   DATA = IMPORTFILE(FILE,SHEET,STARTROW,ENDROW) reads from the specified
%   worksheet for the specified row interval(s). Specify STARTROW and
%   ENDROW as a pair of scalars or vectors of matching size for
%   dis-contiguous row intervals. To read to the end of the file specify an
%   ENDROW of inf.%
% Example:
%   fitbitexport20180913 = importfile('fitbit_export_20180913.xls','Activities',1,32);
%
%   See also XLSREAD.

% Auto-generated by MATLAB on 2018/09/13 13:55:01

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    startRow = 1;
    endRow = 32;
end

%% Import the data
[~, ~, raw] = xlsread(workbookFile, sheetName, sprintf('A%d:J%d',startRow(1),endRow(1)));
for block=2:length(startRow)
    [~, ~, tmpRawBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:J%d',startRow(block),endRow(block)));
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
end
stringVectors = string(raw(:,[1,2,3,4,5,6,7,8,9,10]));
stringVectors(ismissing(stringVectors)) = '';

%% Create table
tableout = table;

%% Allocate imported array to column variable names
tableout.Date = stringVectors(:,1);
tableout.CaloriesBurned = stringVectors(:,2);
tableout.Steps = stringVectors(:,3);
tableout.Distance = stringVectors(:,4);
tableout.Floors = categorical(stringVectors(:,5));
tableout.MinutesSedentary = stringVectors(:,6);
tableout.MinutesLightlyActive = stringVectors(:,7);
tableout.MinutesFairlyActive = categorical(stringVectors(:,8));
tableout.MinutesVeryActive = categorical(stringVectors(:,9));
tableout.ActivityCalories = stringVectors(:,10);
end
