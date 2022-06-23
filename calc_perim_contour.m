function P = calc_perim_contour(contour)
% Расчет периметра контура
% На входе матрица размером n * 2; n -кол. точек 
% столбцы - x и y
P = 0;
for i = 1:size(contour,1)-1
    Xcur = contour(i,1);
    Ycur = contour(i,2);

    Xnext = contour(i+1,1);
    Ynext = contour(i+1,2);

    dx = Xnext - Xcur;
    dy = Ynext - Ycur;

    dP = sqrt(dx^2 + dy^2);

    P = P + dP;
end
    
    X1 = contour(1,1);
    Y1 = contour(1,2);

    Xend = contour(end,1);
    Yend = contour(end,2);

    dx = X1 - Xend;
    dy = Y1 - Yend;

    dP = sqrt(dx^2 + dy^2);

    P = P + dP;
end