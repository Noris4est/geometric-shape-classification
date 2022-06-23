function Bayes_fit(X_train,y_train)

%наивный байес fit
classes = sort(unique(y_train));
n_classes = numel(classes);
n_fetures = size(X_train,2);

%по столбцам признаки, по строкам классы
mu_matrix = zeros(n_classes,n_fetures);
sigma_matrix = zeros(size(mu_matrix));
class_population = zeros(1,numel(classes));

for i = 1:n_classes
    Xclass = X_train(y_train == classes(i),:);
    class_population(i) = size(Xclass,1);
    for j = 1:n_fetures
        col = Xclass(:,j);
        mu = mean(col);
        sigma = std(col);
        mu_matrix(i,j) = mu;
        sigma_matrix(i,j) = sigma;
    end
end

class_p = class_population/sum(class_population);
class_p = round(class_p,3);
mu_matrix = round(mu_matrix,3);
sigma_matrix = round(sigma_matrix,3);
writematrix(mu_matrix,'BayesMu.txt');
writematrix(sigma_matrix,'BayesSigma.txt');
writematrix(class_p,'BayesP.txt');
end