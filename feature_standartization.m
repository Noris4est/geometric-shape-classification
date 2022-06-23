function X_out = feature_standartization(X_in)
% центроровка и нормирование признаков
% итерация по столбцам, расчет среднего и СКО
for j = 1:size(X_in,2)
    col = X_in(:,j);
    mu = mean(col); %среднее значение
    sigma = std(col); %СКО
    X_in(:,j) = (X_in(:,j) - mu)/sigma;
end
X_out = X_in;
end