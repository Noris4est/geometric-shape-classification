function im_out = create_geom_distortion_regular_poly( ...
    im_size, ...
    Shape_area_part, ...
    Nodes_Number, ...
    d_h_max_perc, ...
    d_ij_Nodes_max_perc)
%% Априорные параметры

N_min = 1; % минимальное количество точек (не включая две крайние по умолчанию 0)
N_max = 4; % максимальное количестко точек
%d_h_max_perc = 0.15; % максимальное отклонение координаты в случайных точках
%d_ij_Nodes_max_perc = 1;% максимальное отклонение координат вершин фигуры
%отклонение может быть в + и -. Задается в % от диагонали кадра.
n = im_size(1);
m = im_size(2);
S_0 = n* m; %расет площади всего изображения
S_shape = Shape_area_part * S_0; %расчет площади фигуры
a = sqrt(4*S_shape*tan(pi/Nodes_Number)/Nodes_Number); %длина стороны
R_external = a/(2*sin(pi/Nodes_Number));

if R_external > n/2 || R_external > m/2
    disp('Фигура выходит за границы изображения')
end
%% формирование номинальных координат многоугольника
i0 = round(n/2);
j0 = round(m/2);
d_phi = 2*pi/Nodes_Number;
phi_nodes = 0 : d_phi : 2*pi - d_phi; %угловые координаты вершин многоугольника
I_arr = - sin(phi_nodes)*R_external + i0;
J_arr = cos(phi_nodes)*R_external + j0;
I_arr = round(I_arr);
J_arr = round(J_arr);
%% формирование погрешности положения вершин
diag_pix = sqrt(n^2 + m^2);
d_ij_Nodes_max = d_ij_Nodes_max_perc / 100 * diag_pix;

dI_arr = round(-d_ij_Nodes_max + 2*d_ij_Nodes_max*rand(1,Nodes_Number));
dJ_arr = round(-d_ij_Nodes_max + 2*d_ij_Nodes_max*rand(1,Nodes_Number));

I_dist = I_arr + dI_arr;
J_dist = J_arr + dJ_arr;
%% вычисление углов 
alpha = zeros(1,Nodes_Number); %углы при одноименных вершинах
vec12 = form_vec(I_dist,J_dist,1,2);%вектор от точки 1 к точке 2.
vec14 = form_vec(I_dist,J_dist,1,Nodes_Number);
alpha(1) = calc_angle_betw_vecs(vec12,vec14);

for k = 2:Nodes_Number - 1
    vec_front = form_vec(I_dist,J_dist,k,k+1);%передний при обходе
    vec_back = form_vec(I_dist,J_dist,k,k-1);
    alpha(k) = calc_angle_betw_vecs(vec_front,vec_back);
end

vec_N_to_1 = form_vec(I_dist,J_dist,Nodes_Number,1);
vec_N_to_prev = form_vec(I_dist,J_dist,Nodes_Number,Nodes_Number - 1);
alpha(Nodes_Number) = calc_angle_betw_vecs(vec_N_to_1,vec_N_to_prev);
%% Формирование заготовки изображения
im = zeros(im_size);
%% формирование погрешности положения промежуточных точек
safety_factor = 3; %коэффициент запаса
d_l = 1/safety_factor; %шаг в направлении векторов при построении ребер
d_h_max = d_h_max_perc/100*diag_pix;
%обход всех ребер (прямоугольник - 4 ребра). Обход по часовой стрелке.
for k = 1:Nodes_Number %!!!
    p1 = [I_dist(k) J_dist(k)]; %первая точка рассм. ребра
    alpha1 = alpha(k); %первый примыкающий угол
    if k+1<=Nodes_Number % у последнего ребра вторая точка в общем порядке стоит первой
        p2 = [I_dist(k+1) J_dist(k+1)];
        alpha2 = alpha(k+1);
    else
        p2 = [I_dist(1) J_dist(1)];
        alpha2 = alpha1(1);
    end
    L_cur = distance(p1,p2); %расстояние между точками p1 и p2
    p_arr = PointsSpace(p1,p2,d_l); % массив точек между p1 и p2 с шагом d_l
    N_points = randi([N_min, N_max]); %число случайных точек
    %по этим точка будет осуществляться сплайн-интерполяция
    
    flag = 1; %индикатор для поддержания цикла с заранее неизвестным числом повторений
    while flag
        %при формировании случайных позиций могут встретиться нули
        %для этого диапазон изменен. pos прин. знач. в диап. : [0.2 0.8] * L_cur.
        %ребро рассматривается как ось X, а отклонения профиля явл. d_h.
        pos = 0.2 + 0.6 * rand(1,N_points); %относительные силовых положения точек
        pos = [0 sort(pos) 1];
        pos = pos*L_cur;%приведенные положения силовых точек
        d_h = -d_h_max + 2*d_h_max*rand(1,N_points); %Массив отклонений [-dhmax dhmax]
        d_h = [0 d_h 0]; %дополненный массив
        x_arr = linspace(0,L_cur,size(p_arr,1)); %плотная сетка вдоль оси ребра
        d_h_arr = interp1(pos,d_h,x_arr,'spline'); %профиль отклонения ребра на плотной сетке
        %отклонения не должны выходить за ограничения - биссектриссы примыкающих углов
        %уравнения биссектрисс выводятся и записываются снизу.
        %значения ординаты биссектрисс также определяется на сетке x_arr
        k1 = -tan(alpha1/2); 
        k2 = tan(alpha2/2);
        y1 = k1*x_arr;
        y2 = -L_cur*k2 + x_arr*k2;
        
    

        %проверка: d_h_arr должен быть выше y1,y2 везде 
        %кроме первой и последней точки
        %также отклонения профиля не должны превышать 2*d_h_max
        %(эмпирически приблизительно посчитанно)
        check1 = numel(  find( y1(2:end-1) > d_h_arr(2:end-1) ) ) == 0;
        check2 = numel(  find( y2(2:end-1) > d_h_arr(2:end-1) ) ) == 0;
        check3 = numel(  find( abs(d_h_arr) > 2*d_h_max ) ) == 0;
        if check1*check2*check3 == 1
            flag = 0; %при выполн. 3х услов. осуществляется выход из цикла
        end
        %Визуализация
