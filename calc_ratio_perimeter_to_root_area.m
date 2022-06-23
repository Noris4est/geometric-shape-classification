function [ratio] = calc_ratio_perimeter_to_root_area(x)
%Отношение периметра к корню из площади
%На вход поступает вектор признаков. Шаг по углу равномерный.
n = numel(x);
d_fi = 2*pi/n;
cos_d_fi = cos(d_fi);
sin_d_fi = sin(d_fi);
%Расчет периметра
MulXshift1 = x(1:end-1).*x(2:end);
%Массив отрезков с 1 по n-1
dL_arr = x(1:end-1).^2 + x(2:end).^2 - 2*MulXshift1*cos_d_fi;
dL_arr = sqrt(dL_arr);
%Расчет последнего отрезка 
dL_last = x(end)^2 + x(1)^2 - 2*x(end)*x(1)*cos_d_fi;
dL_last = sqrt(dL_last);
%Периметр фигуры
Perim = sum(dL_arr) + dL_last;

%Расчет площади
%Массив площадей сегментов с 1 по n-1
dS_arr = 0.5*MulXshift1*sin_d_fi;
%Площадь последнего сегмента
dS_last = 0.5*x(end)*x(1)*sin_d_fi;
%Площадь фигуры
Area = sum(dS_arr) + dS_last;
if Area ~= 0
    ratio = Perim/sqrt(Area);
else
    ratio = 0;
end