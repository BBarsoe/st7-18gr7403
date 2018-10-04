clear;close all;clc;
%% Import data
fitbitExportData = importfile('Fitbit-dataset-Jacob.csv');
heartRate = fitbitExportData{:,2};
dateTime = fitbitExportData{:,1};

%% Create features
heartRateDerivative = diff(heartRate);

%% Wave lenght
windowSize = 300; %Seconds
startIndex = 1;
totalTime = 0;
pointLength = 0;
tmpResult1 = zeros(ceil(seconds(dateTime(end) - dateTime(1)) / windowSize),1);
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
    %the total time of current window
    totalTime = totalTime + timeDiff;
    % If more than 300 seconds has been calculated
    if totalTime/windowSize >= 1
        %Save the current wavelenght
        tmpResult1(startIndex,1) = pointLength;
        %Save the current timestamp
        tmpResult2(startIndex,1) = dateTime(index);
        %reset the wavelenght
        pointLength = 0;
        %increment the index for saving the wavelenghts
        startIndex = startIndex + 1;
        %Save the overflowed time
        totalTime = totalTime-windowSize;
    end
end
%creates a table with the results
waveLength = table(tmpResult1(1:end-1),tmpResult2);
clear windowSize startIndex totalTime pointLength tmpResult1 tmpResult2 timeDiff heartRateDiff;

%% Slope Sign Change
heartRateSlopeChange = logical(heartRateDerivative);
heartRateSlopeChange_2 = SlopeSignChange(heartRateDerivative);

%% Mean absolute value
heartRateMovAbsMean = movmean(abs(heartRateDerivative),[1000 0]);

%% Mean values trailing
heartRateMovMean = movmean(heartRateDerivative,[1000 0]);

%% Plot data
subplot(2,2,1)
plot(dateTime(1:end-1),heartRateDerivative);
hold on;
plot(dateTime,heartRate);

subplot(2,2,2)
plot(waveLength{:,2},waveLength{:,1})

subplot(2,2,3)
plot(dateTime(1:end-1),heartRateSlopeChange)

subplot(2,2,4)
plot(dateTime(1:end-1),heartRateMovMean)


%% Slope sign change function
function ssc = SlopeSignChange(x)
ssc=0;
for i=2:length(x)-1;
temp = sign((x(i)-x(i-1)) * (x(i)-x(i+1)));
    if temp > 0
        ssc = ssc + 1;
    end
end
end