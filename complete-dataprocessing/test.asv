clear; close all; clc;
res = [1:94462];
a = zeros(94462,1);
load testSleepData.mat
for i = 1:length(res)
   a(i) = myfunc(res(i)-1,sleepingAverageData,rawSleep);
end

function awakeness = myfunc(i,sleepingAverageData,rawSleep)
minutesPerDay = 1440;
now = sleepingAverageData.timestamp(1) + minutes(i);
minutesSleeptPerDay = minutes(rawSleep.wakeTime - rawSleep.bedTime);
timeSinceWakeTime = minutes(now - rawSleep.wakeTime);
timeSinceWakeTimePast48Hours = timeSinceWakeTime(timeSinceWakeTime < (2 * minutesPerDay) & timeSinceWakeTime > 0);
minutesSleeptPast48Hours = minutesSleeptPerDay(timeSinceWakeTime < (2 * minutesPerDay) & timeSinceWakeTime > 0);
window = gausswin(4 * minutesPerDay);
window(1:2880) = '';
awakeness = sum((minutesSleeptPast48Hours.* window(timeSinceWakeTimePast48Hours))/60);
end