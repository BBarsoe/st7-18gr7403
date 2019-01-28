function res = awakeness(i,sleepingAverageData,rawSleep)
minutesPerDay = 1440;
now = sleepingAverageData.timestamp(1) + minutes(i);
minutesSleeptPerDay = minutes(rawSleep.wakeTime - rawSleep.bedTime);
timeSinceWakeTime = minutes(now - rawSleep.wakeTime);
timeSinceWakeTimePast48Hours = ceil(timeSinceWakeTime(timeSinceWakeTime < (2 * minutesPerDay) & timeSinceWakeTime > 0));
minutesSleeptPast48Hours = ceil(minutesSleeptPerDay(timeSinceWakeTime < (2 * minutesPerDay) & timeSinceWakeTime > 0));
window = gausswin(4 * minutesPerDay);
window(1:2880) = '';
res = sum((minutesSleeptPast48Hours.* window(timeSinceWakeTimePast48Hours))/60);
end