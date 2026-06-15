%% Absentismoen eragina
txandak = readtable('lantxandak.xlsx');
absentismoak = readtable('absentismoak.xlsx');

%Formatua
txandak.eguna = datetime(txandak.eguna);
absentismoak.datak = datetime(absentismoak.datak);

%Baliabide errealak, absentismoak kontutan hartuta
c_real = zeros(7, 12);
datak_lista = datetime(2025, 1, 13) + days(0:6); 
tarteak = 0:2:22; 

for d_idx = 1:7
    uneko_data = datak_lista(d_idx);

    for t_idx = 1:12
        uneko_tarte = tarteak(t_idx);

        %Zehaztu orduaren arabera zein txanda den
        if uneko_tarte >= 6 && uneko_tarte < 14
            uneko_txanda = 'Goiz';
        elseif uneko_tarte >= 14 && uneko_tarte < 22
            uneko_txanda = 'Arratsalde';
        else
            uneko_txanda = 'Gau';
        end

        %Identifikatu egun eta txanda horretarako aktibo dauden langileak
        langile_aktibo = txandak(txandak.eguna == uneko_data & ...
            strcmp(txandak.txanda, uneko_txanda) & ...
            strcmp(txandak.egoera, 'Aktibo'), :);

        %Identifikatu eguneko absentisimoak
        baja = absentismoak(absentismoak.datak == uneko_data, :);

        %Kendu langile aktiboetatik absentismoak direnak
        langile_errealak = langile_aktibo(~ismember(langile_aktibo.id_langile, baja.langile_id), :);

        % 4. Contar conductores (G) y sanitarios (S) reales libres
        G_disp = sum(strcmp(langile_errealak.postua, 'G'));
        S_disp = sum(strcmp(langile_errealak.postua, 'S'));

        % El número de servidores efectivos 'c' es el número de parejas G-S posibles
        c_real(d_idx, t_idx) = min(G_disp, S_disp);
    end
end


