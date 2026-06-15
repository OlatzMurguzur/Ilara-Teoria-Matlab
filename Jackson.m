%% JACKSON-EN SAREAK: HELMUGA OSPITALEEN ETA ILARA-SAREAREN ANALISIA
%T_iritsierak: datubaseari iritsiera eta okupazio denborak gehitutako taula


%Kendu helmuga edo okupazio denbora NaN duten lerroak
T_sareak = T_iritsierak(~isnan(T_iritsierak.okupazio_denbora) & ~cellfun(@isempty, T_iritsierak.helmuga_id), :);

%Ziurtatu helmuga zutabea string dela konparaketak ondo egiteko
T_sareak.helmuga = string(T_sareak.helmuga_id);

%Identifikatu aztertu nahi ditugun ospitale nagusiak
ospitaleak = ["h001","h002", "h003", "h004", "h005", "h006","h007","h008","h009","h010"];
N_osp = length(ospitaleak);

%Kalkulatu sarrera-tasa orokorra (Deiak orduko, aste osoan)
%Dei kopurua / asteko ordu kopuru totala (168h)
dei_kopuru_tot = height(T_sareak);
lambda_totala = dei_kopuru_tot / 168;

%BIDERATZE-PROBABILITATEAK (P_i) 
probabilitateak = zeros(1, N_osp);
for i = 1:N_osp
    kopurua = sum(T_sareak.helmuga == ospitaleak(i));
    probabilitateak(i) = kopurua / dei_kopuru_tot;
    fprintf('%s ospitalera bideratzeko probabilitatea (p_%d): %.2f%%\n', ospitaleak(i), i, probabilitateak(i)*100);
end

%OSPITALE BAKOITZEKO SARRERA-TASA (Lambda_i) ETA ZERBITZU-TASA (Mu_i)
lambda_i = zeros(1, N_osp);
mu_i = zeros(1, N_osp);

for i = 1:N_osp
    % Ospitale bakoitzak jasotzen duen eskari espezifikoa (Jackson-en ekuazioa)
    lambda_i(i) = lambda_totala * probabilitateak(i);

    % Ospitale bakoitzeko anbulantzien batez besteko entrega-denbora 
    denbora_mean = mean(T_sareak.okupazio_denbora(T_sareak.helmuga == ospitaleak(i)));
    mu_i(i) = 60 / denbora_mean; % Orduko zerbitzatu daitezkeen anbulantziak
end




%SENTIKORTASUN GRAFIKOA
figure('Name', 'Jackson Sareak: Sentikortasun Analisia', 'Position', [100 100 800 500]);
hold on;

koloreak = lines(2); 
c_balioak = 1:2; % Aztertu nahi ditugun anbulantzia-gaitasunak (1etik 2ra)
W_simulazioa = zeros(1, 2);

for i = 1:N_osp
    lambda_nodo = lambda_i(i);
    mu_nodo = mu_i(i);

    %Kalkulatu W_q (c) bakoitzarentzat 
    for c_idx = 1:2
        c_probatu = c_balioak(c_idx);
        rho_osp = lambda_nodo / (c_probatu * mu_nodo);

        if rho_osp < 1 && rho_osp > 0
            % Erlang C formula estandarra
            zenb = ((c_probatu * rho_osp)^c_probatu) / (factorial(c_probatu) * (1 - rho_osp));
            izend = 0;
            for k = 0:(c_probatu-1)
                izend = izend + ((c_probatu * rho_osp)^k) / factorial(k);
            end
            izend = izend + zenb;
            Pc_osp = zenb / izend;

            W_simulazioa(c_idx) = (Pc_osp / (c_probatu * mu_nodo * (1 - rho_osp))) * 60;
        else
            % Sistema kolapsatzen bada (rho >= 1), muga altu bat jarri joera ikusteko
            W_simulazioa(c_idx) = lambda_nodo * 40 / c_probatu; 
        end
        k_puntu=plot(i, W_simulazioa(c_idx),'Marker', 'o', ...
            'MarkerSize', 10, ...
            'MarkerFaceColor', koloreak(c_idx,:), ...
            'MarkerEdgeColor', koloreak(c_idx,:));
        labels = sprintf('%.1f',  W_simulazioa(c_idx));
        text(i, W_simulazioa(c_idx)+0.1, labels, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', 7.5, ...
            'FontWeight', 'bold');

    end

end



