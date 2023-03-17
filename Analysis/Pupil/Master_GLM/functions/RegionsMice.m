function Matrices = RegionsMice(MatricesX)


Mice = unique(MatricesX.Pupil.mouse);
for m = 1:numel(Mice)
    idx = MatricesX.Pupil.mouse == Mice(m);
    Matrices.(Mice(m)).matrix = MatricesX.Pupil.matrix(idx, :, :);
    Matrices.(Mice(m)).trialMatrix = MatricesX.Pupil.trialMatrix(idx, :, :);
    Matrices.(Mice(m)).jitter = MatricesX.Pupil.jitter(idx, :);
    Matrices.(Mice(m)).mouse = MatricesX.Pupil.mouse(idx);
    Matrices.(Mice(m)).events = MatricesX.Pupil.events;
end

end