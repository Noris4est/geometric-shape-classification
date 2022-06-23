function im_out = im_preprocessing(im_in)
im_out = im2double(im_in);
im_out = double(im_out<0.5);
end