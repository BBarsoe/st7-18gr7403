clear all
close all
clc
%%
%Dataset = importfile('Jacob_0110_0410.csv',34702,153487);
load 'Dataset.mat'
%%
%diffHeart = diff(Dataset.heart);
%MAV_Heart = movmean(Dataset.heart,1000);
%MAV_diff_Heart = movmean(abs(diffHeart),1000);
%Slope_change = diff(sign(diff(diffHeart)))~=0;
%heart_movmin = movmin(heart,300);
%heart_movmax = movmax(heart,300);
%Mov_median =movmedian(Dataset.heart,1000);
%Data_table = table(diffHeart,MAV_Heart(1:end-1),MAV_diff_Heart,Mov_min(1:end-1),Mov_max(1:end-1),Mov_median(1:end-1),Dataset.sleep(1:end-1));
heart = Dataset.heart;
heart_diff = diff(heart);
heart_diff_movmax = movmax(heart_diff,1200);
heart_diff_movmean = movmean(heart_diff,1200);
heart_diff_movmin = movmin(heart_diff,1200);
heart_median = movmedian(heart,1200);
heart_movmean = movmean(heart,1200);
heart_movmin = movmin(heart,1200);
heart_movmax = movmax(heart,1200);
Data_table = table(heart(1:end-1),heart_diff, heart_diff_movmax,heart_diff_movmean,heart_diff_movmin,heart_median(1:end-1),heart_movmean(1:end-1),heart_movmin(1:end-1),heart_movmax(1:end-1),Dataset.sleep(1:end-1));
Data_table.Properties.VariableNames{1} = 'heart';
Data_table.Properties.VariableNames{6} = 'heart_median';
Data_table.Properties.VariableNames{7} = 'heart_movmean';
Data_table.Properties.VariableNames{8} = 'heart_movmin';
Data_table.Properties.VariableNames{9} = 'heart_movmax';
Data_table.Properties.VariableNames{10} = 'sleep';