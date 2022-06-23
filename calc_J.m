function  j_val = calc_J(teta,lambda,X,y_true)
m = size(X,1);

z = X*teta;

y_pred = 1./(1+exp(-z));
j_1 = -1/m*sum(y_true.*log(y_pred) + (1-y_true).*log(1-y_pred));
j_2 = lambda/2/m*sum(teta(2:end).^2);
j_val = j_1+j_2;
end