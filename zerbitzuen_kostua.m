%% Anbulantzien kostu ekonomikoa egun eta ordu tarte bakoitzean

%Aldatu komak puntuengatik str2double-k funtzionatzeko
testu_kostua = string(T_iritsierak.kostua);
testu_kostua = strrep(testu_kostua, ',', '.'); 
T_iritsierak.kostua = str2double(testu_kostua);

%Kostuen batura kalkulatu (NaN balioak alde batera utzita)
kostu_analisia = groupsummary(T_iritsierak, {'asteko_eguna', 'ordu_tartea'}, 'sum', 'kostua');
kostu_analisia.Properties.VariableNames{'sum_kostua'} = 'Kostu_Totala_Euro';

ordena = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
tarteak = {'0-2', '2-4', '4-6', '6-8', '8-10', '10-12', '12-14', '14-16', '16-18', '18-20', '20-22', '22-24'};
kostu_matrizea = zeros(7, 12); 

for d_idx = 1:7
    for t_idx = 1:12
        tarte_ordua = (t_idx-1)*2; 

        %Bihurtu string eta double errorea ekiditeko 
        idx = (string(kostu_analisia.asteko_eguna) == string(ordena{d_idx}) & ...
            double(kostu_analisia.ordu_tartea) == tarte_ordua);

        if any(idx)
            %Balioa badago, gorde matrizean, bestela NAN bada, 0 jarri 
            balioa = kostu_analisia.Kostu_Totala_Euro(idx);
            if isnan(balioa)
                kostu_matrizea(d_idx, t_idx) = 0;
            else
                kostu_matrizea(d_idx, t_idx) = balioa;
            end
        end
    end
end

%Heatmap
figure('Name', 'Larrialdien Kostu Ekonomiko Metatua');
h2 = heatmap(tarteak, ordena, kostu_matrizea);

h2.Title = 'Larrialdi Zerbitzuen Kostu Ekonomiko Metatua (Eurotan)';
h2.XLabel = 'Ordu Tartea'; 
h2.YLabel = 'Asteko Eguna';






