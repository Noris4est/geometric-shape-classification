function teta_new = update_teta(teta,lambda,alpha,X,y_true)
%update teta params
m = size(X,1);
z = X*teta;
y_pred = 1./(1+exp(-z));
d_teta = zeros(size(teta));
d_teta(1) = alpha/m*sum((y_pred - y_true).*X(:,1));
for i = 2:numel(d_teta)
    d_teta_1 = alpha/m*sum((y_pred - y_true).*X(:,i));
    d_teta_2 = alpha*lambda/m*teta(i);
    d_teta(i) = d_teta_1 + d_teta_2;
end
teta_new = teta - d_teta;
end