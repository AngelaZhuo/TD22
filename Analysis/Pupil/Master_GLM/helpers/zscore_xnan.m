function Z_matix = zscore_xnan(Matrix)

%compute the zscore omiting the NaN values in a 3-dimensional matrix

Mean = mean(Matrix, [2,3], "omitnan");
Std = std(Matrix, 0, [2,3], "omitnan");
Z_matix = (Matrix-Mean)./Std;


end

