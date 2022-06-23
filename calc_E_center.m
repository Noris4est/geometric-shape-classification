function [i_0,j_0] = calc_E_center(im)
im = double(im);
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
end