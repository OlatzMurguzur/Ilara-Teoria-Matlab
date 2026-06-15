%% %% ASTEBURUKO LARRIALDI KRITIKOEN BLOKEO PROBABILITATE OROKORRA (Pb)


%ASTEBURUKO ESKARIAREN BANAKETA (%80 URGENTZIA / %20 LARRIALDIA)

%Aurkitu asteburuko lerro guztiak (Sat eta Sun)
asteburu_idx = (string(T.asteko_eguna) == "Sat" | string(T.asteko_eguna) == "Sun");
N_asteburu = sum(asteburu_idx); % Asteburuko zerbitzu kopuru totala

%Sortu ausazko banaketa bat 0 eta 1 arteko zenbakiekin
rng('default'); % Emaitzak beti berdinak izateko
ausazko_prob = rand(N_asteburu, 1);

%Esleitu kategoriak: %20 Larrialdiak (probabilitatea <= 0.20) eta %80 Urgentziak (probabilitatea > 0.20)
mota_berria = cell(N_asteburu, 1);
mota_berria(ausazko_prob <= 0.20) = {'Larrialdia'};
mota_berria(ausazko_prob > 0.20) = {'Urgentzia'};

%Idatzi aldaketa T taula nagusian
T.emergentzia(asteburu_idx) = mota_berria;



%%
%Garbitu taula: Asteburuak (Sat, Sun) eta Larrialdiak soilik mantendu
larrialdi_idx = (string(T.emergentzia) == "Larrialdia");

T_asteburu_larrialdiak = T_iritsierak(asteburu_idx & larrialdi_idx,:);

%SARRERA-TASA (Lambda) kalkulatu: Asteburuko larrialdiak orduko
%Asteburu batek 48 ordu ditu (24h larunbata + 24h igandea)
dei_kopuru_totala = height(T_asteburu_larrialdiak);
lambda_asteburua = dei_kopuru_totala / 48; 

%ZERBITZU-TASA (Mu) kalkulatu: Orduko zenbat zerbitzu amaitzen diren
if dei_kopuru_totala > 0
    batea_besteko_iraupena = mean(T_asteburu_larrialdiak.okupazio_denbora);
    mu_asteburua = 60 / batea_besteko_iraupena;
else
    mu_asteburua = 2.0; %Balio lehenetsia daturik ez badago (30 minutu bidaiko)
end

%ANBULANTZIA KOPURUA (c): Asteburuko batez besteko anbulantzia errealak
%'c_real' matrizetik larunbat (6. eguna) eta igandeko (7. eguna) balioak batu eta batezbestekoa egin
c_asteburua = round(mean(mean(c_real(6:7, :)))); 

%ERLANG B FORMULA  
if lambda_asteburua == 0
    Pb_asteburua = 0; %Deirik ez badago, blokeo arriskua zero da
elseif c_asteburua <= 0
    Pb_asteburua = 100; %Anbulantziarik ez badago, dei guztiak blokeatzen dira
else
    %Trafiko intentsitatea (a)
    a = lambda_asteburua / mu_asteburua; 

    %Erlang B algoritmoa
    B = 1;
    for k = 1:c_asteburua
        B = (a * B) / (k + a * B);
    end
    Pb_asteburua = B * 100; %Ehunekoa
end

%Emaitzak ikusteko
fprintf('Asteburuko dei kritiko kopurua: %d dei\n', dei_kopuru_totala);
fprintf('Sarrera-tasa (Lambda): %.4f larrialdi/oruko\n', lambda_asteburua);
fprintf('Zerbitzu-tasa (Mu): %.4f zerbitzu/oruko (Batez beste: %.2f min)\n', mu_asteburua, batea_besteko_iraupena);
fprintf('Erabilitako anbulantzia kopurua (c_media): %d anbulantzia\n', c_asteburua);
fprintf('BLOKEO PROBABILITATEA (Pb): %.6f %%\n', Pb_asteburua);
