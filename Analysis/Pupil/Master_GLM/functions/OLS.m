function [Beta, Residual] = OLS(X,Y, resid)
% Y are the observations and X the design matrix. 
% Every row in Y corresponds to every row in X. 
% Every column in Y is fitted to the design matrix. 
% A matrix of Betas is obtained where every column corresponds to every
% column of Y. 

temp = mtimes(X', X);
temp = inv(temp);
temp = mtimes(temp, X');
Beta = mtimes(temp, Y);

Residual = [];
if resid == 1 
    Residual = (Y-X*Beta);
end

end

