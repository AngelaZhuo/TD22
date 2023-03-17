M1 = squeeze(Matrices.Pupil.matrix(1, :, :));

for tr = 1:145
    plot(M1(:, tr))
    hold on
    pause
end
   