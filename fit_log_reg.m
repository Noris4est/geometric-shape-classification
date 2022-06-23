function [j_train_mean, j_cv_mean] = fit_log_reg(X_train,y_train,X_cv,y_cv,lambda,alpha)
   %формирование первого единичного столбца (нулевой единичный признак)

   n_max_iter = 10^5;
   delta_j_min = 1e-4;

   m_tr = size(X_train,1);
   if ~isequal(X_train(:,1),ones(m_tr,1))
       X_train_prep = ones(m_tr,size(X_train,2)+1);
       X_train_prep(:,2:end) = X_train;
   else
       X_train_prep = X_train;
   end
   m_cv = size(X_cv,1);
   if ~isequal(X_cv(:,1),ones(m_cv,1))
       X_cv_prep = ones(m_cv,size(X_cv,2)+1);
       X_cv_prep(:,2:end) = X_cv;
   else
       X_cv_prep = X_cv;
   end
   %X_cv и y_cv нужно для построения графиков обучения
   un_cl = unique(y_train);
   Nuc = numel(un_cl);
   n_pars = size(X_train_prep,2);
   teta_matrix = zeros(n_pars,Nuc);
   j_cv_sample = zeros(Nuc,n_max_iter);
   j_train_sample = zeros(Nuc,n_max_iter);
   n_iter_arr = zeros(1,Nuc);
   %один против всех
   for i = 1:Nuc
       cur_cl = un_cl(i);
       y_train_cur = y_train;
       y_train_cur(y_train_cur ~= cur_cl) = 0;
       y_train_cur(y_train_cur ~= 0) = 1;

       y_cv_cur = y_cv;
       y_cv_cur(y_cv_cur ~= cur_cl) = 0;
       y_cv_cur(y_cv_cur ~= 0) = 1;
       [teta,...
           n_iter_cur,...
           j_cv_no_reg,...
           j_train_no_reg] = fir_lr_binar( ...
           X_train_prep, ...
           y_train_cur, ...
           X_cv_prep, ...
           y_cv_cur, ...
           lambda, ...
           alpha, ...
           n_max_iter, ...
           delta_j_min);
       teta_matrix(:,i) = teta;
       j_cv_sample(i,:) = j_cv_no_reg;
       j_train_sample(i,:) = j_train_no_reg;
       n_iter_arr(i) = n_iter_cur;
       disp(strcat('Количество итераций на классе №',num2str(i),' = ',num2str(n_iter_cur)));
   end
   n_iter_max = max(n_iter_arr);
   j_cv_mean = mean(j_cv_sample,1);
   j_cv_mean = j_cv_mean(1:n_iter_max);
   j_train_mean = mean(j_train_sample,1);
   j_train_mean = j_train_mean(1:n_iter_max);
   %итогом записывается матрица параметров классификатора
   %столбцы - веса классификатора для каждого класса против всех
   writematrix(round(teta_matrix,5),'teta_matrix.txt');
end