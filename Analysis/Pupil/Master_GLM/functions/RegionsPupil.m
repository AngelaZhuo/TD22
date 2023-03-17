function Matrices = RegionsPupil(MatricesX)
FM = fields(MatricesX);
F = fields(MatricesX.(FM{1}));
for f = 1:5 % Just the first five
    Matrices.Pupil.(F{f}) = [];
end
for fm = 1:numel(FM)
    for f = 1:5 % Just the first five
        Matrices.Pupil.(F{f}) = cat(1,Matrices.Pupil.(F{f}), MatricesX.(FM{fm}).(F{f}));
    end
end
Matrices.Pupil.(F{6}) = MatricesX.(FM{fm}).(F{6}); % The events
end