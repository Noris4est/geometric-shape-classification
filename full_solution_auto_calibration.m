clc
clear
close all

%используется автоматическа калибровка на фон
%cam = webcam;
%cam.Resolution = '1920x1080';
%im0 = snapshot(cam);
im0 = imread('full_solution_test/2.jpg');
%im0 = imread('special_shapes_no_rot_shift\star5\499.png');
%im0 = imread('shapes/triangle/345.png');
im0 = rgb2gray(im0);
im1 = double(im0);

%рамка субкадра
size_sf = [600 600]; % (width along j, height along i) subframe size
ImC = round(size(im1)/2); %image center
PLD = [ImC(2) - size_sf(2)/2, ImC(1) - size_sf(1)/2]; % (j,i) point left down

figure;
subplot(1,2,1);imshow(im0,[]);title('Исходное изобр. с кам. с рамкой');
rectangle('Position',[PLD(1) PLD(2) size_sf(2) size_sf(1)],...
         'LineWidth',1, ...
         'LineStyle','-', ...
         'EdgeColor','red');
subplot(1,2,2);imshow(im1,[]);title('Полутон. исх. изобр.');
rectangle('Position',[PLD(1) PLD(2) size_sf(2) size_sf(1)],...
         'LineWidth',1, ...
         'LineStyle','-', ...
         'EdgeColor','red');

im2 = imcrop(im1,[PLD(1) PLD(2) size_sf(2) size_sf(1)]);
figure; 
subplot(1,2,1);imshow(im2,[]);title('Выделенная ROI на изобр.');
im2_F = log(abs(fftshift(fft2(im2).^2))+1);
subplot(1,2,2);imshow(im2_F,[]);title('Спектр ROI');

%фильтрация шума
%в первую очередь фильтрация импульсного шума
im3 = medfilt2(im2,[3 3]);

%затем фильтрация шума по Гауссу
k_size = 0.07; % размер ядра в % от размера кадра
[n,m] = size(im2);
kernel_size = round(k_size*sqrt(m*n));
h = fspecial('gaussian',kernel_size,kernel_size/4);
im3 = imfilter(im3,h,'symmetric');
im3_F = log(abs(fftshift(fft2(im3).^2))+1);

figure;
subplot(1,3,1);imshow(im3,[]); title('фильтрованное изображение');
subplot(1,3,2);imshow(im3_F,[]); title('спектр ф. изобр.');
subplot(1,3,3);histogram(im3); title('гист. ф. изобр.')
xticks([0 50 100 150 200 250]);
xlim([0 250])

figure; imshow(im3,[]); title('неоткалиброванное изображение'); xlabel('x'); ylabel('y'); colorbar; colormap default;
figure; mesh(im3); title('неоткалиброванное изображение')

im4 = auto_calibration(im3);
figure; imshow(im4,[]);  title('откалиброванное изображение');xlabel('x'); ylabel('y');colorbar; colormap default;
figure; mesh(im4); title('откалиброванное изображение')


%определение лапласиана для определения грубого центра тяжести
h_lap = double(fspecial('laplacian'));
im4_L = abs(imfilter(im4,h_lap,'symmetric'));
figure; imshow(im4_L,[]);title('Несглаженный лаплас');
colorbar; colormap default;

h_sleek = fspecial('gaussian',25,9); %здесь можно поэксперементировать
im4_L = imfilter(im4_L,h_sleek,'symmetric');
im4_L1 = im4_L.*double(im4_L>0.5.*max(im4_L,[],'all'));
figure; imshow(im4_L,[]); title('Сглаж. лаплас.')
colorbar; colormap default;
figure; imshow(im4_L1,[]); title('Сглаж. усечен. лаплас');
colorbar; colormap default;



%расчет грубого центра тяжести

[i_c,j_c] = calc_E_center(im4_L1);
figure; 
subplot(1,2,1);imshow(im4,[]); title('изображение');
rectangle('Position',[j_c i_c 2 2],...
         'LineWidth',3, ...
         'LineStyle','-', ...
         'EdgeColor','red');
subplot(1,2,2);histogram(im4);


%определение оптимального порога бля бинаризации

%изображение двух сечений изображения через найденный энергетический центр

im_vert_cross = im4(:,j_c);
im_hor_cross = im4(i_c,:);
figure;
subplot(1,2,1);plot(im_vert_cross);
subplot(1,2,2);plot(im_hor_cross);

%бинаризация изображения
%ROI_search_minmax
% p1 = prctile(im4,3,'all');
% p2 = prctile(im4,97,'all');
% treshold = (p1+p2)/2;
im4 = histeq(im4);
T = adaptthresh(im4);
im5 = imbinarize(im4,T);
im5 = double(im5);
figure;
subplot(1,2,1);imshow(im5);
rectangle('Position',[j_c i_c 3 3],...
         'LineWidth',2, ...
         'LineStyle','-', ...
         'EdgeColor','red');
subplot(1,2,2);histogram(im5);

%заполнение изображения
tic
im6 = im_fill(im5,i_c,j_c); % на заполнение подается черный объект, выходит белый 
toc
tic
im6 = SelectAndFillMainShape(im5);
toc
[x,i_0,j_0,i_arr,j_arr] = single_feature_extraction_mod(im6,32);
x = SingleFeatureShift(x);
add_feature = calc_ratio_perimeter_to_root_area(x);
x = [x add_feature];

x_poly = generate_X_quad_features(x);
x_poly = [1 x_poly];
%message = Bayes_predict(x);

message = 1;
class_names = ["circle"; "square"; "triangle"; "star"];

figure;

imshow(im6);
hold on
rectangle('Position',[j_0 i_0 2 2],...
         'LineWidth',1, ...
         'LineStyle','-', ...
         'EdgeColor','red');
scatter(j_arr,i_arr,'red');

hold off
figure; plot(x,'LineWidth',2); ylim([0 1]); title(class_names(message));
