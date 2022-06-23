function im_out = im_fill(im,i_c,j_c)
    im_c = im; % комплементарное изображение - объект черный
    im = imcomplement(im); % основное изображение - объект белый

    %изображение 8 - связно, следовательно, выбирается 8 связное ядро
    I_fill = zeros(size(im));
    I_fill(i_c,j_c) = 1;
    
    %для надежности, начало заполннения должно произойти в точке, где im == 0
    %ищем ближайшего соседа 
    [n,m] = size(im);
    if im_c(i_c,j_c) ~= 1
        flag = 1;
        delta = 1;
        delta_max_perc = 5;% 5% диагонали кадра
        delta_max = delta_max_perc/100*sqrt(n*m);
        step_d = 5; 
        while flag
            if CheckIndexValid(i_c-delta,j_c-delta,n,m) && CheckIndexValid(i_c+delta,j_c+delta,n,m)
                im_segment = im(i_c-delta:i_c+delta,j_c-delta:j_c+delta);
                [i_arr,j_arr,~]= find(im_segment == 0);
                if ~isempty(i_arr)
                    i_c = i_arr(1) + i_c - delta;
                    j_c = j_arr(1) + j_c - delta;
                    flag = 0;
                else
                    if delta>delta_max
                        flag = 0;
        
                        %делаем вывод, что вся фигура раскрашена
                    end
                    delta = delta + step_d;
                end
            else
                flag = 0;
            end
        end
    end
    
    
    k_iter = 1;
    flag = 1;
    
    %для каждой точки из старой оболочки формируем новые точки
    %причем при формировании каждой новой точки проверяем условие того, что она
    %на комплементарном изображении равна единице.
    old_shell = [i_c j_c]; %старая оболочка
    %figure;
    i_s = 2;%iterator of new shell
    while flag
        new_shell = zeros(k_iter*4,2);
        n_os = i_s-1;%number of elements in old shell
        i_s = 1; %iter new shell
        for i = 1:n_os
            ij_cur = old_shell(i,:);
            i_cur = ij_cur(1);
            j_cur = ij_cur(2);
            if CheckIndexValid(i_cur+1,j_cur,n,m)
                if im_c(i_cur+1,j_cur) == 1
                    if I_fill(i_cur+1,j_cur) == 0
                        new_shell(i_s,:) = [i_cur+1,j_cur]; i_s = i_s + 1;
                        I_fill(i_cur+1,j_cur) = 1;
                    end
                end
            end
            if CheckIndexValid(i_cur-1,j_cur,n,m)
                if im_c(i_cur-1,j_cur) == 1
                    if I_fill(i_cur-1,j_cur) == 0
                        new_shell(i_s,:) = [i_cur-1,j_cur]; i_s = i_s + 1;
                        I_fill(i_cur-1,j_cur) = 1;
                    end
                end
            end
            if CheckIndexValid(i_cur,j_cur+1,n,m)
                if im_c(i_cur,j_cur+1) == 1
                    if I_fill(i_cur,j_cur+1) == 0
                        new_shell(i_s,:) = [i_cur,j_cur+1]; i_s = i_s + 1;
                        I_fill(i_cur,j_cur+1) = 1;
                    end
                end
            end
            if CheckIndexValid(i_cur,j_cur-1,n,m)
                if im_c(i_cur,j_cur-1) == 1
                    if I_fill(i_cur,j_cur-1) == 0
                        new_shell(i_s,:) = [i_cur,j_cur-1]; i_s = i_s + 1;
                        I_fill(i_cur,j_cur-1) = 1;
                    end
                end
            end
        end
        if i_s == 1
            flag = 0;
        end
        old_shell = new_shell;
        k_iter = k_iter + 1;
        %imshow(I_fill);
    
    end
    im_full_fill = I_fill | im;
    im_out = double(im_full_fill);
    
function result = CheckIndexValid(i,j,n,m)
    if i>0 && i<=n && j>0 && j<=m
        result = 1;
    else
        result = 0;
    end
end

end