function price = fix_price(price,x)
% Checks if price is admissable (not negative or complex)

for i=1:length(price)
    if imag(price(i))>1e-6 || real(price(i))<0
        price(i)
        fprintf('The price corresponding to %.2f log-moneyness is complex or negative', x(i) )
    else
        price(i) = real(price(i));
    end
end

end