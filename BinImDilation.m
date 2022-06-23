function im_out = BinImDilation(im,SE)
%Входное изображение бинарное: Фон - "0", объект - "1"
im_d = conv2(im,SE,'same');
im_out = double(im_d>0); %дилатация
end