function OutputImg = SelectAndFillMainShape(InputImg)
    %% Описание формата вх. и вых данных
    %Вход - бинар. double изобр., фигура ч. внутри 
    %Выход - утолщенный контур (дилат. 3х3) главной геом фигуры - бин. изобр.
    
    %% Определение всех контуров
    CM = contourc(InputImg, 1); % CM - Contour Matrix
    %CM = imcontour(InputImg, 1);
    %% Определение числа контуров 
    NumContours = 0; %Numbers of contours
    j = 1;
    while j < size(CM,2)
        j = j + CM(2,j) + 1;
        NumContours = NumContours + 1;
    end
    %% Опр. старт. индекса и количества точек контуров
    StInd_and_NumP = zeros(2,NumContours);%Start Index and Number of Points
    j = 1;
    k = 1;
    while j < size(CM,2)
        StInd_and_NumP(1,k) = j + 1;
        StInd_and_NumP(2,k) = CM(2,j);
        j = j + CM(2,j) + 1;
        k = k + 1;
    end

    %% Отбор контуров по признаку минимально допустимого кол-ва элементов
    Nmin = 100;
    StInd_and_NumP = StInd_and_NumP(:,StInd_and_NumP(2,:) > Nmin);
    NumContours = size(StInd_and_NumP,2);
    ActiveContoursIndexArr = 1:NumContours;
    PerimeterArr = zeros(1,NumContours);

    %% Отбор контуров по признаку их замкнутости
    delta_max_perc = 2; % Максимальное расстояние между первой и последней точкой не более 2% диагонали кадра
        
    nIm = size(InputImg,1);%разрешение изображения
    mIm = size(InputImg,2);

    diagImg = sqrt(nIm^2 + mIm^2);
    LenMax = diagImg*delta_max_perc/100;
    IsClosedContourArr = zeros(1,NumContours);
    for i = 1:NumContours
        CurStInd_and_NumP = StInd_and_NumP(:,i);
        i0 = CurStInd_and_NumP(1);
        N0 = CurStInd_and_NumP(2);

        xFirst = CM(1,i0);
        yFirst = CM(2,i0);

        xLast = CM(1,i0 + N0 - 1);
        yLast = CM(2,i0 + N0 - 1);

        dx = xLast - xFirst;
        dy = yLast - yFirst;

        LenFirstLast = sqrt(dx^2 + dy^2);
        IsClosedContourArr(i) = LenFirstLast < LenMax;
    end
    IsClosedContourArr = logical(IsClosedContourArr);
    ActiveContoursIndexArr = ActiveContoursIndexArr(IsClosedContourArr);
    TrueStInd_and_NumP = StInd_and_NumP(:,IsClosedContourArr);
    %% Отбор контуров по признаку Black->White (Внутри Ч, снаружи Б)
    GxOp = [-1, 0, 1;
            -2, 0, 2;
            -1, 0, 1];  %Gradient along axis X Operator 
    GyOp = [-1, -2, -1;
             0,  0,  0;
             1,  2,  1]; %Gradient along axis Y Operator 
    %Исходное изображение double
    Gx = imfilter(InputImg,GxOp,'symmetric'); %Карта градиента по оси X, Y
    Gy = imfilter(InputImg,GyOp,'symmetric'); 
    
    IsBlackInsideArr = zeros(1,size(TrueStInd_and_NumP,2)); %Метки контуров, что внутри Ч, снаружи Б

    num_p_on_cont = 50;%Количество точек на контур
    dh_grad = 2; %сдвиг в направлении градиента
    
    %Итерация контуров 
    for i = 1:size(TrueStInd_and_NumP,2)
        CurStInd_and_NumP = TrueStInd_and_NumP(:,i);
        i0 = CurStInd_and_NumP(1);
        N0 = CurStInd_and_NumP(2);
        step_co = floor(N0/num_p_on_cont); %шаг между отсчетами в контурах
        if step_co == 0
            step_co = 1;
        end
        OrigContour = CM(:,i0:step_co:i0+N0-1)';
        ShiftContour = zeros(size(OrigContour));
        %Обход i-го по выделенным точкам и паралл. форм. сдвинутого конт.
        for j = 1:size(OrigContour,1)
            xc = round(OrigContour(j,1));
            yc = round(OrigContour(j,2));
            gx = Gx(yc,xc); % x -> j; y -> i
            gy = Gy(yc,xc);
            L2 = sqrt(gx^2 + gy^2); %vector length
            vec = [gx,gy];
            if L2 ~= 0
                vec = vec/L2*dh_grad;%приведение длины вектора
            else
                vec = [0 0];
            end
            ShiftContour(j,:) = OrigContour(j,:) + vec;
        end
        % Визуализация
