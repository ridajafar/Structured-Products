% runAssignment6 EXERCISE 2
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

% Setting dates and rates
today = '2023-01-31';
date0y = datenum(2023,02,02);
date1y = datenum(2024,02,02);
discount_1y = Disc_interp(discounts,dates,date1y);
delta_time_365 = yearfrac(date0y,date1y,act365);
r = -log(discount_1y)./delta_time_365;

%% EXERCISE 2

disp('EXERCISE 2')

% Parameters
smile = load('Smile.mat');
Notional = 1e7;
payoff = 0.05*Notional;
S0 = smile.cSelect.reference;
d = smile.cSelect.dividend;

% ATM Spot -> K = S0
F0 = S0*exp(delta_time_365*(r-d));
K_digital = S0;

% Computing the price of the digital option 
[slope_digital_price, black_digital_price] = digital_price(delta_time_365, F0, K_digital, discount_1y, payoff, smile);

% Displaying results
fprintf('The price of the digital option using the Black formula is: %f \n', black_digital_price)
fprintf('The price of the digital option considering the slope impact is: %f \n', slope_digital_price)

