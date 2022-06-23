function y_pred = create_predict_lr(X)
teta = readmatrix('teta.txt');
z = X*teta;
y_pred = round(double(1./(1+exp(-z))>0.5));
end