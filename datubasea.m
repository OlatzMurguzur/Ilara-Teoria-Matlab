%% %% DATU BASEA

%% DISTANTZIAK
kilometroak = string(readcell('kilometroguztiak.xlsx'));
kilometroak = kilometroak(2:31,22:end);
minutuak = string(readcell('minutuguztiak.xlsx'));
minutuak = minutuak(2:31,22:end);

hosp = readcell('Hospital.xlsx'); 
herri = readcell('poblacionesBizkaia.xlsx');


% Jatorriak (20 herri, 10 hospitale)
herriak=herri(2:end,1);
hospitaleak=hosp(2:end,1);
jatorriak_id = string([herriak;hospitaleak]');
jatorriak_id=repelem(jatorriak_id, 10)';
% Helmugak (10 hospitale)
helmugak_id = string(hospitaleak');
helmugak_id = repmat(helmugak_id,1,30)';

% Datuak eskurartu
km=[];
minut=[];

for i=1:30
    km=[km,kilometroak(i,:)];
    minut=[minut,minutuak(i,:)];
end

km=km';
minut=minut';

%Taula 
distantziak = table(jatorriak_id, helmugak_id, km, minut);

%Hasierako 10 erregistroak ikusi
%head(distantziak, 10)

%writetable(distantziak, 'distantziak.xlsx');

%% ANBULANTZIEN DATU BASEA
n = 50; % Anbulantzia kopurua
rng(1); % Hazia zehaztu emaitzak ez aldatzeko

%1. Definitu id_anbulantzia (gako nagusia)
id_anbulantzia = (1:n)';

%2. Zehaztu matrikula 
letrak = char(65 + randi([0, 25], [n, 3])); % ASCII kodean 65->'A',...,90->'Z'
zenbakiak = randi([0, 9], [n, 4]); 
matrikula = string(zeros(n,1));
for i = 1:n
    matrikula(i) = sprintf('%d%d%d%d%s', zenbakiak(i,1), zenbakiak(i,2), zenbakiak(i,3), zenbakiak(i,4), letrak(i,:));
end

%3. Urtea (2015 eta 2025 artean)
urtea = randi([2015, 2025], [n, 1]);


%4. Anbulantzia mota (soporte_vital o traslado_pacientes)
mota_posibleak = {'soporte_vital', 'traslado_pacientes'};
mota = mota_posibleak(randi([1, 2], [n, 1]))';

% Taula:
anbulantziak = table(id_anbulantzia, matrikula, urtea, mota);% +fecha_revision, km_revision

% Hasierako 10 erregistroak ikusteko
%head(anbulantziak, 10);
%writetable(anbulantziak, 'anbulantziak.xlsx')


%% LANGILEEN DATU BASEA
gidari_kop = 50;
sanitario_kop = 50;
guztira = gidari_kop + sanitario_kop;
rng(1); 

%1. Gako nagusiak
id_langilea = (1:guztira)';

%2. Zehaztu langile bakoitzaren izen deiturak
%Horretarako izen-abizen zerrenda bat sortuz hauek konbinatuko ditugu
izenak = {'Jon', 'Ane', 'Mikel', 'Sara', 'Asier', 'Maite', 'Peru', 'Olatz', 'Eneko', 'Maddi', 'Gorka', 'Naia', 'Beñat', 'Joane', 'Ander', 'Irene'};
abizenak = {'Ugarte', 'Guridi', 'Zubia', 'Garcia', 'Etxeberria', 'Agirre', 'Azurmendi', 'Murua', 'Urrutia', 'Aranguren', 'Zabala', 'Goikoetxea', 'Aranburu', 'Zubizarreta', 'Barrenetxea', 'Ormaetxea'};

izenabizen = string(zeros(guztira, 1));
for i = 1:guztira
    izen_id = randi(length(izenak));
    abizen_id = randi(length(abizenak));
    izenabizen(i) = sprintf('%s %s', izenak{izen_id}, abizenak{abizen_id});
end

%3. Alta data
alta_zaharrena = datetime(1983, 1, 1);
alta_berriena = datetime(2023,1,1);
tartekoegunak = days(alta_berriena - alta_zaharrena);
alta_data = alta_zaharrena + days(randi(tartekoegunak, [guztira, 1]));
alta_data.Format = 'dd-MMM-yyyy';

%4. Zehaztu mota (50 "G" y 50 "S")
%Nahastu 50 G-rekin eta beste 50 S-rekin osatutako bektorea langile mota
%zehazteko
mota = [repmat("G", gidari_kop, 1); repmat("S", sanitario_kop, 1)];
mota = mota(randperm(guztira));

% Taula: 
langileak = table(id_langilea, izenabizen, alta_data, mota); 

%head(langileak, 10)
%writetable(langileak, 'langileak.xlsx')

%% LAN TXANDAK
langileak = readtable("langileak.xlsx");
langileak.mota=categorical(langileak.mota); %aurrerago == erabili ahal izateko

%Datuak
datak = datetime(2025, 1, 13) + days(0:6); % 2025eko urtarrilak 13(astelehena)-tik 19(igandea)-ra
txanda_posibleak = {'Goiz', 'Arratsalde', 'Gau'};
%egoera = {'Aktibo', 'Atseden','Oporretan', 'Baja', 'Exzedentzia'};
gidari_id = langileak.id_langilea(langileak.mota == 'G');
sanitario_id = langileak.id_langilea(langileak.mota == 'S');

%5 gidari eta 5 sanitario txanda gabe, oporretan 
gidari_oporretan = gidari_id(randperm(length(gidari_id), 5));
sanitario_oporretan = sanitario_id(randperm(length(sanitario_id), 5));
oporretan = [gidari_oporretan; sanitario_oporretan];

%Txanden taula
lantxandak = table();

for i = 1:height(langileak)
    id = langileak.id_langilea(i);
    txanda_langileko = table(); %langile bakoitzaren txanden taula
    txanda_langileko.id_langile = repmat(id, 7, 1);
    txanda_langileko.eguna = datak';
    mota=langileak.mota(i);
    txanda_langileko.postua = repmat(mota, 7, 1);

    
    if ismember(id, oporretan) %Oporretan
        txanda_langileko.txanda = repmat({'Inaktibo'}, 7, 1);
        txanda_langileko.egoera = repmat({'Oporretan'}, 7, 1);
    
    else %5 Aktibo y 2 Atseden
        atseden_egunak = randperm(7, 2);
        egoera = repmat({'Aktibo'}, 7, 1);
        egoera(atseden_egunak) = {'Atsedena'};
        egoera=categorical(egoera);

        
        txandak = cell(7, 1);
        for j = 1:7
            if egoera(j) == 'Aktibo'
                txandak{j} = txanda_posibleak{randi(3)};
            else
                txandak{j} ='Inaktibo';
            end
        end
        txanda_langileko.txanda = txandak;
        txanda_langileko.egoera = egoera;
    end
    lantxandak = [lantxandak; txanda_langileko];
end

%head(lantxandak,10)
%writetable(lantxandak, 'lantxandak.xlsx');


%% ZERBITZUEN BANAKETA
rng(1);
hosp = readcell('Hospital.xlsx'); 
herri = readcell('poblacionesBizkaia.xlsx');

%Jatorri eta helmugak (10 hospitale eta 20 herri)
jatorri_kop = 30;
helmuga_kop = 30;

datak = datetime(2025, 1, 13) + days(0:6);

zerbitzu_kop=[200,200,200,200,200,80,60]; 
zerbitzu_taula=table();

a=0;
for j=1:7
    zerbitzua_id=(a+1:a+zerbitzu_kop(j))';
    jatorria_id = strings(zerbitzu_kop(j), 1);
    helmuga_id = strings(zerbitzu_kop(j), 1);
    jatorria_PK=strings(zerbitzu_kop(j), 1);
    helmuga_PK=strings(zerbitzu_kop(j), 1);
    mota=strings(zerbitzu_kop(j),1);
    data=repelem(datak(j),zerbitzu_kop(j))';
    emergentzia=strings(zerbitzu_kop(j),1);

    
    for i = 1:zerbitzu_kop(j)
        %Jakinda lekualdatzeen %98 ospitale eta herri artekoa (prob. 0,98) dela 
        % eta %2 hospitalen artekoa (probabilitatea 0.02), lekualdatze mota zehaztuko dugu. 
        p = rand; %[0,1] arteko balioa sortu
        
        if p <= 0.02
            mota(i) = "Hosp<->Hosp";
            %Aukeratu ausaz bi ospitale (guztira 10 hosp)
            hosp1 = randi(10) + 1; %taulan 1.errenkada izenburuak dira
            hosp2 = randi(10) + 1;
            while hosp1 == hosp2 %ospitale berdina ez izateko
                hosp2 = randi(10) + 1; 
            end 
            
            jatorria_id(i) = string(hosp{hosp1, 1});
            helmuga_id(i) = string(hosp{hosp2, 1});
            jatorria_PK(i) = hosp{hosp1, 5};
            helmuga_PK(i) = hosp{hosp2, 5};
        else
            mota(i) = "Herri<->Hosp"; 
            q = rand;
            if q <= 0.5 %Herri (20) -> Hosp (10)
                herri1 = randi(20) + 1;
                hosp2 = randi(10) + 1;
                
                jatorria_id(i) = string(herri{herri1, 1});
                helmuga_id(i) = string(hosp{hosp2, 1});
                jatorria_PK(i) = herri{herri1, 3};
                helmuga_PK(i) = hosp{hosp2, 5};
            else  %Hosp (20) -> Herri (10)
                hosp1 = randi(10) + 1;
                herri2 = randi(20) + 1;
                
                jatorria_id(i) = string(hosp{hosp1, 1});
                helmuga_id(i) = string(herri{herri2, 1});
                jatorria_PK(i) = hosp{hosp1, 5};
                helmuga_PK(i) = herri{herri2, 3};
            end
        end
        p=rand;
        if p>=0.25
            emergentzia(i)= 'Trasladua';
            kostua(i)= 1060;
    
        else
            q=rand;
            if q>=0.2 
                emergentzia(i)='Urgentzia';
                kostua(i)=357;
            else
                emergentzia(i)='Larrialdia/UVI';
                kostua(i)=582;
            end
        end
    
    end
    a=a+zerbitzu_kop(j);
    taulaberria = table(zerbitzua_id, data, jatorria_id, helmuga_id, mota,emergentzia);
    zerbitzu_taula=[zerbitzu_taula; taulaberria];

end


zerbitzu_kop = [200,200,200,200,200,80,60];  %Asteko bolumena
banaketak = [1.1, 0.5, 0.0, 0.5, 6.1, 19.5, 26.4, 13.9, 16.6, 8.6, 5.7, 1.1] / 100;
tarte_hasiera = 0:2:22;

%Eguneko tasak kalkulatu (λ_tarte = eguneko_kopurua * tarteko_pisua / 2 ordu)
%Honek matrize bat sortuko du: [7 egun x 12 tarte]
tasak_astea = (zerbitzu_kop' * banaketak) / 2; 
%Asteko egun bakoitzeko ordu tarte bakoitzean batazbeste izango diren zerbitzu kopurua


zerbitzu_guztiak = table(); 
clear min

zerbitzu_index = 1;
for egun_idx = 1:7
    n_eguna = zerbitzu_kop(egun_idx);
    uneko_denbora_seg = 0;
    
    %Egun bakoitzeko zerbitzuak sortu
    for i = 1:n_eguna
        %1. Zein ordeu tartetan gauden jakin behar dugu λ lortzeko
        uneko_ordua = uneko_denbora_seg / 3600;
        tarte_idx = min(floor(uneko_ordua / 2) + 1, 12);
        
        lambda = tasak_astea(egun_idx, tarte_idx);
        
        %2. Hurrengo zerbitzurako itxaron denbora
        %Arazoa: lambda 0 bada (gauean), denbora infinitua izan daiteke. 
        %Segurtasun muga bat jarriko dugu 
        if lambda > 0
            itxaron_t_orduak = exprnd(1/lambda);
        else
            itxaron_t_orduak = 0.5; % Ordu erdi itxaron tasa 0 denean
        end
        
        uneko_denbora_seg = uneko_denbora_seg + (itxaron_t_orduak * 3600);
        
        %3. Mugatu eguneko 24 orduetara
        if uneko_denbora_seg > 24 * 3600
            zerbitzu_index = zerbitzu_index + (n_eguna - i + 1);
            break; %Eguna amaitu da
        end
        zerbitzu_taula.hora_disponible(zerbitzu_index) = seconds(mod(uneko_denbora_seg, 24*3600));
        
        itxaron_segunduak = rand() * 15 * 60;
        zerbitzu_taula.hora_recogida(zerbitzu_index) = zerbitzu_taula.hora_disponible(zerbitzu_index) + seconds(itxaron_segunduak);
        
        jatorria = string(zerbitzu_taula.jatorria_id(zerbitzu_index));
        helmuga = string(zerbitzu_taula.helmuga_id(zerbitzu_index));
        
        minutuak = readtable('minutuguztiak.xlsx', 'ReadRowNames', true, 'VariableNamingRule', 'preserve');
        bidai_segunduak = minutuak{jatorria, helmuga} * 60;
        zerbitzu_taula.hora_llegada(zerbitzu_index) = zerbitzu_taula.hora_recogida(zerbitzu_index) + seconds(bidai_segunduak);
        
        zerbitzu_index = zerbitzu_index + 1; 
    end
end
zerbitzu_taula.hora_disponible.Format = "hh:mm:ss";
zerbitzu_taula.hora_recogida.Format = "hh:mm:ss";
zerbitzu_taula.hora_llegada.Format = "hh:mm:ss";

    

% Emaitzak ikusteko
%head(zerbitzu_taula,10)

%writetable(zerbitzu_taula, "zerbitzutaula.xlsx")
%%
rng(1);

zerbitzuak = readtable('zerbitzutaula.xlsx');
txandak = readtable('lantxandak.xlsx');

zerbitzuak.data = datetime(zerbitzuak.data);
txandak.eguna = datetime(txandak.eguna);

%Bi zutabe berri sortu esleipenak gordetzeko
zerbitzuak.gidari_id = nan(height(zerbitzuak), 1);
zerbitzuak.sanitario_id = nan(height(zerbitzuak), 1);

%Hasierako balio bezala zehaztu langile guztien "libre" ordua eguneko 00:00:00 moduan
txandak.libre_noiz = duration(zeros(height(txandak), 1), 0, 0);

%Zerbitzuen ordua ordu-formatuan (duration) jarri konparaketak egiteko
zerbitzuak.hora_disponible = duration(string(zerbitzuak.hora_disponible));
zerbitzuak.hora_llegada = duration(string(zerbitzuak.hora_llegada));

for i = 1:height(zerbitzuak)
    z_data = zerbitzuak.data(i);
    z_hasiera = zerbitzuak.hora_disponible(i);
    z_amaiera = zerbitzuak.hora_llegada(i);
    
    %1. Langile erabilgarriak bilatu (Egun berean + Aktibo + Libre ordua <= Hasiera ordua)
    posibleak = txandak(txandak.eguna == z_data & ...
                        strcmp(txandak.egoera, 'Aktibo') & ...
                        txandak.libre_noiz <= z_hasiera, :);
    
    %2. Gidaria (G) esleitu
    gidari_posibleak = posibleak(strcmp(posibleak.postua, 'G'), :);
    if ~isempty(gidari_posibleak)
        %Lehenengo libre geratu dena hartu 
        gidaria = gidari_posibleak(1, :);
        zerbitzuak.gidari_id(i) = gidaria.id_langile;
        
        %Eguneratu langilearen libre ordua taula orokorrean
        idx = (txandak.id_langile == gidaria.id_langile & txandak.eguna == z_data);
        txandak.libre_noiz(idx) = z_amaiera;
    end
    
    %3. Sanitarioa (S) esleitu
    sanitario_posibleak = posibleak(strcmp(posibleak.postua, 'S'), :);
    if ~isempty(sanitario_posibleak)
        sanitarioa = sanitario_posibleak(1, :);
        zerbitzuak.sanitario_id(i) = sanitarioa.id_langile;
        
        %Eguneratu langilearen libre ordua
        idx = (txandak.id_langile == sanitarioa.id_langile & txandak.eguna == z_data);
        txandak.libre_noiz(idx) = z_amaiera;
    end
end


%% ABSENTISMOAK
rng(1);

langileak = readtable('langileak.xlsx');

absentismo_kop = 20;
arrazoiak = {'gaixotasuna', 'familia arazoa', 'joan-etorria', 'istripua', 'etxebizitza arazoa', 'justifikatu gabea'};

%Absentismoen gako nagusiak
absentismo_id = (1:absentismo_kop)';
%Ausaz aukeratutako langileak
langile_id = langileak.id_langilea(randi(height(langileak), absentismo_kop, 1));
%Absentismoen ausazko datak 2025/01/13-2025/01/19 bitartean
egunak = randi([0, 6], absentismo_kop, 1);
datak = datetime(2025, 1, 13) + days(egunak);
%Ausazko arrazoiak
arrazoiak = arrazoiak(randi(length(arrazoiak), absentismo_kop, 1))';

% TAULA
absentismoak = table(absentismo_id, langile_id, datak, arrazoiak);

%head(absentismoak,20)
%writetable(absentismoak, 'absentismoak.xlsx');












