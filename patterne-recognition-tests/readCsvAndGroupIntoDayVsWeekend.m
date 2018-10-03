clear;close all;clc;
%% Import data
fitbitExportData = importfile('Fitbit-dataset-Jacob.csv');

%% Group data
fitbitData = [];
for i = 1:size(fitbitExportData)
    dayChar = cell2mat(fitbitExportData{i,1});
    dayDatetime = datetime(dayChar,'InputFormat','yyyy-MM-dd HH-mm-ss');
    fitbitData(i-1,:) = fitbitExportData{i,vartype('string')};
    if  isweekend(dayDatetime)
        fitbitData(size(fitbitData,1),1) = 1;
    else 
        fitbitData(size(fitbitData,1),1) = 0;
    end   
end