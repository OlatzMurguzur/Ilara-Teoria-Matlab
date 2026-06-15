%% POISSON/ESPONENTZIAL BANAKETAREN EGIAZTAPENA
% Estatistikoen ataleko 'T_iritsierak' taulatik abiatuko gara, NaN baliorik gabe

% Aztertu nahi den egun eta ordu tarte zehatza: Astelehena, 12:00
egun_zehatza = 'Tue'; 
tarte_zehatza = 12; 

%Identifikatu tarte horretako datu guztiak
datu_iragaziak = T_iritsierak(T_iritsierak.asteko_eguna == egun_zehatza & T_iritsierak.ordu_tartea == tarte_zehatza, :);

%Iritsieren arteko denborak (minututan) - estatistikoak ataletik
itxaron_denborak = datu_iragaziak.inter_iritsiera_min;

if length(itxaron_denborak) > 5
    figure('Name', 'Poisson Prozesuaren Egiaztapena');

    %Histograma normalizatuta
    histogram(itxaron_denborak, 'Normalization', 'pdf', 'FaceColor', '#4DBBD5', 'EdgeColor', 'w'); 
    %'pdf' probability density function
    %esponentzialaren joera hobeto ikusteko, maiztasunak erakutsi ordez
    hold on;

    %Kurba esponentzial teorikoa  (1/batez besteko denbora)
    lambda_estimatua = 1 / mean(itxaron_denborak);
    x_ardatza = linspace(0, max(itxaron_denborak), 100);
    y_teorikoa = lambda_estimatua * exp(-lambda_estimatua * x_ardatza);

    plot(x_ardatza, y_teorikoa, 'r-', 'LineWidth', 2.5);

    title(sprintf('Iritsieren Egiaztapena: %s (%d:00 - %d:00)', string(egun_zehatza), tarte_zehatza, tarte_zehatza+2));
    xlabel('Joan-etorrien arteko denbora (Minutuak)');
    ylabel('Dentsitate Probabilitatea');
    legend('Simulazioko datu errealak', 'Banaketa Esponentzial Teorikoa');
    grid on;
    hold off;
else
    disp('Ez dago nahiko datu tarte honetan grafikoa egiteko.');
end


%% BISUALIZAZIO BATERATUA: ORDU TARTE GUZTIAK GRAFIKO BEREAN

%Talde bakoitzaren (eguna + ordu tartea) batez besteko denbora 
talde_batesbestekoak = groupsummary(T_iritsierak, {'asteko_eguna', 'ordu_tartea'}, 'mean', 'inter_iritsiera_min');

%Jatorrizko taula eta batez besteko berriak elkartu errenkada bakoitzari bere tarteko mu zerbitzu-tasa esleitzeko
T_normalizatua = join(T_iritsierak, talde_batesbestekoak, 'Keys', {'asteko_eguna', 'ordu_tartea'});

%Datuak normalizatu: (T_i zati \mu_tartea)
%Normalizazio honeki tarte guztiek ezaugarri bera izatea lortzen da (Batezbestekoa = 1, \lambda = 1)
T_normalizatua.inter_iritsiera_norm = T_normalizatua.inter_iritsiera_min ./ T_normalizatua.mean_inter_iritsiera_min;

%Grafikoa 
figure('Name', 'Iritsieren Egiaztapena (Ordu Tarte eta Egun Guztiak)');

%Tarte guztien datu normalizatuak histograma bakarrean irudikatu
histogram(T_normalizatua.inter_iritsiera_norm, 'Normalization', 'pdf', 'BinWidth', 0.15, 'FaceColor', '#0072BD', 'EdgeColor', 'w');
hold on;

%Banaketa Esponentziala lambda = 1 izanik
x_ardatza = linspace(0, max(T_normalizatua.inter_iritsiera_norm), 200);
y_teorikoa = exp(-x_ardatza);

plot(x_ardatza, y_teorikoa, 'r-', 'LineWidth', 2.5);

title('Iritsieren Egiaztapena (Ordu Tarte eta Egun Guztiak)');
xlabel('Iritsieren arteko denbora normalizatua (t / \mu_{tartea})');
ylabel('Dentsitate Probabilitatea');
legend('Simulazioko tarte guztiak (bateratuta)', 'Banaketa Esponentzial Estandarra (\lambda = 1)');
grid on;
xlim([0, 5]); 
hold off;