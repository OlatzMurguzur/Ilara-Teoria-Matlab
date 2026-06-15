%% %% ERLANG B INTERPRETAZIOA: LARRIALDI KRITIKOEN BLOKEO PROBABILITATEA (Pb)
%T taula: asteburuetan trasladorik ez duen eta, %80 urgentziak eta %20
%larrialdiak diren datuen taula

%Identifikatu larrialdi kritikoak soilik direnak (M/M/c/c eredurako)
T_larrialdiak = T(string(T.emergentzia) == "Larrialdia", :);

%Larrialdietako sarrera-tasak (lambda) asteko ordu-tarteka
dei_larrialdiak = groupsummary(T_larrialdiak, {'asteko_eguna', 'ordu_tartea'});
lambda_B = zeros(7, 12);

%Larrialdietako zerbitzu-tasak (Mu)
okupazio_larrialdiak = groupsummary(T_larrialdiak, {'asteko_eguna', 'ordu_tartea'}, 'mean', 'okupazio_denbora');
mu_B = zeros(7, 12);

ordena = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};

for d_idx = 1:7
    for t_idx = 1:12
        tarte_ordua = (t_idx-1)*2;

        %Sarrera-tasa (Larrialdiak orduko)
        idx_l = (string(dei_larrialdiak.asteko_eguna) == string(ordena{d_idx}) & dei_larrialdiak.ordu_tartea == tarte_ordua);
        if any(idx_l)
            lambda_B(d_idx, t_idx) = dei_larrialdiak.GroupCount(idx_l) / 2; % 2 orduko tartea delako
        end

        %Zerbitzu-tasa (Mu)
        idx_m = (string(okupazio_larrialdiak.asteko_eguna) == string(ordena{d_idx}) & okupazio_larrialdiak.ordu_tartea == tarte_ordua);
        if any(idx_m)
            mu_B(d_idx, t_idx) = 60 / okupazio_larrialdiak.mean_okupazio_denbora(idx_m);
        else
            mu_B(d_idx, t_idx) = 2.0; % Balio estandarra (larrialdiak luzeagoak izan ohi dira)
        end
    end
end

%Blokeo Probabilitatearen Matrizea (Pb)
Pb_matrizea = zeros(7, 12);

%Erlang B formula ebazteko
for d = 1:7
    for t = 1:12
        l = lambda_B(d, t)*10 ;
        m = mu_B(d, t);
        c = round(c_real(d, t)/2 ); %Zure txanda eta absentismoen c_real berbera

        %Muga-baldintzak kontrolatzeko
        if l == 0
            Pb_matrizea(d, t) = 0; %Deirik ez badago, blokeo arriskua 0 da
            continue;
        end
        if c <= 0
            Pb_matrizea(d, t) = 1; %Anbulantziarik ez badago, dei guztiak blokeatzen dira (%100)
            continue;
        end

        %Trafiko intentsitatea (a)
        a = l/m;

        %Erlang B formula kalkulatu 
        izendatzailea = 0;
        for k = 0:c
            izendatzailea = izendatzailea + (a^k) / factorial(k);
        end
        zenbakitzailea = (a^c) / factorial(c);

        %Probabilitatea %0-100 formatura pasatuta
        Pb_matrizea(d, t) = (zenbakitzailea / izendatzailea) * 100;
    end
end

%Heatmap
figure('Name', 'Erlang B: Blokeo Probabilitatea');
tarte_izenak = {'0-2', '2-4', '4-6', '6-8', '8-10', '10-12', '12-14', '14-16', '16-18', '18-20', '20-22', '22-24'};

h3 = heatmap(tarte_izenak, ordena, Pb_matrizea);
h3.Title = 'Bizi-Arrisku Kritikoen Blokeo Probabilitatea (c/2, lambda*10), P_b (%)';
h3.XLabel = 'Ordu Tartea'; h3.YLabel = 'Asteko Eguna';
h3.Colormap = hot; %Arriskua hobeto islatzeko kolore eskala gorria