clear;close all;clc;
%% Import data
fitbitExportData = importfile('Fitbit-dataset-Jacob.csv');
heartRate = fitbitExportData{:,2};
dateTime = fitbitExportData{:,1};

%% Create features
heartRateDerivative = diff(heartRate);

% Wave lenght
windowSize = 300; %Seconds
startIndex = 1;
resultSize = [ceil(seconds(dateTime(end) - dateTime(1)) / 300) 2];
resultVariables = {'double','datetime'};
result = table('Size',resultSize,'VariableTypes',resultVariables);
totalTime = 0;
pointLength = 0;
tmpResult1 = zeros(ceil(seconds(dateTime(end) - dateTime(1)) / 300),1);
tmpResult2 = datetime;

for index = 1:size(heartRateDerivative)-1
    %number of seconds between current dateTime and the next
    tmp = diff([dateTime(index) dateTime(index+1)]); 
    % Convert the diffTime to a 'double' value from a 'duration' value
    timeDiff = seconds(tmp); clear tmp;
    %values diff between current heartRateDerivative value and the next
    %heartRateDerivative value
    heartRateDiff = diff([heartRateDerivative(index) heartRateDerivative(index+1)]);
    %the length bewteen the two points
    pointLength = pointLength + norm([heartRateDiff timeDiff]);
    totalTime = totalTime + timeDiff;
    if totalTime/windowSize >= 1
        tmpResult1(startIndex,1) = pointLength;
        tmpResult2(startIndex,1) = dateTime(index);
        pointLength = 0;
        startIndex = startIndex + 1;
        totalTime = totalTime-windowSize;
    end
end
result = table(tmpResult1(1:end-1),tmpResult2);

%% Plot data
subplot(2,1,1)
plot(dateTime(1:end-1),heartRateDerivative);
hold on;
plot(dateTime,heartRate);
subplot(2,1,2)
plot(tmpResult2,tmpResult1(1:end-1))
