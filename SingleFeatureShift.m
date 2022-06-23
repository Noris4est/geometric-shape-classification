function x_out = SingleFeatureShift(x_in)
    i_min_arr = find(x_in == min(x_in));
    i_min = i_min_arr(1);
    %реализован сдвиг влево до глобального минимума
    if i_min - 1 >= 1
        x_out = [x_in(i_min:end),x_in(1:i_min-1)];
    else
        x_out = x_in;
    end
    
end