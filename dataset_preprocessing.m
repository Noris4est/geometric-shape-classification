function dataset_preprocessing(orig_folder_name, new_folder_name, class_names)

exts = [".jpg";".bmp";".png"];
k_size = 0.15; % размер ядра в % от размера кадра


if ~exist(new_folder_name, 'dir')
       mkdir(new_folder_name)
end
for j = 1:numel(class_names)
    c_name = class_names(j);
    new_cl_fol_dir = strcat(new_folder_name,'/',c_name);
    if ~exist(new_cl_fol_dir, 'dir')
       mkdir(new_cl_fol_dir)
    end
    class_folder_name = strcat(orig_folder_name,'/',c_name,'/');
    class_images = imageDatastore(class_folder_name,FileExtensions = exts);
    k_img = 1;
    for i = 1:numel(class_images.Files)
        im = readimage(class_images,i); % чтение изображения
        if numel(size(im)) == 3
            im = rgb2gray(im);
        end
        im = im2double(im);
        [n,m] = size(im);
        kernel_size = round(k_size*sqrt(m*n));
        h = fspecial('gaussian',kernel_size,kernel_size/4);
        im_new = imfilter(im,h,'symmetric');
        im_new = uint8(255*double(im_new>0.5));

        name = strcat(num2str(k_img));
        dir = strcat(new_cl_fol_dir,'/',name,'.png');
        imwrite(im_new,dir);
        k_img = k_img + 1;
    end
end
end