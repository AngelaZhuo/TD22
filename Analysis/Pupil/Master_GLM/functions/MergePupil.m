function Matrices = MergePupil(Matrices, Matrices2)
F = fields(Matrices.Pupil);
for f = 1:5
    Matrices.Pupil.(F{f}) = cat(1, Matrices.Pupil.(F{f}), Matrices2.Pupil.(F{f}));
end
end