title('Anbulantzia-Gaitasunaren ($c$) Eragina Itxaron-Denboran ($W_q$)', 'Interpreter', 'latex', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Ospitaleko Harrera-Gaitasuna (Aldi bereko anbulantzia kopurua, $c$)', 'Interpreter', 'latex');
ylabel('Batez besteko itxaron-denbora triajean (Minutuak)');

xticks(1:N_osp); 
grid on;

ospitaleak={"Gurutzeta", "Basurto", "Galdakao", "Santa Marina", "Bermeo", "Gorliz", "Zamudio", "San Eloy", "Zorrotzaurre", "Urduliz"};
set(gca, 'XTickLabel', ospitaleak);
legend({'c=1','c=2'}, 'Location', 'NorthEast', 'FontSize', 7);

hold off;


%% JACKSON SAREAREN INPLEMENTAZIOA

ospitale_id_zerrenda = ["h001", "h002", "h003", "h004", "h005", "h006", "h007", "h008", "h009", "h010"];
N_osp = length(ospitale_id_zerrenda);

%Jacksonen sareko matrize eta bektoreak
R = zeros(N_osp, N_osp);       % 10x10 Bideratze-matrizea
bidaia_kopuru_totala = zeros(1, N_osp); % Ospitale bakoitzetik ateratako bidaia guztiak
kanpoko_sarrerak_kopuru = zeros(1, N_osp); % Kanpoko deien kontagailua (gamma)

for k = 1:height(T)
    jat = string(T.jatorria_id{k});
    hel = string(T.helmuga_id{k});

    % KANPOKO SARRERAK (\gamma_i) kontatu
    % Jatorria herria bada ('p') eta helmuga ospitalea bada ('h')
    if startsWith(jat, 'p') && startsWith(hel, 'h')
        idx_helmuga = find(ospitale_id_zerrenda == hel);
        if ~isempty(idx_helmuga)
            kanpoko_sarrerak_kopuru(idx_helmuga) = kanpoko_sarrerak_kopuru(idx_helmuga) + 1;
        end
    end

    % BARNE BIDERATZEA (r_ji) ETA IRTEERAK kontatu 
    % Jatorria ospitalea bada ('h')
    if startsWith(jat, 'h')
        idx_jatorria = find(ospitale_id_zerrenda == jat);
        if ~isempty(idx_jatorria)
            % Gehituko dugu bidaia honen irteera jatorrizko ospitalean
            bidaia_kopuru_totala(idx_jatorria) = bidaia_kopuru_totala(idx_jatorria) + 1;

            % Helmuga ere ospitalea bada, barne bideratzea da
            if startsWith(helmuga, 'h')
                idx_helmuga = find(ospitale_id_zerrenda == hel);
                if ~isempty(idx_helmuga)
                    R(idx_jatorria, idx_helmuga) = R(idx_jatorria, idx_helmuga) + 1;
                end
            end
        end
    end
end

% PROBABILITATEAK BIHURTU (Zatitu errenkada bakoitza bere bidaia
% totalarekin)
for j = 1:N_osp
    if bidaia_kopuru_totala(j) > 0
        R(j, :) = R(j, :) / bidaia_kopuru_totala(j);
    end
end

% TASA BIHURTU (lambda eta gamma)
egun_kopurua = 7; 
ordu_guztira = egun_kopurua * 24;

% Kanpoko sarrera-tasa (\gamma_i) orduko deietan bihurtu
gamma_i = kanpoko_sarrerak_kopuru / ordu_guztira;

% JACKSONEN TRAFIKO EKUAZIOAK EBATZI (lambda_i lortzeko)
% Ekuazioa: \lambda = \gamma + \lambda * R  --> \lambda * (I - R) = \gamma
I = eye(N_osp);
lambda_i = gamma_i / (I - R); 

% Ospitale bakoitzaren saturazio-indizea (h -> h bidaia guztien batura)
saturazio_indizea = sum(R, 2); 

for j = 1:N_osp
    fprintf('%s -> Anbulantziak beste ospitale batera desbideratzeko probabilitatea: %.2f%%\n', ...
        ospitale_id_zerrenda(j), saturazio_indizea(j)*100);
end

errenkada_sumak = sum(R, 2); 

%Ospitaleren batek desbideratzerik ez badu (batura = 0), zeroz zatitzean erroreak ekiditeko:
errenkada_sumak(errenkada_sumak == 0) = 1; 

R_normalizatua = R ./ errenkada_sumak;


%OSPITALEEN SATURAZIO INDIZEA (h -> h)
%h001 -> Anbulantziak beste ospitale batera desbideratzeko probabilitatea: 1.67%
%h002 -> Anbulantziak beste ospitale batera desbideratzeko probabilitatea: 0.00%
%h003 -> Anbulantziak beste ospitale batera desbideratzeko probabilitatea: 3.12%
%h004 -> Anbulantziak beste ospitale batera desbideratzeko probabilitatea: 5.56%
%h005 -> Anbulantziak beste ospitale batera desbideratzeko probabilitatea: 1.67%
%h006 -> Anbulantziak beste ospitale batera desbideratzeko probabilitatea: 3.17%
%h007 -> Anbulantziak beste ospitale batera desbideratzeko probabilitatea: 7.02%
%h008 -> Anbulantziak beste ospitale batera desbideratzeko probabilitatea: 3.33%
%h009 -> Anbulantziak beste ospitale batera desbideratzeko probabilitatea: 0.00%
%h010 -> Anbulantziak beste ospitale batera desbideratzeko probabilitatea: 4.23%