function [slope_digital_price, black_digital_price] = digital_price(delta_time_365, F0, K_digital, discount, payoff, smile)
% Computes the price of a digital option both with the black formula and
% considering the slope of the smile curve impact

% INPUT:
%
% delta_time_365:   delta time between evaluation date and exercise date (act365)
% sigma_digital:    volatility
% F0:               initial value of the forward
% K_digital:        strike
% discount:         discount factor between evaluation date and exercise date
% payoff:           payoff of the digital option
% smile:            smile curve struct


% Parameters for readability
K = smile.cSelect.strikes;
sigma = smile.cSelect.surface;
sigma_digital = interp1(K,sigma,K_digital);

% Computing d1,d2 and vega
d1 = 1./sqrt(delta_time_365*sigma_digital^2).*(log(F0/K_digital) + 1/2*delta_time_365*sigma_digital^2);
d2 = 1./sqrt(delta_time_365*sigma_digital^2).*(log(F0/K_digital) - 1/2*delta_time_365*sigma_digital^2);
vega = discount*F0*exp(-d1^2/2)/sqrt(2*pi)*sqrt(delta_time_365);

% Computing the price of the digital option with the Black formula
black_digital_price = discount*normcdf(d2)*payoff;

% Computing (numerically) the derivative of the slope with respect to K
K_bigger = K(K > K_digital);
sigma_bigger = sigma(K > K_digital);
K_smaller = K(K < K_digital);
sigma_smaller = sigma(K < K_digital);
slope_impact = (sigma_bigger(1)-sigma_smaller(end))/(K_bigger(1)-K_smaller(end));

% Computing the price of the digital option considering the volatility smile
slope_digital_price = black_digital_price - slope_impact*vega*payoff;

end