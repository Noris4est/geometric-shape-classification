function [confM,accuracy] = calc_confusion_matrix(y_test,y_pred)
    u_cl = unique(y_test);
    Nuc = numel(u_cl);
    confM = zeros(Nuc,Nuc);
    

    %for i = 1:size(y_test)
    %    confM(y_test(i),y_pred(i)) = confM(y_test(i),y_pred(i)) + 1;
    %end

    for i = 1:Nuc
        for j = 1:Nuc
            confM(i,j) = sum(y_test == u_cl(i) & y_pred == u_cl(j));
        end
    end

    accuracy = 0;
    for i = 1:Nuc
        accuracy = accuracy + confM(i,i);
    end
    accuracy = accuracy/numel(y_pred);

end
