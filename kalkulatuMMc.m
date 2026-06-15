function neurriak = kalkulatuMMc(c, lambda, mu)
% c: Zerbitzari kopurua (Anbulantziak)
% lambda: Iritsiera-tasa (lambda)
% mu: Zerbitzu-tasa (mu)

%Parametroak 
a = lambda / mu;      % Trafiko-intentsitatea (Erlang-etan) 
rho = a / c;          % Sistemaren erabilera tasa 

%Egonkortasun baldintza egiaztatu
if rho >= 1
    error('Sistema ez-egonkorra (rho >= 1). Ilara infinitu haziko litzateke.');
end

%Erlang-C Formula: C(c, a) 
% Baturaren zatia: sum_{n=0}^{c-1} (a^n / n!)
n_balioak = 0:(c-1);
baturaren_zatia = sum((a.^n_balioak) ./ factorial(n_balioak));

zenbakitzailea = (a^c) / factorial(c);
izendatzailea = (1 - rho) * baturaren_zatia + zenbakitzailea;

C_ca = zenbakitzailea / izendatzailea;

%Errendimendu neurriak 
% Ilaran dagoen bezero kopuru ertaina (Lq) 
Lq = (rho * C_ca) / (1 - rho);

% Ilaran itxaron beharreko denbora ertaina (Wq) 
Wq = C_ca / (c * mu * (1 - rho));

% Sisteman igarotako denbora ertaina (W) 
W = Wq + (1 / mu);

% Sisteman dagoen bezero kopuru ertaina (L) 
L = lambda * W;


neurriak.rho = rho;
neurriak.C_ca = C_ca;
neurriak.Lq = Lq;
neurriak.Wq = Wq;
neurriak.W = W;
neurriak.L = L;

end