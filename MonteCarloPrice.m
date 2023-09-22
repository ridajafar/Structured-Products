function [price,std,ci] = MonteCarloPrice(N, x, ttm, sigma, eta, k, F0, discount)
% Computes the price of the option using Monte Carlo
% 
% INPUT
% N:        number of simulations
% x:        log-moneyness
% ttm:      ttm of the call
% sigma:    sigma coefficient of the distribution
% eta:      eta coefficient of the distribution
% k:        k coefficient of the distribution
% F0:       forward of the underlying of the call
% discount: discount of the call


rng(42)
g = randn(N,1);
G = gamrnd(ttm/k, k/ttm, N, 1);

% Checking the first 4 moments
numerical_moments = mean(G.^(1:4));
theoretical_moments = [1, (ttm+k)/ttm, (ttm+k)*(ttm+2*k)/ttm, (ttm+k)*(ttm+2*k)*(ttm+3*k)/ttm^3];
check = numerical_moments - theoretical_moments;
disp('Checks for the first four moments:')
disp(check)

% Simulating Ft
laplace_exponent = @(w) -ttm/k*log(1+k*w*sigma^2);
f_t = sqrt(ttm)*sigma*sqrt(G).*g - (1/2 + eta)*ttm*sigma^2*G - laplace_exponent(eta);
F_t = F0*exp(f_t);

% Computing payoff and price
K = F0./exp(x);
payoff = max(F_t - K, 0);
[price,std,ci] = normfit(discount*payoff);

end