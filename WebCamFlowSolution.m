clc
clear
close all

cam = webcam;

CamResolution = [640 480];
CamResStr = strcat(num2str(CamResolution(1)), ...
    'x', ...
    num2str(CamResolution(2)));

cam.Resolution = CamResStr;% WxH
%preview(cam)

flag = 1;
load TreeMLmodel.mat
load SVMmodel.mat
load RandForestModel.mat
load X_train.mat
load y_train.mat

size_sf = [300 300]; % (width along j, height along i) subframe size
k_size = 0.02; % размер ядра фильтрации гаусса в % от размера кадра
h_sleek = fspecial('gaussian',25,9); %здесь можно поэксперементировать
laplas_treshold = 0.5; %пороговый коэффициент карты лапласиана для центра тяжести
K_NearestNeighbors = 3; % К ближайших соседей для KNN классификатора
class_names = ["circle"; "square"; "triangle"; "star5"; "hexagon"];

ImC = round(CamResolution/2); %image center
PLD = [ImC(2) - size_sf(2)/2, ImC(1) - size_sf(1)/2]; % (j,i) point left down

h_lap = double(fspecial('laplacian'));
kernel_size = round(k_size*sqrt(size_sf(1)*size_sf(2)));
h_gauss = fspecial('gaussian',kernel_size,kernel_size/4);
figure;
while flag
    im0 = snapshot(cam); %Получение исходного кадра
    %% Предобработка изображения - Image preprocessing
    im1 = rgb2gray(im0);
    im1 = double(im1);
    %рамка субкадра (ROI)
    im2 = imcrop(im1,[PLD(1) PLD(2) size_sf(2) size_sf(1)]); 
    %size(im2) ~= size_sf в общем случае. Бывают откл. +/- пиксел.
    [n,m] = size(im2);
    %фильтрация шума
    %в первую очередь фильтрация импульсного шума
    im3 = medfilt2(im2,[3 3]);
    %затем фильтрация шума по Гауссу
    im4 = imfilter(im3,h_gauss,'symmetric');
    im5 = auto_calibration(im4);%калибровка неравноверности облученности
    %определение лапласиана для определения грубого центра тяжести
    im5_L = abs(imfilter(im5,h_lap,'symmetric'));
    im5_LS = imfilter(im5_L,h_sleek,'symmetric');
    im5_LT = im5_LS.*double(im5_LS>laplas_treshold*max(im5_LS,[],'all'));

    %расчет грубого центра тяжести
    [i_c,j_c] = calc_E_center(im5_LT);

    %бинаризация изображения
    % Фильтрация выбросов через поправку на процентили (не (min+max)/2)
%     p1 = prctile(im5,3,'all');
%     p2 = prctile(im5,97,'all');
%     treshold = (p1+p2)/2; %расчет порога
%     im6 = double(im5>treshold); %бинаризация
    im5 = histeq(im5);
    T = adaptthresh(im5);
    im6 = imbinarize(im5,T);
    im6 = double(im6);
    % Сегментация (селекция) главной геометрической фигуры на изображении и заполнение изображения
    im7 = SelectAndFillMainShape(im6);
    %im7 = im_fill(im6,i_c,j_c);
    %% Извлечение признаков - Feature extraction
    [x,i_0,j_0,i_arr,j_arr] = single_feature_extraction_mod(im7,32);
    %% Предобработка признаков - Feature preprocessing
    x = SingleFeatureShift(x);%Циклический сдвиг вектора признаков
    %создавние сильного признака из имеющихся - отношение периметра к корню
    additional_feature = calc_ratio_perimeter_to_root_area(x);
    x = [x additional_feature];
    %% Формирование полиномиальных признаков - Make Polynomial
    %x_poly = generate_X_quad_features(x);     
    %x_poly = [1 x_poly];
    %% Предсказание - Predict
    BayesNoPolyPred = Bayes_predict(x); % pred - prediction
    TreeNoPolyPred = predict(TreeMLmodel, x);
    SVM_NoPolyPred = predict(SVMmodel, x);
    RandForestNoPolyPred = round(predict(RandForestModel, x));
    if RandForestNoPolyPred <= 0
        RandForestNoPolyPred = 1;
    end
    if RandForestNoPolyPred > numel(class_names)
        RandForestNoPolyPred = numel(class_names);
    end
    KNN_NoPolyPred = KNN_classification(X_train,y_train,K_NearestNeighbors,x);

    %для predict лог.рег. нужно добавлять "нулевой" признак единицу
    LogRegNoPoly = predict_log_reg([1 x]);
    %% Визуализация
    subplot(2,3,1); imshow(im1,[]);title('Полут. исх. изобр.');
    rectangle('Position',[PLD(1) PLD(2) size_sf(2) size_sf(1)],...
             'LineWidth',1, ...
             'LineStyle','-', ...
             'EdgeColor','red');
    subplot(2,3,2); imshow(im4,[]);title('Фильтр. изобр.');
    subplot(2,3,3); imshow(im5,[]);title('Калибр. изобр.');
    hold on
    if CheckIndexValid(i_c,j_c,n,m)
        scatter(j_c,i_c,'green');
    end
    hold off
    subplot(2,3,4);imshow(im6);title('Бинариз. изобр.');
    subplot(2,3,5);imshow(im7); title('Заполн. изобр.');
    hold on
    if CheckIndexValid(j_0,i_0,n,m)
        rectangle('Position',[j_0 i_0 2 2],...
             'LineWidth',1, ...
             'LineStyle','-', ...
             'EdgeColor','red');
    end
    scatter(j_arr,i_arr,'red');
    hold off
    subplot(2,3,6);plot(x); ylim([0 1]);title({ ...
        strcat("Bayes no poly: ",num2str(class_names(BayesNoPolyPred))), ...
        strcat("Tree no poly: ",num2str(class_names(TreeNoPolyPred))), ...
        strcat("SVM no poly: ",num2str(class_names(SVM_NoPolyPred))), ...
        strcat("RandForest no poly: ",num2str(class_names(RandForestNoPolyPred))), ...
        strcat("KNN no poly: ",num2str(class_names(KNN_NoPolyPred))), ...
        strcat("LogReg no poly: ",num2str(class_names(LogRegNoPoly)))...
        });
    
end
function result = CheckIndexValid(i,j,n,m)
    if i>0 && i<=n && j>0 && j<=m
        result = 1;
    else
        result = 0;
    end
end
