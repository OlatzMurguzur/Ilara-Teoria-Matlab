%% SIMULAZIOAK

%%  ZERBITZU GEHIEN: asteazkena 12-14h

%Iritsieren arteko Batez Besteko Denbora (Minutuak)
%asteazkena 12-14h- 2.09 min
lambda_wed = 60/2.09; %iritsiera orduko

%Ibilgailuen Batez Besteko Okupazio Denbora (Minutuak)
%asteazkena 12-14h- 22.96 min
mu_wed=60/22.96; %zerbitzu orduko

kalkulatuMMc(50, lambda_wed, mu_wed)
%rho: 0.219712918660287
% sistemaren %22 soilik erabiltzen du, anbulantzia gehiegi

%C_ca: 7.851365273409429e-18
% oso balio baxua denez, paziente batek deitzeko eta anbulantzia guztiak
% okupatuta egoteko probabilitatea oso baxua da

%Lq: 2.210784236908027e-18
% oso baxua, ez dago inor ilaran

%Wq: 7.700898425229627e-20
% anbulantzia bat esleitzeko itxaron beharreko denbora nulua da

%W: 0.382666666666667
% 0.382*60=22.92 min behar dira deia egiten denetik zerbitzua amaitu arte
% behar duen denbora

%L: 10.985645933014355
% batazbeste 11 anbulantzia okupatuta -> kolapso (L>c) muga c=11


%% Zerbitzu gehien izandako egoeraren analisia

%Parametroen definizioa
lambda = 60/2.09; 
mu = 60/22.96;

%Anbulantzia kopuru tartea
c_balioak = 12:60;

%Parametroak
Wq_min = zeros(size(c_balioak));
L_balioak = zeros(size(c_balioak));
rho_balioak = zeros(size(c_balioak));

for i = 1:length(c_balioak)
    st = kalkulatuMMc(c_balioak(i), lambda, mu);
    Wq_min(i) = st.Wq * 60; %Minutuetara pasatu
    L_balioak(i) = st.L;
    rho_balioak(i) = st.rho;
end

%Grafikoak
figure('Name', 'Anbulantzia Sistemaren Analisia', 'Color', 'w');

%1. Grafikoa: Itxaron-denbora (Wq)
subplot(2,1,1);
plot(c_balioak, Wq_min, 'r-o', 'LineWidth', 1.5, 'MarkerSize', 4);
grid on;
title('Batez besteko itxaron-denbora (W_q)');
xlabel('Anbulantzia kopurua (c)');
ylabel('Minutuak');
line([11 11], [0 max(Wq_min)], 'Color', 'k', 'LineStyle', '--'); %Muga teorikoa
text(12, max(Wq_min)*0.8, '← Kolapso muga (c=11)');

%2. Grafikoa: Sistemaren erabilera (rho)
subplot(2,1,2);
yyaxis left
plot(c_balioak, rho_balioak, 'b-s', 'LineWidth', 1.5);
ylabel('Sistemaren erabilera maila (\rho)');
yyaxis right
plot(c_balioak, L_balioak, 'g-d', 'LineWidth', 1.5);
ylabel('Sisteman dauden gaixoak (L)');
grid on;
title('Sistemaren karga eta Okupazioa');
xlabel('Anbulantzia kopurua (c)');
legend('\rho (erabilera)', 'L (gaixoak)', 'Location', 'northeast');


% c=12 edo c=13 denean itxaron denbora izugarri igotzen da (esponentzialki). 
% Baina c=20tik aurrera, grafikoa ia laua da. 
% Horrek esan nahi du 20 anbulantziatik 50era pasatzeak ez duela ia batere hobetzen itxaron denbora, baina kostua bikoiztu egiten du.


%% Kasu estandarra: asteartea 8-10
lambda=60/16.52;
mu=60/27.58;

c_balioak = 12:60;

Wq_min = zeros(size(c_balioak));
L_balioak = zeros(size(c_balioak));
rho_balioak = zeros(size(c_balioak));

for i = 1:length(c_balioak)
    st = kalkulatuMMc(c_balioak(i), lambda, mu);
    Wq_min(i) = st.Wq * 60; % Minutuetara pasatu
    L_balioak(i) = st.L;
    rho_balioak(i) = st.rho;
end

%Grafikoak
figure('Name', 'Anbulantzia Sistemaren Analisia', 'Color', 'w');

%1. Grafikoa: Itxaron denbora (Wq)
subplot(2,1,1);
plot(c_balioak, Wq_min, 'r-o', 'LineWidth', 1.5, 'MarkerSize', 4);
grid on;
title('Batez besteko itxaron denbora (W_q)');
xlabel('Anbulantzia kopurua (c)');
ylabel('Minutuak');
line([11 11], [0 max(Wq_min)], 'Color', 'k', 'LineStyle', '--'); % Muga teorikoa
text(12, max(Wq_min)*0.8, '← Kolapso muga (c=11)');

% 2. Grafikoa: Sistemaren erabilera (rho)
subplot(2,1,2);
yyaxis left
plot(c_balioak, rho_balioak, 'b-s', 'LineWidth', 1.5);
ylabel('Sistemaren erabilera maila (\rho)');
yyaxis right
plot(c_balioak, L_balioak, 'g-d', 'LineWidth', 1.5);
ylabel('Sisteman dauden gaixoak (L)');
grid on;
title('Sistemaren karga eta Okupazioa');
xlabel('Anbulantzia kopurua (c)');
legend('\rho (erabilera)', 'L (gaixoak)', 'Location', 'northeast');



