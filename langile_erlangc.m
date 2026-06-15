%% Langileen absentismoen eragina itxaron-denboran
%Iritsiera tasa (lambda): tasak_astea da gure lambda (zerbitzuak orduko) -> datubasea.m fitxategitik
lambda_matrizea = tasak_astea; 

%Zerbitzu tasa (mu)
mu_matrizea = zeros(7, 12);
for d_idx = 1:7
    for t_idx = 1:12
        egun_izenak = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
        tarte_ordua = (t_idx-1)*2; %2 orduko tarteak direlako

        %Bilatu balioa aurreko 'emaitzak_okupazioa' taulan ->
        % estatistikoak.m fitxategitik
        idx = (emaitzak_okupazioa.asteko_eguna == egun_izenak{d_idx} & emaitzak_okupazioa.ordu_tartea == tarte_ordua);
        if any(idx)
            % mu = 60 / BatezBesteko_Okupazioa_Min (zerbitzu-orduko bihurtzeko)
            mu_matrizea(d_idx, t_idx) = 60 / emaitzak_okupazioa.BatezBesteko_Okupazioa_Min(idx);
        else
            mu_matrizea(d_idx, t_idx) = 2.5; %Balio lehenetsia daturik ez badago (NAN kasua)
        end
    end
end

%Errendimendu neurrien matrizeak (7 egun x 12 tarte)
Wq_matrizea_min = zeros(7, 12); % Itxaron denbora minututan
Lq_matrizea = zeros(7, 12);     % Ilarako luzera
Pc_matrizea = zeros(7, 12);     % Itxaroteko probabilitatea

%Erlang C elementuz elementu kalkulatzeko
for d = 1:7
    for t = 1:12
        l = lambda_matrizea(d, t);
        m = mu_matrizea(d, t);
        c = c_real(d, t); %c_erreala.m fitxategitik

        %Deirik ez badago, ez dago itxaronaldirik
        if l == 0
            Wq_matrizea_min(d, t) = 0; Pc_matrizea(d, t) = 0; Lq_matrizea(d, t) = 0;
            continue;
        end

        %Absentismoagatik c=0 geratzen bada, sistema kolapsatuta dago 
        if c <= 0
            Wq_matrizea_min(d, t) = Inf; Pc_matrizea(d, t) = 1; Lq_matrizea(d, t) = Inf;
            continue;
        end

        %Erabilera maila (rho)
        rho = l / (c * m);

        %Egonkortasun baldintza egiaztatu (\rho >= 1 bada, kolapsoa)
        if rho >= 1
            Wq_matrizea_min(d, t) = Inf; Pc_matrizea(d, t) = 1; Lq_matrizea(d, t) = Inf;
        else
            % Erlang C-ren sumatorioaren zati izendatzailea
            a = l / m; % Trafiko intentsitatea
            batura = 0;
            for k = 0:(c-1)
                batura = batura + (a^k) / factorial(k);
            end

            % C zatia (Muga karga)
            termino_c = (a^c) / (factorial(c) * (1 - rho));

            %Itxaroteko Probabilitatea (Pc)
            Pc = termino_c / (batura + termino_c);

            %Ilarako luzera (Lq)
            Lq = Pc * (rho / (1 - rho));

            %Ilarako itxaron denbora orduetan, eta minututara pasatu (Wq)
            Wq_orduak = Lq / l;
            Wq_minbak = Wq_orduak * 60;

            %Gorde datuak matrizean
            Pc_matrizea(d, t) = Pc;
            Lq_matrizea(d, t) = Lq;
            Wq_matrizea_min(d, t) = Wq_minbak;
        end
    end
end

%Heatmap (Wq)
figure('Name', 'Erlang C: Itxaron Denbora Teorikoa');
ordena_kronologikoa = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
tarte_izenak = {'0-2', '2-4', '4-6', '6-8', '8-10', '10-12', '12-14', '14-16', '16-18', '18-20', '20-22', '22-24'};

h = heatmap(tarte_izenak, ordena_kronologikoa, Wq_matrizea_min);
h.Title = 'Pazienteen Itxaron Denbora Teorikoa Ilaran (W_q minututan)';
h.XLabel = 'Ordu Tartea'; h.YLabel = 'Asteko Eguna';