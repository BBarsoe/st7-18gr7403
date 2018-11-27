function urineOutput = urineOutput(heartrate,fluidBalance)
urineMaxPrDay = 4000;
urineMinPrDay = 500;
urineMax = dayToMinute(urineMaxPrDay);
urineMin = dayToMinute(urineMinPrDay);

if isnan(heartrate)|| isnan(fluidBalance)
    urineOutput = (fluidBalance*0.75+urineMinPrDay)/24/60;
    return;
end
if heartrate > 110
    urineOutput = (fluidBalance*0.25+urineMinPrDay)/24/60;
    if fluidBalance < 0
        urineOutput = urineMin;
    end
    if urineOutput > urineMax
        urineOutput = urineMax;
    end
else
    urineOutput = (fluidBalance*0.75+urineMinPrDay)/24/60;
    if fluidBalance < 0
        urineOutput = urineMin;
    end
    if urineOutput > urineMax
        urineOutput = urineMax;
    end
end