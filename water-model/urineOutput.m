% Kan ikke huske hvor jeg har brugt hvilke kilder. Den første er for hydreret/ikke hydreret, men ved ikke med de to andre. 
%https://www.ics.org/Abstracts/Publish/40/000043.pdf
%https://www-physiology-org.zorac.aub.aau.dk/doi/pdf/10.1152/jappl.1956.8.6.621
%https://rcni.com/sites/rcn_nspace/files/ns2008.07.22.47.50.c6634.pdf
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