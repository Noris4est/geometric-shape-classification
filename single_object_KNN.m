function y_pred = single_object_KNN(X_train,y_train,K,x_test)

m_train = size(X_train,1);
L2_dist = zeros(1,m_train);%массив расстояний до каждого объекта X_train
for i = 1:m_train
    L2_dist(i) = sum((x_test - X_train(i,:)).^2,'all');%евклидова метрика
end

%находим аргументы K минимальных элементов массива L2_dist

index_arr = 1:numel(L2_dist);
% сортировка 
for i = 1:K
    for j = 1:numel(L2_dist)-1 
        if L2_dist(j)<L2_dist(j+1)
            buf = L2_dist(j);
            L2_dist(j) = L2_dist(j+1);
            L2_dist(j+1) = buf;

            buf = index_arr(j);
            index_arr(j) = index_arr(j+1);
            index_arr(j+1) = buf;
        end
    end
end

%классы ближайших элементов к x_test из X_train 
KNN_index = index_arr(end:-1:end-K+1); % 
K_nearest_classes = y_train(KNN_index);
unic_elems = unique(K_nearest_classes);
number_unic_elems = zeros(size(unic_elems));
for i = 1:numel(unic_elems)
    number_unic_elems(i) = sum(K_nearest_classes == unic_elems(i));
end
y_pred = unic_elems(number_unic_elems == max(number_unic_elems));
y_pred = y_pred(1);

end