%         figure;
%         hold on
%         plot(x_arr,d_h_arr,'black');
%         plot(x_arr,y1,'g');
%         plot(x_arr,y2,'b');
%         scatter(pos,d_h,'color','orange');
%         hold off
%         if flag
%             message = 'bad';
%         else
%             message = 'good';
%         end
%         title(message);
    end
    %{
    Определение орта вектора, нормального к текйщему ребру
    и направленного от центра геом.фигуры
    %}
    vec_edge = p2-p1;%вектор сонаправленный ребру
    vec_edge_unit = vec_edge/sqrt(sum(vec_edge.^2));%орт вектора
    norm_unit = [-vec_edge_unit(2),vec_edge_unit(1)];%нормаль к орту ребра
   
    p_mid = (p1+p2)/2;
    %вектор от центра фигуры к центру текущего ребра
    vec_ceter_to_edge_mid = [p_mid(1) - i0, p_mid(2) - j0];
    %если скалярное произведение отрицательно, разворачиваем вектор
    if sum(norm_unit.*vec_ceter_to_edge_mid)<0
        norm_unit = - norm_unit;
    end
    %из каждой точки в напр. нормали к ребру строятся вектора отклонений
    %dist = distortion (искажение)
    p_arr_dist = p_arr + [norm_unit(1)*d_h_arr',norm_unit(2)*d_h_arr'];
    p_arr_dist = round(p_arr_dist);
    %запись полученных координат в матрицу изображения с проверкой
    for kk = 1:size(p_arr,1)
        i_cur = p_arr_dist(kk,1);
        j_cur = p_arr_dist(kk,2);
        if CheckIndexValid(i_cur,j_cur,n,m)
            im(i_cur,j_cur) = 1;
        else
            disp('Фигура выходит за границы изображения')
        end
    end
end
%% Морфологическая обработка
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
im_dc = imcomplement(im_d);
im_out = im_fill(im_dc,i0,j0); %выходное изображение с заливкой
%% доп. функции
function result = CheckIndexValid(i,j,n,m)
    if i>0 && i<=n && j>0 && j<=m
        result = 1;
    else
        result = 0;
    end
end

function vec = form_vec(I,J,n1,n2)
    vec = [I(n2) - I(n1), J(n2) - J(n1)];
end

function angle = calc_angle_betw_vecs(vec1,vec2)
    L1 = sqrt(sum(vec1.^2));%нормы векторов
    L2 = sqrt(sum(vec2.^2));
    prod = vec1*vec2';
    angle = acos(prod/L1/L2);
end

%вычисление расстояния между точками
function d = distance(p1,p2)
    d = sqrt(sum((p1-p2).^2));
end

    function P_arr = PointsSpace(p1,p2,step)
    d12 = distance(p1,p2);
    N = round(d12/step) +1;
    
    if p1(1) ~= p2(1)
        i_arr = linspace(p1(1),p2(1),N);
    else
        i_arr =  p2(1)*ones(1,N);
    end

    if p1(2) ~= p2(2)
        j_arr = linspace(p1(2),p2(2),N);
    else
        j_arr = p2(2)*ones(1,N);
    end

    P_arr = [i_arr',j_arr'];
end
end