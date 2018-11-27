clear; close all; clc;
%% Load data
if isfile("rawDataSubject1.mat")
    load("rawDataSubject1.mat");
else 
    rawSleep = importSleepData('fitbit_sleep_jacob.xls');
    rawFluid = importFluidData('fluid_jacob.xlsx'); 
    rawHeart = importHeartRate('female_data_heart.csv',2,444978);
    save('rawDataSubject1.mat','rawSleep','rawHeart','rawFluid');
end
%% Run model
subject1 = fluidModel(rawSleep,rawFluid,rawHeart);