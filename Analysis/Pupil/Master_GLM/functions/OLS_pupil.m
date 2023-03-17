function [Beta, Residual] = OLS(Xw,Yw, resid)
% Y are the observations and X the design matrix. 
% Every row in Y corresponds to every row in X. 
% Every column in Y is fitted to the design matrix. 
% A matrix of Betas is obtained where every column corresponds to every
% column of Y. 
R = size(Xw, 2); T = size(Xw,1); B = size(Yw,2);
Beta = NaN(R, B); Residual = NaN(T, B);
for bin = 1:B
    Y = Yw(:,bin);
    X = Xw;
    Y = Y(~isnan(Y));
    X = X(~isnan(Y), :);
    temp = mtimes(X', X);
    temp = inv(temp);
    temp = mtimes(temp, X');
    Be = mtimes(temp, Y);
    if resid == 1 
        Residual(~isnan(Y),bin) = (Y-X*Be);
    end
end
end

