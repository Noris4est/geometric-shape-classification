function y_pred = predict_log_reg(X)

m = size(X,1);
if ~isequal(X(:,1),ones(m,1))
   X_prep = ones(m,size(X,2)+1);
   X_prep(:,2:end) = X;
else
   X_prep = X;
end

teta_matrix = readmatrix('teta_matrix.txt');
Z_pred = X_prep*teta_matrix;
Y_pred = 1./(1+exp(-Z_pred));
m = size(X,1);
y_pred = zeros(m,1);
for i = 1:m
    row_pred = Y_pred(i,:);
    y_pred(i) = find(row_pred == max(row_pred));
end

end