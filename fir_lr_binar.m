function [teta,...
    n_iter,...
    j_cv_no_reg,...
    j_train_no_reg] = fir_lr_binar( ...
    X_train, ...
    y_train, ...
    X_cv, ...
    y_cv, ...
    lambda, ...
    alpha, ...
    n_max_iter, ...
    delta_j_min)
    %Входные параметры:
    % X_train, y_train - обучающая выборка и метки классов (2 класса)
    % X_cv, y_cv - кросс-валидационная выборка и метки классов
    % y_train и y_cv принимают значения 0 или 1.
    % lambda - коэффициент регуляризации - штраф за большие параметры 
    % lambda может принимать значения из 1e-3 ... 1e3
    % alpha - learning rate - скорость обучения : 1e-3 ... 1;

    n_params = size(X_train,2);
    m_samples = size(X_train,1);
    teta = -1 + 2*rand(n_params,1); % вектор столбец [-1;1]

    
    j_cv_no_reg = zeros(n_max_iter,1);
    j_train_no_reg = zeros(n_max_iter,1);
    n_iter = 1;
    flag = 1;

    while flag == 1
        j_new = calc_J(teta,lambda,X_train,y_train);
        j_cv_no_reg(n_iter) = calc_J(teta,0,X_cv,y_cv);
        j_train_no_reg(n_iter) = calc_J(teta,0,X_train,y_train);

        if n_iter ~= 1
            if abs(j_old-j_new)/j_old <= delta_j_min
                flag = 0;
            end
        end
        if n_iter == n_max_iter
            flag = 0;
        end
        if flag ==1 
            %teta = update_teta(teta,lambda,alpha,X_train,y_train);
            z = X_train*teta;
            y_pred = 1./(1 + exp(-z));
            teta_reg_shiht = [0;teta(2:end)];
            teta = teta - alpha/m_samples*X_train'*(y_pred-y_train) - ...
                lambda/m_samples*teta_reg_shiht;
            n_iter = n_iter + 1;
        end
        j_old = j_new;
    end
end