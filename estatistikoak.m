%% ESTATISTIKOAK
%1. Ibilgailuen batez besteko okupazio-denbora metatua (behar duten tokira iristen direnetik helmugara iristen diren arte), ordu-tarte eta asteko egun bakoitzeko.

T = readtable('zerbitzuen_banaketa_osoa.xlsx');
T = T(T.hora_disponible ~= duration(0,0,0), :);
T.data = datetime(T.data);

%Kalkuluak egiteko orduak 'duration' motara bihurtu
T.hora_recogida = duration(T.hora_recogida);
T.hora_llegada = duration(T.hora_llegada);

%Okupazio-denbora minututan: (Helmuga ordua - Jasotze ordua)
T.okupazio_denbora = minutes(T.hora_llegada - T.hora_recogida);

[~, egunak] = weekday(T.data); %weekday funtzioa erabiliz (1=Igandea, 2=Astelehena... 7=Larunbata)
ordena_kronologikoa = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
T.asteko_eguna = categorical(string(egunak),ordena_kronologikoa);


%Ordu-tarteak sortu (2 ordukoak: 0-2, 2-4, ..., 22-24)
orduak = hours(T.hora_recogida); 
T.ordu_tartea = floor(orduak / 2) * 2;
T.ordu_tartea(T.ordu_tartea == 24) = 22;

%groupsummary erabiliko dugu batez bestekoak lortzeko
emaitzak_okupazioa = groupsummary(T, {'asteko_eguna', 'ordu_tartea'}, 'mean', 'okupazio_denbora');

%Zutabeei izen argiak jarri
emaitzak_okupazioa.Properties.VariableNames{'mean_okupazio_denbora'} = 'BatezBesteko_Okupazioa_Min';


%Datuak matrize formatura pasatu heatmap bat egiteko
%Taula "unstack" egin eguna zutabeetan jartzeko
grafiko_taula = unstack(emaitzak_okupazioa(:, {'asteko_eguna', 'ordu_tartea', 'BatezBesteko_Okupazioa_Min'}), ...
    'BatezBesteko_Okupazioa_Min', 'asteko_eguna');

figure('Name', 'Ibilgailuen Okupazio Denbora');
h = heatmap(emaitzak_okupazioa, 'asteko_eguna', 'ordu_tartea', 'ColorVariable', 'BatezBesteko_Okupazioa_Min');
h.Title = 'Ibilgailuen Batez Besteko Okupazio Denbora (Minutuak)';
h.XLabel = 'Asteko Eguna';
h.YLabel = 'Ordu Tartea (Hasiera ordua)';

% Emaitzak bistaratu
%head(emaitzak_okupazioa)

T_okupazioa = T;



%% 2. Ondoz ondoko bi joan-etorriren batez besteko denbora, ordu-tarte bakoitzeko eta asteko egun bakoitzeko.

T.timestamp = T.data(:) + T.hora_recogida(:);

%KRONOLOGIKOKI ORDENATU ETA DIFERENTZIAK KALKULATU
% Garrantzitsua: ondoz ondokoak izateko, denboran ordenatuta egon behar dute
T = sortrows(T, 'timestamp');

%Zerbitzuen arteko denbora kalkulatu (minututan)
%diff funtzioak ondoz ondoko balioen arteko aldea ematen du
iritsiera_denborak = diff(T.timestamp); 

%Diferentziak taulan sartu (lehenengo zerbitzuari NaN bat jarriko diogu, ez baitu aurrekorik)
T.inter_iritsiera_min = [NaN; minutes(iritsiera_denborak)];


%ANALISI ESTATISTIKOA (Batez bestekoa)
%Kendu NaN balioa duen lehenengo errenkada batez bestekoa kalkulatzeko
T_garbia = T(~isnan(T.inter_iritsiera_min), :);

emaitzak_iritsiera = groupsummary(T_garbia, {'asteko_eguna', 'ordu_tartea'}, 'mean', 'inter_iritsiera_min');

%Zutabe izen argia jarri
emaitzak_iritsiera.Properties.VariableNames{'mean_inter_iritsiera_min'} = 'BatezBesteko_Iritsiera_Min';

%EMAITZAK ERAKUTSI
head(emaitzak_iritsiera)

%Heatmap 
figure('Name', 'Iritsieren arteko Batez Besteko Denbora (Minutuak)');
h = heatmap(emaitzak_iritsiera, 'asteko_eguna', 'ordu_tartea', 'ColorVariable', 'BatezBesteko_Iritsiera_Min');
h.Title = 'Iritsieren arteko Batez Besteko Denbora (Minutuak)';
h.XLabel = 'Asteko Eguna';
h.YLabel = 'Ordu Tartea';


