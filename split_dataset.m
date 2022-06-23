function [X_train,X_cv,X_test,y_train,y_cv,y_test] = split_dataset(X,y,n_obj_in_class,proportions)
% proportions - вектор пропорций вида [n_train, n_cv, n_test]
proportions = proportions/sum(proportions); % нормирование вектора пропорций

m_train = round(n_obj_in_class*proportions(1));
%{
m_train - "m train objects single class" 
Количеество объектов одного класса в тренировочной подвыборке
%}

m_cv = round(n_obj_in_class*proportions(2));
%{
m_cv - "m cross validation objects single class" 
Количеество объектов одного класса в валидационной подвыборке
%}

m_test = round(n_obj_in_class*proportions(3));
%{
m_cv - "m test objects single class" 
Количеество объектов одного класса в тестовой подвыборке
%}

cl_arr = unique(y); %массив меток классов
n_cl = numel(cl_arr);
n_f = size(X,2);% количество признаков

X_train = zeros(n_cl*m_train,n_f); % заготовки подвыборок
X_cv = zeros(n_cl*m_cv,n_f);
X_test = zeros(n_cl*m_test,n_f);

y_train = zeros(n_cl*m_train,1);
y_cv = zeros(n_cl*m_cv,1);
y_test = zeros(n_cl*m_test,1);

for i = 1:numel(cl_arr)
    i_arr= find(y == cl_arr(i)); % массив индексов элементов i-го класса в датасете
    m_cur = numel(i_arr); % количество элементов i-го класса в датасете
    if n_obj_in_class>m_cur
        message = strcat('Количество элементов класса №',num2str(i),'=',num2str(m_cur),'это меньше, чем задано параметром n_obj_in_class');
        disp(message)
        break
    else
        i_arr = i_arr(randperm(m_cur)); %перемешивание индексов i-го класса

        i_train = i_arr(1:m_train); %индексы тренировочного субсета - часть от общих индексов
        i_cv = i_arr(m_train+1:m_train+m_cv);
        i_test = i_arr(m_train+m_cv+1:m_train+m_cv+m_test);
        
        X_train(1+(i-1)*m_train:i*m_train,:) = X(i_train,:);
        X_test(1+(i-1)*m_test:i*m_test,:) = X(i_test,:);
        X_cv(1+(i-1)*m_cv:i*m_cv,:) = X(i_cv,:);

        y_train(1+(i-1)*m_train:i*m_train) = cl_arr(i);
        y_test(1+(i-1)*m_test:i*m_test) = cl_arr(i);
        y_cv(1+(i-1)*m_cv:i*m_cv) = cl_arr(i);

        %{
        if i == 1
            X_train = X(cur_train_index,:);
            X_cv = X(cur_cv_index,:);
            X_test = X(cur_test_index,:);
    
            y_train = y(cur_train_index);
            y_cv = y(cur_cv_index);
            y_test = y(cur_test_index);
        else
            X_train = [X_train;X(cur_train_index,:)];
            X_cv = [X_cv;X(cur_cv_index,:)];
            X_test = [X_test;X(cur_test_index,:)];
    
            y_train = [y_train; y(cur_train_index)];
            y_cv = [y_cv; y(cur_cv_index)];
            y_test = [y_test; y(cur_test_index)];
        end
        %}
    end
end
%перемешиваем train, cv и test выборки внутри самих себя
m_train_0 = numel(y_train);
train_shuffle_index = randperm(m_train_0);
y_train = y_train(train_shuffle_index);
X_train = X_train(train_shuffle_index,:);

m_cv_0 = numel(y_cv);
cv_shuffle_index = randperm(m_cv_0);
y_cv = y_cv(cv_shuffle_index);
X_cv = X_cv(cv_shuffle_index,:);

m_test_0 = numel(y_test);
test_shuffle_index = randperm(m_test_0);
y_test = y_test(test_shuffle_index);
X_test = X_test(test_shuffle_index,:);


end