function [SE] = create_circ_struct_el(r)
    n = 2*r + 1;
    [j,i] = meshgrid(1:n,1:n);
    ij0 = r+1;
    r_pow_2 = r^2;
    SE = double( (i-ij0).^2 + (j - ij0).^2 <= r_pow_2 );
end