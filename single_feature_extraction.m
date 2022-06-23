function x = single_feature_extraction(im,N)
% im - исходное изображение; N - число признаков
%% определение энергетического центра фигуры на изображении
im_h = size(im,1);
im_w = size(im,2);
i_vector = 1:im_h;
j_vector = 1:im_w;
i_matrix = repmat(i_vector',1,im_w);
j_matrix = repmat(j_vector,im_h,1);
Shape_area = sum(im,'all');
i_0 = sum(i_matrix.*im,'all')/Shape_area;
i_0 = int16(i_0);
j_0 = sum(j_matrix.*im,'all')/Shape_area;
j_0 = int16(j_0);
%% выделение признаков (feature extraction)
%признаки - отсчеты в полярной системе координат до оболочки фигуры 
d_angle = 2*pi/N; %угловой шаг
d_t = 1; %линейный шаг вектора
L_arr = zeros(1,N);%массив расстояний до края фигуры 
Angle_arr = 0 : d_angle : 2*pi - d_angle; %массив векторов
cos_angle = cos(Angle_arr);%массив косинусов углов для оптимизации
sin_angle = sin(Angle_arr);%масив синусов углов
for i = 1:N
    flag = 1;
    t = 0;
    while flag
        %увеличение t в цикле до момента выхода за границы фигуры
        i_cur = int16(i_0 - t*sin_angle(i));
        j_cur = int16(j_0 + t*cos_angle(i));
        if im(i_cur,j_cur) ~= 1
            flag = 0;
            L_arr(i) = t;
        end
        t = t + d_t;
    end
end
x = L_arr/max(L_arr); % нормирование признаков на размер фигуры
end