function y_pred = KNN_classification(X_train,y_train,K,X_test)
m_test = size(X_test,1);
y_pred = zeros(m_test,1);
%для каждого объекта, класс которого нужно предсказать
for i = 1:m_test
    y_pred(i) = single_object_KNN(X_train,y_train,K,X_test(i,:));
end