function [im_out,k_try] = create_geom_distortion_ellipse( ...
    im_size, ...
    Shape_area_part, ...
    relative_a_b, ...
    d_r_max_perc)

%im_size - размер генерируемого изображения
%Shape_area_part - доля площади объекта (эллипса) на изображении
%relative_a_b - соотношение большой (a) и малой (b) полуосей эллипса
%большая полуось горизонтальна
%априорная информация
N_min = 4; % минимальное количество точек
N_max = 10; % максимальное количестко точек

%d_r_max_perc = 1; % максимальное отклонение радиуса в % в случайных точках
%отклонение может быть в + и -. Задается в % от диагонали кадра.



%расчет
n = im_size(1);
m = im_size(2);
S_0 = n* m; %расет площади всего изображения
S_shape = Shape_area_part * S_0; %расчет площади фигуры
a_ha = sqrt(S_shape*relative_a_b/pi); %расчет большей полуоси (a half axis)
b_ha = a_ha/relative_a_b; %расчет меньшей полуоси (b_half_axis)
a_ha = round(a_ha);
b_ha = round(b_ha);
%проверка
if a_ha > im_size(2)/2
    disp('Большая диагональ выходит за границы изображения')
end
if b_ha > im_size(1)/2
    disp('Меньшая диагональ выходит за границы изображения')
end
r_max = a_ha; %максимальный радиус в полярной СК
safety_factor = 3; %коэффициент запаса
d_phi = round(1/(safety_factor * r_max),3); %шаг по углу
phi = 0:d_phi:2*pi; %массив угловых координат
%радиальные координаты номинальной фигуры до добавления геом. искаж
r0 = a_ha*b_ha./sqrt( (a_ha*sin(phi)).^2 + (b_ha*cos(phi)).^2 );

%формирование геометрических искажений
diag_pix = sqrt(n^2 + m^2); %размер диагонали

flag = 1;
N_points = randi([N_min, N_max]); %число случайных силовых точек отклонений
d_r_max = d_r_max_perc/100 * diag_pix; %максимальное отклонение по радиусу в пикселах
phi_extend = [phi-2*pi, phi, phi+2*pi];

%При формировании геометрических искажений могут возникать неудачи
%Повторям до успеха
k_try = 0;
while flag
    phi_dpp = pi*2*rand(1,N_points); %phi_distors_points_pos - угловые позиции точек
    phi_dpp = sort(phi_dpp);%сортировка по возрастанию (т.к. координаты)
    
    d_r_arr = -d_r_max + 2*d_r_max*rand(1,N_points); %Массив отклонений [-drmax drmax] 
    
    d_r_raw = [d_r_arr d_r_arr d_r_arr]; %Для выполнения условия гладкости при сшивании на краях метод брутфорса три подряд 
    phi_raw = [phi_dpp - 2*pi, phi_dpp, phi_dpp + 2*pi];
    
    d_r = interp1(phi_raw,d_r_raw,phi_extend,'spline'); %сплайн интерполяция
    
    d_r = d_r(numel(phi) + 1: numel(phi)*2); % извлечение центрального сегмента dr массива
    % проверка на выбросы после интерполяции. Коэф. запаса 2 (эмпирически)
    % и проверка на близость первого и последнего dr
    if numel(find(abs(d_r)>2*d_r_max)) == 0 
        if (d_r(1) - d_r(end))/d_r(1) < 0.05
            flag = 0;
        end
    end
    k_try = k_try + 1; % подсчет количества попыток
end

r_distor = r0 + d_r;
im = zeros(im_size);

i0 = round(n/2);
j0 = round(m/2);

i_rel = round( -r_distor.*sin(phi) ); %rel = relative относительно
j_rel = round( r_distor.*cos(phi) );

i_shape = i_rel + i0;
j_shape = j_rel + j0;

for t = 1:numel(i_shape)
    i_cur = i_shape(t);
    j_cur = j_shape(t);
    if CheckIndexValid(i_cur,j_cur,n,m)
        im(i_cur, j_cur) = 1;
    else
        disp('Фигура выходит за границы изображения')
    end
end
%{
Сформированный контур объекта может содержать разрывы в областях с высокой
крутизной (в этих областях радиус вектор имеет малый угол с кастаельной к
объекту). Для устранения разрывов применяется дилатация. Структурным
элементом выбирается окружность. Радиус подбирается эмпирически.
%}
rad_SE = 2; %Радиус структурного элемента
SE = create_circ_struct_el(rad_SE);%структурный элемент для дилатации
im_d = conv2(im,SE,'same');im_d = double(im_d>0); %дилатация
%{
для соответствия формату входных данных в функцию заливки объекта 
выполняется расчет дополненного изображения.
%}
im_d = imcomplement(im_d);
im_out = im_fill(im_d,i0,j0); %выходное изображение с заливкой

%компактная функция проверки корректности координат пикселов при вызове
function result = CheckIndexValid(i,j,n,m)
    if i>0 && i<=n && j>0 && j<=m
        result = 1;
    else
        result = 0;
    end
end

end