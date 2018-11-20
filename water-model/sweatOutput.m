function sweatOutput = sweatOutput(heartrate,fluidBalance)
%Ved ikke hvad værdien skal være for moderat træning vs intens.
%Har set meget forskelligt. Har kilder på de steder jeg har læst, men der
%er forskelle mellem personer og mellem målinger.
if gender == female
    if fluidBalance > 0
        if heartrate > 170
            sweatOutput = (1925)/60;%(2700*(475/800)+2700*(1000/1200))/2 for at finde gennemsnit af maks for kvinder ift mænd.
        elseif (140 < heartrate) && (heartrate < 170)
            sweatOutput = 1000/60;%https://link.springer.com/article/10.1007%2Fs00421-007-0636-z
        elseif (110 < heartrate) && (heartrate < 140)
            sweatOutput = 475/60;%https://link.springer.com/content/pdf/10.1007%2Fs004210050676.pdf(y)
        elseif heartrate < 110
            sweatOutput = 100/24/60;%https://rcni.com/sites/rcn_nspace/files/ns2008.07.22.47.50.c6634.pdf
        end
    elseif fluidBalance < 0
        %https://www.physiology.org/doi/pdf/10.1152/jappl.1956.8.6.621
        %Kilden har en ratio på 11/9 mellem dem der bliver hydreret og dem
        %der ikke bliver.
        if heartrate > 170
            sweatOutput = (1575)/60;
        elseif (140 < heartrate) && (heartrate < 170)
            sweatOutput = 820/60;
        elseif (110 < heartrate) && (heartrate < 140)
            sweatOutput = 390/60;
        elseif heartrate < 110
            sweatOutput = 100/24/60;%https://rcni.com/sites/rcn_nspace/files/ns2008.07.22.47.50.c6634.pdf
        end
    end
elseif gender == male
    if fluidBalance > 0
        if heartrate > 170
            sweatOutput = (2700)/60;%https://www.researchgate.net/publication/275648096_Sweat_rate_and_fluid_intake_in_young_elite_basketball_players_on_the_FIBA_Europe_U20_Championship
        elseif (140 < heartrate) && (heartrate < 170)
            sweatOutput = 1200/60;%https://link.springer.com/article/10.1007%2Fs00421-007-0636-z
        elseif (110 < heartrate) && (heartrate < 140)
            sweatOutput = 800/60;%https://link.springer.com/content/pdf/10.1007%2Fs004210050676.pdf(y)
        elseif heartrate < 110
            sweatOutput = 100/24/60;%https://rcni.com/sites/rcn_nspace/files/ns2008.07.22.47.50.c6634.pdf
        end
    elseif fluidBalance < 0
        %https://www.physiology.org/doi/pdf/10.1152/jappl.1956.8.6.621
        %Kilden har en ratio på 11/9 mellem dem der bliver hydreret og dem
        %der ikke bliver.
        if heartrate > 140
            sweatOutput = (2210)/60;
        elseif (110 < heartrate) && (heartrate < 140)
            sweatOutput = 980/60;
        elseif (110 < heartrate) && (heartrate < 140)
            sweatOutput = 655/60;
        elseif heartrate < 110
            sweatOutput = 100/24/60;%https://rcni.com/sites/rcn_nspace/files/ns2008.07.22.47.50.c6634.pdf
        end
    end
end