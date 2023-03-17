for id = 1:2
    mo = "tdat01"
    lim = 191
    load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
    Matrices.(mo).matrix(Matrices.(mo).matrix > lim) = NaN;
    lim = 100
    Matrices.(mo).matrix(Matrices.(mo).matrix < lim) = NaN;
    parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
end
%%
for id = 1:2
    mo = "tdat02"
    lim = 80
    load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
    Matrices.(mo).matrix(Matrices.(mo).matrix < lim) = NaN;
    parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
end
%%
for id = 1:2
    mo = "td101"
    lim = 200
    load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
    Matrices.(mo).matrix(Matrices.(mo).matrix > lim) = NaN;
    parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
end
%%
id = 4
mo = "td104"
lim = 80
load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
Matrices.(mo).matrix(Matrices.(mo).matrix < lim) = NaN;
parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%%
id = 6
mo = "td201"
lim = 200
load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
for tr = 1:150
    if any(Matrices.(mo).matrix(:, :, tr) > lim)
        Matrices.(mo).matrix(:, :, tr) = NaN;
    end
end
parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%%
id = 8
mo = "tdat05"
lim = 145
load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
Matrices.(mo).matrix(Matrices.(mo).matrix < lim) = NaN;
parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%%
id = 6
mo = "tdat02"
lim = 60
load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
Matrices.(mo).matrix(Matrices.(mo).matrix < lim) = NaN;
parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%%
id = 10
mo = "tdat02"
lim = 77
load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
Matrices.(mo).matrix(Matrices.(mo).matrix < lim) = NaN;
parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%%
id = 11
mo = "td103"
lim = 140
load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
Matrices.(mo).matrix(Matrices.(mo).matrix > lim) = NaN;
parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%%
id = 11
mo = "tdat01"
lim = 90
load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
Matrices.(mo).matrix(Matrices.(mo).matrix < lim) = NaN;
parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%%
id = 11
mo = "tdat02"
lim = 60
load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
Matrices.(mo).matrix(Matrices.(mo).matrix < lim) = NaN;
parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%%
id = 12
mo = "tdat02"
lim = 64
load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
Matrices.(mo).matrix(Matrices.(mo).matrix < lim) = NaN;
parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%%
id = 13
mo = "tdat05"
lim = 100
load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
Matrices.(mo).matrix(Matrices.(mo).matrix < lim) = NaN;
parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%%
id = 14
mo = "tdat01"
lim = 157
load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
Matrices.(mo).matrix(Matrices.(mo).matrix(:, 1:37, :) > lim) = NaN;
Matrices.(mo).matrix(Matrices.(mo).matrix(:, 121:168, :) > lim) = NaN;
parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%%
%  id = 23
%  mo = "td101"
%  load(PVdirectory + "/Pupil/pupilMatrices_NW_" + num2str(id) + ".mat")
%  Matrices = rmfield(Matrices, mo);
%  parsave(PVdirectory + "/Pupil/" + "pupilMatrices_NW_" + num2str(id), Matrices)
%  


