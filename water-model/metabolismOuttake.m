function metabolismOuttake = metabolismOuttake()
urineMax
urineMin = 500;
if heartrate > 110
    metabolismOuttake = (fluidBalance*0.25+urineMin)/24/60;
    if fluidBalance < 0
        metabolismOuttake = urineMin;
    end
    if metabolismOuttake > urineMax
        metabolismOuttake = urineMax;
    end
else
    metabolismOuttake = (fluidBalance*0.75+urineMin)/24/60;
    if fluidBalance < 0
        metabolismOuttake = urineMin;
    end
    if metabolismOuttake > urineMax
        metabolismOuttake = urineMax;
    end
end