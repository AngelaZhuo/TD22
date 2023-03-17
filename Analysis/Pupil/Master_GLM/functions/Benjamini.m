function [hMatrix, newAlpha] = Benjamini(pMatrix)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[Neurons, Bins, Parameters] = size(pMatrix);
hBinary = NaN(Neurons, Bins, Parameters);
newAlpha = ones(Neurons, Parameters);
for r = 1:Neurons
    for out = 1:Parameters
        temp = pMatrix(r, :, out); temp(isnan(temp)) = [];
        [H,alph_corrected] = multiple_comparison_correction(temp,0.05,"benjamini");
%         [H,alph_corrected] = multiple_comparison_correction(squeeze(pMatrix(neur, :, out)),0.05,"bonferroni");
        hBinary(r, ~isnan(pMatrix(r, :, out)), out) = H;
        newAlpha(r, out) = alph_corrected;
    end
end

hMatrix = NaN(Neurons, Bins, Parameters);
hMatrix(hBinary == 1) = 1;


end

