%% ILARA-TEORIAKO TAULAK SORTZEKO SCRIPT FINAL-FINALA

% 1. ERRENKADAK: Anbulantzia erabilgarrien kopurua (c)
c_kopuruak = [12; 15; 20; 30; 50]; 
Errenkada_Kop = length(c_kopuruak);

% 2. ZUTABEAK: iritsiera eta okupazio denborak erabilita

% A) ZERBITZU GUTXI (Gaua: Astelehena, 02:00 - 04:00)
lambda_gaua = 60 / 11.87;  % Iritsierak orduko
mu_gaua     = 60 / 30.5;   % Zerbitzuak orduko

% B) ZERBITZU ERTAINAK (Arratsaldea: Osteguna, 16:00 - 18:00)
lambda_arratsalde = 60 / 3.246; 
mu_arratsalde     = 60 / 19.46; 

% C) ZERBITZU ASKO (Goiza: Asteazkena, 12:00 - 14:00)
lambda_goiza = 60 / 2.09; 
mu_goiza     = 60 / 22.96;


okupazio_matrizea = zeros(Errenkada_Kop, 3); 
itxaron_matrizea  = zeros(Errenkada_Kop, 3); 

for i = 1:Errenkada_Kop
    c_uneko = c_kopuruak(i);
    
    % A) GAUEKO TARTEA
    rho_gaua = lambda_gaua / (c_uneko * mu_gaua);
    if rho_gaua < 1
        n_gaua = kalkulatuMMc(c_uneko, lambda_gaua, mu_gaua);
        okupazio_matrizea(i, 1) = n_gaua.rho * 100; 
        itxaron_matrizea(i, 1)  = n_gaua.Wq * 60;   
    else
        okupazio_matrizea(i, 1) = NaN; itxaron_matrizea(i, 1) = NaN;
    end
    
    % B) ARRATSALDEKO TARTEA
    rho_arratsalde = lambda_arratsalde / (c_uneko * mu_arratsalde);
    if rho_arratsalde < 1
        n_arratsalde = kalkulatuMMc(c_uneko, lambda_arratsalde, mu_arratsalde);
        okupazio_matrizea(i, 2) = n_arratsalde.rho * 100;
        itxaron_matrizea(i, 2)  = n_arratsalde.Wq * 60;
    else
        okupazio_matrizea(i, 2) = NaN; itxaron_matrizea(i, 2) = NaN;
    end
    
    % C) GOIZEKO TARTEA
    rho_goiza = lambda_goiza / (c_uneko * mu_goiza);
    if rho_goiza < 1
        n_goiza = kalkulatuMMc(c_uneko, lambda_goiza, mu_goiza);
        okupazio_matrizea(i, 3) = n_goiza.rho * 100;
        itxaron_matrizea(i, 3)  = n_goiza.Wq * 60;
    else
        okupazio_matrizea(i, 3) = NaN; itxaron_matrizea(i, 3) = NaN;
    end
end


Taula_Okupazioa = table(c_kopuruak, okupazio_matrizea(:,1), okupazio_matrizea(:,2), okupazio_matrizea(:,3), ...
    'VariableNames', {'Anbulantziak_c', 'Gaua_Baxua_NaN', 'Arratsaldea_27_58', 'Goiza_22_96'})


Taula_Itxaron_Denbora = table(c_kopuruak, itxaron_matrizea(:,1), itxaron_matrizea(:,2), itxaron_matrizea(:,3), ...
    'VariableNames', {'Anbulantziak_c', 'Gaua_Baxua_NaN', 'Arratsaldea_27_58', 'Goiza_22_96'})