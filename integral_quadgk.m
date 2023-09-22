function integral = integral_quadgk(x, phi)
% Computes integral of the Lewis formula to obtain the call option price
% with quadgk
%
% INPUT:
% x:        log-moneyness grid
% phi:      characteristic function


% Discretization parameters
csi_min = -30;
csi_max = -csi_min;

% Compute f
f = @(csi,y) 1/(2*pi)*phi(-csi-1i/2)./(csi.^2+1/4).*exp(-1i*csi*y);

% Compute integral
integral = arrayfun(@(y) quadgk(@(csi) f(csi,y), csi_min, csi_max), x);


end