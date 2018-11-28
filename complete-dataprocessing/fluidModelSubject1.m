function result = fluidModelSubject1()
%% Adding paths
addpath(genpath('data'));
addpath(genpath('water-model'));
%% Load data
if isfile("data/rawDataSubject1.mat")
    load("data/rawDataSubject1.mat");
else
    rawData = importfile('data/subject1.xlsx');
    rawSteps = table(rawData{~isnat(rawData{:,1}),1}, rawData{~isnan(rawData{:,2}),2});
    rawHeart = table(rawData{~isnat(rawData{:,3}),3}, rawData{~isnan(rawData{:,4}),4});
    rawSleep = table(rawData{~isnat(rawData{:,5}),5}, rawData{~isnat(rawData{:,6}),6});
    rawFluid = table(rawData{~isnat(rawData{:,7}),7}, rawData{~isnan(rawData{:,8}),8});
    clear rawData;
    save('data/rawDataSubject1.mat','rawSteps','rawHeart','rawSleep','rawFluid');
end
%% Run model
gender = "female";
result = fluidModel(rawSleep,rawFluid,rawHeart,gender);
end