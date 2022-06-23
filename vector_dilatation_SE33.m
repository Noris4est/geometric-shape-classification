function vecOut = vector_dilatation_SE33(vecIn)
%Вход: матрица размерности n * 2, где n - число точек исх. вектора 
%Выход: матрица m * 2, m - число точек вых. вектора. m = 9*n;
%Дубли не удаляются
    N0 = size(vecIn,1);
    vecOut = zeros(N0*9,2); 
    k = 1;
    for i = 1:N0
        xc = vecIn(i,1);
        yc = vecIn(i,2);
    
        %vecOut(k,:) = [xc-1,yc-1]; k = k + 1;
        vecOut(k,:) = [xc-1,yc]; k = k + 1;
        %vecOut(k,:) = [xc-1,yc+1]; k = k + 1;
    
        vecOut(k,:) = [xc,yc-1]; k = k + 1;
        vecOut(k,:) = [xc,yc]; k = k + 1;
        vecOut(k,:) = [xc,yc+1]; k = k + 1;
    
        %vecOut(k,:) = [xc+1,yc-1]; k = k + 1;
        vecOut(k,:) = [xc+1,yc]; k = k + 1;
        %vecOut(k,:) = [xc+1,yc+1]; k = k + 1;
    end

end