%         figure;
%         imshow(InputImg);
%         hold on
%         scatter(OrigContour(:,1),OrigContour(:,2), ...
%             'SizeData',3, ...
%             'DisplayName','Original contour');
%         scatter(ShiftContour(:,1),ShiftContour(:,2), ...
%             'SizeData',3, ...
%             'DisplayName','Shift contour');
%         hold off
%         title(num2str(ActiveContoursIndexArr(i)));
%         legend()
        %Расчет периметров Orig и Shift контуров
        P_orig = calc_perim_contour(OrigContour);
        PerimeterArr(i) = P_orig;
        P_shift = calc_perim_contour(ShiftContour);
        IsBlackInsideArr(i) = P_orig < P_shift; 
    end
    % Отбор контуров по признаку
    IsBlackInsideArr = logical(IsBlackInsideArr);
    TrueStInd_and_NumP = TrueStInd_and_NumP(:,IsBlackInsideArr); 
    ActiveContoursIndexArr = ActiveContoursIndexArr(IsBlackInsideArr);
    PerimeterArr = PerimeterArr(IsBlackInsideArr);
    %% Проверка на квазивыпуклость
    %Базовые настройки 
    N_vecs = 16; %Чесло векторов
    dTeta = 2*pi/N_vecs; % Угловой шаг
    dl = 2; % линейный шаг вдоль вектора
    
    Teta  = 0 : dTeta : 2*pi - dTeta;
    sTeta = sin(Teta); % массив синусов углов для оптимизации расчетов
    cTeta = cos(Teta);
    
    IsConvexContourArr = zeros(1, size(TrueStInd_and_NumP,2));
    %Обход всех True контуров
    for i = 1:size(TrueStInd_and_NumP,2)
        %Стартовый индекс и количество точек текущего контура
        CurStInd_and_NumP = TrueStInd_and_NumP(:,i);
        i0 = CurStInd_and_NumP(1);
        N0 = CurStInd_and_NumP(2);
        %Дилатация
        OrigContour = round(CM(:,i0:i0+N0-1)');
        DilatContour = vector_dilatation_SE33(OrigContour);
        %Перенос вектора точек на матрицу (изобр)
        %перенесение вектора точек на изображение
        CurIm = zeros(size(InputImg));
        for j = 1:size(DilatContour,1)
            xc = DilatContour(j,1);
            yc = DilatContour(j,2);
            if CheckIndexValid(yc,xc,size(CurIm,1),size(CurIm,2))
                CurIm(yc,xc) = 1;
            end
        end
        %определение ЭЦ тяжести
        [i0cur,j0cur] = calc_E_center(CurIm);
        NumRiseEdgeArr = zeros(1,N_vecs);

        for j = 1:N_vecs %по всем углам - направлениям
            l = 0; %начальное значенеи длины вектора
            NumRiseEdge = 0;%число краев перехода 0->1
            newVal = 0;
            oldVal = 0;
            while 1
                i_cur = int16(i0cur - l*sTeta(j));
                j_cur = int16(j0cur + l*cTeta(j));
                if CheckIndexValid(i_cur,j_cur,nIm,mIm)
                    newVal = CurIm(i_cur,j_cur);
                    if newVal == 1 && oldVal == 0 %Rise edge
                        NumRiseEdge = NumRiseEdge + 1;
                    end
                else
                    break
                end
                oldVal = newVal;
                l = l + dl;
            end
            NumRiseEdgeArr(j) = NumRiseEdge;
            if NumRiseEdge > 1
                break
            end
        end
        IsConvexContourArr(i) = sum(NumRiseEdgeArr>1) == 0;
    end
    IsConvexContourArr = logical(IsConvexContourArr);
    TrueStInd_and_NumP = TrueStInd_and_NumP(:,IsConvexContourArr);
    ActiveContoursIndexArr = ActiveContoursIndexArr(IsConvexContourArr);
    PerimeterArr = PerimeterArr(IsConvexContourArr);
    %% Выбор контура из индексов ActiveContoursIndexArr с max периметром
    if numel(ActiveContoursIndexArr) ~= 0
        LocIndMainContour = find(PerimeterArr == max(PerimeterArr));
        LocIndMainContour = LocIndMainContour(1); % на всякий случай
        MainContStInd_and_NumP = TrueStInd_and_NumP(:,LocIndMainContour);
        i0 = MainContStInd_and_NumP(1);
        N0 = MainContStInd_and_NumP(2);
        %Дилатация
        MainContour = round(CM(:,i0:i0+N0-1)');
        DilatContour = vector_dilatation_SE33(MainContour);
        %Перенос вектора точек на матрицу (изобр)
        %перенесение вектора точек на изображение
        OutputImg = zeros(size(InputImg));
        for j = 1:size(DilatContour,1)
            xc = DilatContour(j,1);
            yc = DilatContour(j,2);
            if CheckIndexValid(yc,xc,size(CurIm,1),size(CurIm,2))
                OutputImg(yc,xc) = 1;
            end
        end
        %определение ЭЦ тяжести
        [i0,j0] = calc_E_center(OutputImg);
        shape_color = 1;% цвет контура вх. фигуры - "1".
        %figure;imshow(OutputImg);
        OutputImg = im_fill_custom(OutputImg,i0,j0,shape_color);
    else
        OutputImg = InputImg;
    end
    
    %% Доп. функции
    function result = CheckIndexValid(i,j,n,m)
        if i>0 && i<=n && j>0 && j<=m
            result = 1;
        else
            result = 0;
        end
    end
end