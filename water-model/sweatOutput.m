function sweatOutput = sweatOutput(heartrate,fluidBalance)
if gender == female
    if fluidBalance > 0
        if heartrate > 140
            sweatOutput = (2200)/60;
%Ved ikke hvad v�rdien skal v�re for moderat tr�ning vs intens.
%Har set meget forskelligt. Har kilder p� de steder jeg har l�st, men der
%er forskelle mellem personer og mellem m�linger.            
        elseif (110 < heartrate) && (heartrate < 140)
            sweatOutput = 600/60;
        else
            sweatOutput = 100/24/60;
        end
    else
        if heartrate > 140
            sweatOutput = (1800)/60;
        elseif (110 < heartrate) && (heartrate < 140)
            sweatOutput = 500/60;
        else
            sweatOutput = 100/24/60;
        end
    end
else
    if fluidBalance > 0
        if heartrate > 140
            sweatOutput = (2700)/60;
        elseif (110 < heartrate) && (heartrate < 140)
            sweatOutput = 1100/60;
        else
            sweatOutput = 100/24/60;
        end
    else
        if heartrate > 140
            sweatOutput = (2200)/60;
        elseif (110 < heartrate) && (heartrate < 140)
            sweatOutput = 900/60;
        else
            sweatOutput = 100/24/60;
        end
    end
end