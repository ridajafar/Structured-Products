% runAssignment6 EXERCISE 3
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

%% EXERCISE 3

disp('EXERCISE 3')

% Parameters
alpha = 0;
sigma = 0.21;
k = 1.1;
eta = 4;
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

% Define log moneyness grid
x_min = -0.25;
x_max = 0.25;
step = 0.01;
x = x_min:step:x_max;

%% FFT

% Set discretization parameters
M = 15;
x_1 = -500;

% Compute price
tic
price_FFT = compute_price(alpha, ttm, k, sigma, eta, x, discount, F0, 1, M, x_1);
toc

% Plot price
figure()
plot(x,price_FFT,'-xr')
hold on

%% quadgk

% Compute price
tic
price_quad = compute_price(alpha, ttm, k, sigma, eta, x, discount, F0, 2);
toc

% Plot price
plot(x,price_quad,'-ob')

%% Monte Carlo

% Compute price
[price_MC,std,ci] = MonteCarloPrice(1e6,x,ttm,sigma,eta,k,F0,discount);

% Plot price
plot(x,price_MC,'-gs')
xlabel('log-moneyness')
ylabel('Price')
legend('FFT','Quadrature','MC')
hold off

%% FACULTATIVE PART 

alpha = 1/3;

%% FFT

% Compute price
tic
price_FFT_1 = compute_price(alpha, ttm, k, sigma, eta, x, discount, F0, 1, M, x_1);
toc

% Plot price
figure()
plot(x,price_FFT_1,'-xr')
hold on

%% quadgk

% Compute price
tic
price_quad_1 = compute_price(alpha, ttm, k, sigma, eta, x, discount, F0, 2);
toc

% Plot price
plot(x,price_quad_1,'-ob')
xlabel('log-moneyness')
ylabel('Price')
legend('FFT','Quadrature')
hold off
