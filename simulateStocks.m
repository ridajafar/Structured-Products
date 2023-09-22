function [S1,S2] = simulateStocks(M, S1_0, S2_0, rates, d1, d2, delta_times_365, sigma)
% Simulates 2 correlated stocks values in time

% INPUT
%
% M:                number of simulations
% S1_0:             initial value of the first stock
% S2_0:             initial value of the second stock
% rates:            rates between one simulation time and the other
% d1:               dividend yeld for the first stock
% d2:               dividend yeld for the second stock
% delta_times_365:  delta times between one simulation time and the other
% sigma:            matrix with standard deviations and correlation


% Initialize variables
S1 = zeros(M,length(delta_times_365)+1);
S2 = zeros(M,length(delta_times_365)+1);
S1(:,1) = S1_0;
S2(:,1) = S2_0;

% Simulate
rng(42)
for i = 1 : length(delta_times_365)
    z1 = randn(M,1);
    S1(:,i+1) = S1(:,i).*exp( (rates(i) - d1 - sigma(2,2)^2/2)*delta_times_365(i) + sqrt(delta_times_365(i))*sigma(2,2)*z1  );
    z2 = sigma(1,2)*z1 + sqrt(1-sigma(1,2)^2)*randn(M,1);
    S2(:,i+1) = S2(:,i).*exp( (rates(i) - d2 - sigma(1,1)^2/2)*delta_times_365(i) + sqrt(delta_times_365(i))*sigma(1,1)*z2  );
end

end