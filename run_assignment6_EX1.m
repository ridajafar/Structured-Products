% runAssignment6 EXERCISE 1
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

%% EXERCISE 1

disp('EXERCISE 1')

% Parameters
X = 0.025;
spol = 200*1e-4;
sigma = [0.161 0.42; 0.42 0.26];
d_e = 0.028;
d_a = 0.021;
weight = 1/2;
P = 0.95;

% Setting dates and rates
today = '2023-01-31';
date0y = datenum(2023,02,02);
date1y = datenum(2024,02,02);
dates_yearly = [date0y; date1y; dates(13:16)];
discounts_yearly = [1; Disc_interp(discounts,dates,date1y); discounts(13:16)];
delta_times_365 = yearfrac(dates_yearly(1:end-1),dates_yearly(2:end),act365);
forward_rates = -log(discounts_yearly(2:end)./discounts_yearly(1:end-1))./delta_times_365;


%% Computation of alpha

% Initializing the stocks values
stocks_data = readtable('EUROSTOXX50_2023_Dataset.csv','VariableNamingRule', 'preserve');
S_a0 = stocks_data.("AXAF.PA")(stocks_data.Date==today);
S_e0 = stocks_data.("ENEI.MI")(stocks_data.Date==today);

% Stocks Simulation
tic
M = 1e7;
[S_a,S_e] = simulateStocks(M, S_a0, S_e0, forward_rates, d_a, d_e, delta_times_365, sigma);

% Payoff Computation
S = sum(weight * (S_a(:,2:end)./S_a(:,1:end-1) + S_e(:,2:end)./S_e(:,1:end-1)),2);
[payoff, std, ci] = normfit(max(0,S-P));
fprintf('The length of the Confidence interval is: %f \n', ci(2)-ci(1))
toc

% NPV of the certificate
coupon = @(alpha) alpha*payoff;
delta_times_360 = yearfrac(dates_yearly(1:end-1),dates_yearly(2:end),act360);
BPV = sum(discounts_yearly(2:end).*delta_times_360);
NPV = @(alpha) X - 1 + discounts_yearly(end)*(coupon(alpha) + P) - spol*BPV;

% Find alpha 
options = optimset('Display','off');
alpha = fsolve(NPV, 0, options);

% Display results
fprintf('The value of alpha is: %f \n', alpha)

