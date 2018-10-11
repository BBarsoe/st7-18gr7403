clear;clc;close all;
imported_dataset = importfile('Fitbit-dataset-Jacob.csv',1,393683);%Importerer datas�ttet der bruges
imported_dataset.Properties.VariableNames{1} = 'Date';%S�rger for at kolonnerne har variabelnavne til scriptet
imported_dataset.Properties.VariableNames{2} = 'heart';
[minute_number,minutes_time] = discretize(imported_dataset.Date,'minute');%Inddeler data i minut intervaller
minutes_time = minutes_time';%Vender matricen fra 1 r�kke til 1 kolonne
%imported_dataset.minute = minute_number; Ved ikke lige hvorfor den her er der
G = findgroups(minute_number);%Grupperer heart data i minutter
heartsplit = splitapply(@mean,imported_dataset.heart,G);%gns heart pr. minut

k = 1;
tmp = 0;
lasttime = 2;
data = table(minutes_time,zeros(length(minutes_time),1));%Laver en matrice med minutter og nuller
for i = 2:height(imported_dataset)%Hele datas�ttet uden NaN p� r�kke 1
    
    if (minutes_time(k) >= imported_dataset.Date(i))%Hvis tiden er lavere end opt�llingsminuttet
        tmp = imported_dataset.heart(i)+tmp;%L�gger heart sammen med tidligere tal
        
    elseif (imported_dataset.Date(i) > minutes_time(k)+minutes(1))%Hvis der er mere end 1 minut mellem datapunkter
        while (imported_dataset.Date(i) > minutes_time(k)+minutes(1))
            tmp = imported_dataset.heart(i);
            k = k+1;%T�ller k op uden at inkrementere i s� vi ikke kommer ud af sync
            lasttime = i;%S� der ikke divideres med den tidligere i (fra if->elseif)
        end
    else
        data{k,2} = tmp/(i-lasttime);%Tager gns af minuttets datapunkter
        tmp = imported_dataset.heart(i);%Nulstiller tmp til nuv�rende heart
        k = k+1;%�ger t�llingsminuttet
        lasttime = i;%Nulstiller n�vneren
    end
end