%% Analisi Demografikoa: Populazioa vs Eskaria (λ)

herri = readtable('poblacionesBizkaia.xlsx'); 

%Identifikatu zerbitzuak jatorriaren arabera
zerbitzuak_herrika = groupsummary(T, 'jatorria_id');
n_zerbitzuak=sum(zerbitzuak_herrika.GroupCount);


%Jatorri berdina duten taulen errenkadak konbinatu
herri = renamevars(herri, 'id_poblacion','jatorria_id'); %aldatu zutabaren izena ondoren innerjoin erabiltzeko
analisi_demografikoa = innerjoin(zerbitzuak_herrika, herri, 'Keys', 'jatorria_id');


%Populazioaren eta eskariaren arteko Pearsonen korrelazioa
korrelazioa = corrcoef(analisi_demografikoa.GroupCount, analisi_demografikoa.numhabitantes);
korrelazioa(1,2); % Populazioaren eta eskariaren arteko Pearsonen korrelazioa (r=0.0225)


%% 1. GRAFIKOA: Eskala Lineal Erreala
% Datu errealak
figure('Name', 'Korrelazio Demografiko Erreala');
scatter(analisi_demografikoa.numhabitantes, analisi_demografikoa.GroupCount, 70, 'filled', ...
        'MarkerFaceColor', [0 0.4470 0.7410], 'MarkerEdgeColor', 'k');
xlabel('Udalerriko Biztanleak (Eskala Lineala)', 'FontSize', 11);
ylabel('Asteko Dei Kopurua (Eskala Lineala)', 'FontSize', 11);
title('Eskariaren eta Populazioaren Arteko Erlazio Lineala Bizkaian', 'FontSize', 12, 'FontWeight', 'bold');
grid on;


%% 2. GRAFIKOA: Eskala Logaritmikoa Izenekin
figure('Name', 'Korrelazio Demografiko Logaritmikoa Izenekin'); 

%Bi aldagaien logaritmoa kalkulatu hobeto ikusteko grafikoa
log_pop = log10(analisi_demografikoa.numhabitantes);
log_zerbitzuak = log10(analisi_demografikoa.GroupCount);

%Marraztu puntuak eskala logaritmikoan
scatter(log_pop, log_zerbitzuak, 70, 'filled', ...
    'MarkerFaceColor', [0 0.4470 0.7410], 'MarkerEdgeColor', 'k');
hold on;

%Erregresio lerroa logaritmoekin
p_log = polyfit(log_pop, log_zerbitzuak, 1);
x_lerroa_log = linspace(min(log_pop), max(log_pop), 100);
y_lerroa_log = polyval(p_log, x_lerroa_log);
plot(x_lerroa_log, y_lerroa_log, 'r-', 'LineWidth', 2);

%Herrien izenak idatzi grafikoan
for i = 1:height(analisi_demografikoa)
     text(log_pop(i) + 0.03, log_zerbitzuak(i), analisi_demografikoa.nombrepob{i}, ...
         'FontSize', 6, ...
         'FontWeight', 'bold', ...
         'Color', [0.2 0.2 0.2]); 
end

xlabel('Udalerriko Biztanleak (Eskala Logaritmikoan, log_{10})', 'FontSize', 11);
ylabel('Asteko Dei Kopurua (Eskala Logaritmikoan, log_{10})', 'FontSize', 11);
title('Eskariaren eta Populazioaren Arteko Erlazioa', 'FontSize', 12, 'FontWeight', 'bold');
legend('Udalerriak', 'Joera Lerro Logaritmikoa', 'Location', 'NorthWest');
grid on;
hold off;