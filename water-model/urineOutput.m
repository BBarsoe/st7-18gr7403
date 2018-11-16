function urineOutput = urineOutput(heartrate,fluidBalance)
urineMax
urineMin = 500;
if heartrate > 110
    urineOutput = (fluidBalance*0.25+urineMin)/24/60;
    if fluidBalance < 0
        urineOutput = urineMin;
    end
    if urineOutput > urineMax
        urineOutput = urineMax;
    end
else
    urineOutput = (fluidBalance*0.75+urineMin)/24/60;
    if fluidBalance < 0
        urineOutput = urineMin;
    end
    if urineOutput > urineMax
        urineOutput = urineMax;
    end
end