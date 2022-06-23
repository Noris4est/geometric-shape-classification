function im_out = BinImErosion(im,SE)
%Входное изображение бинарное: Фон - "0", объект - "1"
im_e = conv2(im,SE,'same');
im_out = double(im_e == sum(SE,'all')); %дилатация
end