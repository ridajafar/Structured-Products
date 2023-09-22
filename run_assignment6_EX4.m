% runAssignment6 EXERCISE 4
% group 7, AY2022-2023

clear;

% yearfrac formats
act360 = 2;
act365 = 3;

%% Read market data

if ispc()   % Windows version
    formatData='dd/mm/yyyy'; 
    [datesSet, ratesSet] = readExcelData('MktData_CurveBootstrap_AY22-23', formatData);
else        % MacOS version
    datesSet = load("datesSet.mat");
    datesSet = datesSet.datesSet;
    ratesSet = load("ratesSet.mat") ;
    ratesSet = ratesSet.ratesSet;
end

% Bootstrap discounts
[dates, discounts] = BootStrap(datesSet, ratesSet);

%% EXERCISE 4

disp('EXERCISE 4')

% Parameters
alpha = 1/3;
t = 1;

% Setting dates and rates
today = '2023-01-31';
date_start = datenum(2023,02,02);
date_end = datenum(2024,02,02);
discount = Disc_interp(discounts,dates,date_end);
ttm = yearfrac(date_start,date_end,act365);
r = -log(discount)./ttm;
smile = load('Smile.mat');
S0 = smile.cSelect.reference;
d = smile.cSelect.dividend;
F0 = S0*exp(ttm*(r-d));

% Compute prices with the black formula
sigma_black = smile.cSelect.surface';
K = smile.cSelect.strikes';
[price_black,~] = arrayfun(@(sigma_black,k) blkprice(F0, k, r, t, sigma_black),sigma_black,K);

% Define log-moneyness grid
logm = log(F0./K);


%% MINIMIZATION

% Compute price
price_FFT = @(sigma,x,k,eta) compute_price(alpha, ttm, k, sigma, eta, x, discount, F0, 1);

% Compute L2 distance between prices
w = ones(length(K),1)/length(K);
distance = @(sigma,x,k,eta) sum(w.*(price_black - real(price_FFT(sigma,x,k,eta))).^2);
%distance = @(sigma,x,k,eta) sum(w.*(price_black - real(prices_quad(sigma,x,k,eta))).^2) + (sigma<0)*10^8 + (eta<-min(w))*10^8 + (k<0)*10^8;

% Minimize L2 distance to obtain volatility surface
params0 = [0.21,1.1,4]';

A = -eye(3);

b = zeros(3,1);
b(3) = min(w);

tic
params = fmincon(@(params) distance(params(1),logm,params(2),params(3)),params0,A,b);
%params = fminsearch(@(params) distance(params(1),logm,params(2),params(3)),params0);
toc

% Implied volatilities
vols = blkimpv(F0, K, r, ttm, real(price_FFT(params(1),logm,params(2),params(3))));

% Plot implied volatility against the mean of the surface
figure()
plot(K,sigma_black,'b')
hold on
plot(K,vols,'Color',"#EDB120"')
xlabel('Strikes')
ylabel('Implied volatility')
legend('Black','Lewis')
axis('padded')
hold off
