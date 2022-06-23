function [X,y] = feature_extraction(N_features,folder_name,class_names)

exts = [".jpg";".bmp";".png"];
% расчет необходивого количества строк в матрице признаков
% рассчитывается общее число изображений в исходном датасете

m = 0;
for i = 1:numel(class_names)
    c_name = class_names(i); % название текущего класса
    %расположение текущего класса
    class_folder_name = strcat(folder_name,'/',c_name,'/'); 
    %формирование массива ссылок на изображения текущего класса
    class_images = imageDatastore(class_folder_name,FileExtensions = exts);
    %подсчет количества объектов
    m = m + numel(class_images.Files);
end

X_all = zeros(m,N_features+1); % заготовка матрицы признаков
% +1 потому что еще один доп. признак.
y_all = zeros(m,1); %заготовка вектора - столбца - меток объектов
k = 1;

for j = 1:numel(class_names)
    c_name = class_names(j);
    class_folder_name = strcat(folder_name,'/',c_name,'/');
    class_images = imageDatastore(class_folder_name,FileExtensions = exts);
    for i = 1:numel(class_images.Files)
        im = readimage(class_images,i); % чтение изображения
        im = im_preprocessing(im); % simple предобработка изображения
        %извлечение признаков из изображения 
        [x_cur,~] = single_feature_extraction_mod(im,N_features); 
        if numel(find(x_cur == 0))>0
            message = strcat('Zero values in x vector. Class name:', ...
                c_name, ...
                '. image number:', ...
                num2str(i));
            disp(message);
            disp(class_images.Files(i));
        end
        x_cur = SingleFeatureShift(x_cur);%сдвиг признаков до глобального минимума для обеспечения квазиинвариантности к повороту фигуры
        additional_feature = calc_ratio_perimeter_to_root_area(x_cur);
        x_cur = [x_cur additional_feature];%добавление признака отношения периметра к корню из площади
        %запись признаков текущего объекта в матрицу признаков
        X_all(k,:) = x_cur;
        %запись номера класса объекта в вектор-столбец признаков
        y_all(k) = j;
        k = k + 1;
    end
end
%округление знчаений признаков
X = round(X_all,5);
y = round(y_all,5);
end