T_iritsierak=T;

%% 3. Joan-etorrien kopuruaren batezbestekoa eta desbideratze tipikoa, ordu-tarte eta egun bakoitzeko.

%Ordu tarte bakoitzeko zerbiztu kopurua zenbatu
%'GroupCount' zutabeak emango digu hori
kopuru_taula = groupsummary(T, {'asteko_eguna', 'ordu_tartea'});

%Batazebestekoa eta desbideratze tipikoa: 
emaitzak_kopurua = groupsummary(kopuru_taula, {'asteko_eguna', 'ordu_tartea'}, ...
    {'mean', 'std'}, 'GroupCount');

%Zutabeei izen argiak jarri
emaitzak_kopurua.Properties.VariableNames{'mean_GroupCount'} = 'Batezbesteko_Kopurua';
emaitzak_kopurua.Properties.VariableNames{'std_GroupCount'} = 'Desbideratze_Tipikoa';

%Hasierako 10 estatistikoak ikusteko: 
%head(emaitzak_kopurua, 10)

%Heatmap: Batezbesteko kopurua ordu-tarteka
figure('Name', 'Zerbitzu Kopuruaren Batezbestekoa');
h = heatmap(emaitzak_kopurua, 'asteko_eguna', 'ordu_tartea', 'ColorVariable', 'Batezbesteko_Kopurua');
h.Title = 'Zerbitzu Kopuruaren Batezbestekoa';
h.XLabel = 'Eguna'; h.YLabel = 'Ordu Tartea';

%% 4. Lekualdatze bakoitzaren joan-etorrien batez bestekoa eta desbideratze tipikoa.

T.mota = categorical(T.mota(:)); %Lekualdatze mota: Herri-Hosp edo Hosp-Hosp 

%Batezbestekoa eta despideratze tipikoa
%groupsummary erabiliz, mota bakoitzeko estatistikoak lortzen ditugu
estatistikak_mota = groupsummary(T, 'mota', {'mean', 'std'}, 'okupazio_denbora');

%Zutabeei izen argiak jarri 
estatistikak_mota.Properties.VariableNames{'mean_okupazio_denbora'} = 'Batezbesteko_Iraupena_Min';
estatistikak_mota.Properties.VariableNames{'std_okupazio_denbora'} = 'Desbideratze_Tipikoa_Min';

%Emaitzak ikusteko: 
%disp(estatistikak_mota);

%Histograma bat sortu banaketa ikusteko (Ilara-teoriarako garrantzitsua)
figure('Name', 'Zerbitzu-denboren(S) Banaketa Estatistikoa');
histogram(T.okupazio_denbora, 'Normalization', 'pdf');
title('Zerbitzu-denboren (S) Banaketa Estatistikoa');
xlabel('Iraupena (minutuak)'); ylabel('Probabilitatea');
grid on;


%% 5. Lekualdatze bakoitzaren kilometroen batez bestekoa eta desbideratze tipikoa.

km_matrizea = readtable('kilometroguztiak.xlsx', 'ReadRowNames', true, 'VariableNamingRule', 'preserve');

n = height(T);
zerbitzu_km = zeros(n, 1);

for i = 1:n
    %Jatorria eta helmuga testu gisa lortu
    jatorria = string(T.jatorria_id{i});
    helmuga = string(T.helmuga_id{i});
    
    balioa = km_matrizea{jatorria, helmuga};
    zerbitzu_km(i) = str2double(string(balioa));  %Lortutako balioa zenbaki bihurtu
end

%Taulan gorde zutabe moduan
T.km = zerbitzu_km(:);

%Ziurtatu 'mota' categorical dela multzokatzeko
T.mota = categorical(string(T.mota(:)));

%Batezbestekoa eta desbideratze tipikoa
km_estatistikak = groupsummary(T, 'mota', {'mean', 'std'}, 'km');

%Zutabeei izen argiak jarri
km_estatistikak.Properties.VariableNames{'mean_km'} = 'Batezbesteko_KM';
km_estatistikak.Properties.VariableNames{'std_km'} = 'Desbideratze_Tipikoa_KM';

%disp(km_estatistikak);

%Histograma
figure('Name','Distantzien Banaketa (KM)' );
histogram(T.km, 'FaceColor', '#D95319');
title('Distantzien Banaketa (KM)');
xlabel('Kilometroak'); ylabel('Maiztasuna');
grid on;

T_km=T;
