function im_out = auto_calibration(im)
    band_width_perc = 5;% 5% диагонали кадра
    [n,m] = size(im);
    bw = round(band_width_perc/100*sqrt(m*n)); % band width in pixel terms
    half_bw = round(bw)/2;
    n_P = 4;
    Mf = ones(n_P,3);%feature matrix with единичным первым столбцом (нулевой признак)
    y_labels = zeros(n_P,1);% вектор метов
    
    i=1;j=1; % левый верхний угол
    ip = half_bw + i;
    jp = half_bw + j;
    I_cur = mean(im(i:i+bw-1,j:j+bw-1),'all'); %усредненная интенсивность
    Mf(1,2:end) = [ip jp];
    y_labels(1) = I_cur;
    
    i = n; j = 1; %левый нижний угол
    ip = i - half_bw;
    jp = half_bw + j;
    I_cur = mean(im(i-bw+1:i,j:j+bw-1),'all');
    Mf(2,2:end) = [ip jp];
    y_labels(2) = I_cur;
    
    i = 1; j = m; %правый верхний угол
    ip = half_bw + i;
    jp = j - half_bw;
    I_cur = mean(im(i:i+bw-1,j-bw+1:j),'all');
    Mf(3,2:end) = [ip jp];
    y_labels(3) = I_cur;
    
    i = n; j = m;% правый нижний угол
    ip = i - half_bw;
    jp = j - half_bw;
    I_cur = mean(im(i-bw+1:i,j-bw+1:j),'all');
    Mf(4,2:end) = [ip jp];
    y_labels(4) = I_cur;
    
    w_arr = (Mf'*Mf)^(-1);
    w_arr = w_arr*Mf'*y_labels;
    
    [j,i] = meshgrid(1:m,1:n);
    I_backg = i*w_arr(2) + j*w_arr(3) + w_arr(1);
    zeroFlag = 1;
    epsilon = 1e-2;
    for i = 1:n
        for j = 1:m
            if abs(I_backg(i,j))<epsilon
                zeroFlag = 0;
                break
            end
        end
        if zeroFlag == 0
            break
        end
    end

    if zeroFlag
        im_out = im./I_backg;
    else
        im_out = im;
    end
end