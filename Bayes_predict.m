function y_pred = Bayes_predict(X_test)
    mu = readmatrix('BayesMu.txt');
    sigma = readmatrix('BayesSigma.txt');
    p_aprior = readmatrix('BayesP.txt');

    n_cl = size(mu,1); % number of classes
    n_f = size(mu,2); % number of features

    m = size(X_test,1);
    y_pred = zeros(m,1);
    %определеям p(x|y_i) для каждого класса i и берем argmax
    for k = 1:m
        x_test = X_test(k,:);
        p_arr = ones(1,n_cl); %массив веронтятностей
        for i = 1:n_cl
            for j = 1:n_f
                p_arr(i) = p_arr(i)*exp(-(x_test(j)-mu(i,j))^2/2/sigma(i,j)^2)/sigma(i,j);
            end
        end
        p_arr = p_arr.*p_aprior;
        %disp(p_arr);
        k_arr= find(p_arr == max(p_arr));
        y_pred(k) = k_arr(1);
    end
end