%% Significant Unit Identity and CPD
clear
PVdirectory = "/home/walter.canedoriedel/Desktop/Matrices";
addpath(genpath(PVdirectory))
Functions_directory = "/home/walter.canedoriedel/Desktop/Master_GLM"; addpath(genpath(Functions_directory))
cd(Functions_directory)
load("initWorkspace.mat");
Loaded = parload("/home/walter.canedoriedel/Desktop/Matrices/Curated/Matrices_NW_" + num2str(1)); Matrices = Loaded.Matrices; clear Loaded;
R1 = Matrices.VTAdan.Population.CS1final.Range; R2 = Matrices.VTAdan.Population.CS2final.Range; R3 = Matrices.VTAdan.Population.USfinal.Range;
C1 = Events(1)-R1(1)+1; C2 = Events(4)-R2(1)+1; C3 = Events(6)-R3(1)+1;
F = fields(Matrices.NAcAnt.Population);
M.(F{1}).Range = Matrices.NAcAnt.Population.(F{1}).Range; M.(F{1}).Cue = C1; 
M.(F{2}).Range = Matrices.NAcAnt.Population.(F{2}).Range; M.(F{2}).Cue = C2; 
M.(F{3}).Range = Matrices.NAcAnt.Population.(F{3}).Range; M.(F{3}).Cue = C3; 
M.(F{1}).Mirko = -30; M.(F{1}).Part = 1; 
M.(F{2}).Mirko = -20; M.(F{2}).Part = 2; 
M.(F{3}).Mirko = 8; M.(F{3}).Part = 3; 
for f = 1:3
    L = Matrices.NAcAnt.Population.(F{f}).Labels;
    L(L=="") = [];
    for e = 1:numel(L)
        L(e) = replace(L(e), " * ", "x");
        L(e) = replace(L(e), "-", "");
        M.(F{f}).(L(e)).pVal = [];
%         M.(F{f}).(L(e)).benjamini = [];
        M.(F{f}).(L(e)).betas = [];
        M.(F{f}).(L(e)).region = [];
        M.(F{f}).(L(e)).did = [];
        M.(F{f}).(L(e)).mirko_session = [];
        M.(F{f}).(L(e)).id_session = [];
    end
end
Excinhi = [];
unitID = [];
mouseID = [];
sessionID = [];
mirkoID = [];
Regi = [];
for id = 4:25
    clear Matrices
    Loaded = parload("/home/walter.canedoriedel/Desktop/Matrices/Curated/Matrices_NW_" + num2str(id)); Matrices = Loaded.Matrices; clear Loaded;
    for teil = 1:numel(Regions)
        clear Neurons
        Neurons = size(Matrices.(Regions{teil}).matrix, 1);
        eni = NaN(Neurons, size(Matrices.(Regions{teil}).matrix, 2));
        for b = 1:size(eni,2)
            uno = FindExcite_window(Matrices.(Regions{teil}), b);
            eni(:,b) = uno;
        end
        Excinhi = cat(1, Excinhi, eni);
        for f = 1:3
            clear L
            L = Matrices.(Regions{teil}).Population.(F{f}).Labels; L(L=="") = [];
            for e = 1:numel(L)
                clear pVal betas H idx did b bh p
                L(e) = replace(L(e), " * ", "x");
                L(e) = replace(L(e), "-", "");
                for u = 1:Neurons
                    pVal(u, :) =  Matrices.(Regions{teil}).SingleUnit.("unit_"+num2str(u)).(F{f}).pVal(e, :);%./Matrices.(Regions{teil}).Population.(F{f}).nboot;
                    if ~contains(L(e), ["sur", "tgr", "Interactions"])
                        betas(u, :) = Matrices.(Regions{teil}).SingleUnit.("unit_"+num2str(u)).(F{f}).Betas(:, e+1)';
                    end
                end
                M.(F{f}).(L(e)).pVal = cat(1, M.(F{f}).(L(e)).pVal, pVal);
                if ~contains(L(e), ["sur", "tgr", "Interactions"])
                    M.(F{f}).(L(e)).betas = cat(1, M.(F{f}).(L(e)).betas, betas);
                end
            end
        end
        unitID = cat(1, unitID, Matrices.(Regions{teil}).unitDid);
        sessionID = cat(1, ones(Neurons, 1)*id);
        mirkoID = cat(1, mirkoID, Matrices.(Regions{teil}).mirko_session);
        mouseID = cat(1, mouseID, Matrices.(Regions{teil}).mouse);
        Regi = cat(1, Regi, ones(Neurons, 1)*teil);
    end
    id
end
Excinhi(Excinhi==0) = -1;
%% ChiSqr global

regionID = Regi;
% CS1 presentation
C = M.CS1final.Cue;
CS1 = M.CS1final.CS1.pVal(:, C:C+11);
bCS1 = M.CS1final.CS1.betas(:, C:C+11);
hCS1 = Benjamini(CS1); bCS1 = bCS1.*hCS1;
eiCS1 = Excinhi(:, Events(1):Events(2)-1).*hCS1;

% CS2 presentation
C = M.CS2final.Cue;
CS2 = M.CS2final.CS2.pVal(:, C:C+11);
bCS2 = M.CS2final.CS2.betas(:, C:C+11);
hCS2 = Benjamini(CS2); bCS2 = bCS2.*hCS2;
eiCS2 = Excinhi(:, Events(4):Events(5)-1).*hCS2;

% CS2 presentation
C = M.CS2final.Cue;
CS2 = M.CS2final.CS2.pVal(:, C:C+11);
bCS2 = M.CS2final.CS2.betas(:, C:C+11);
hCS2 = Benjamini(CS2); bCS2 = bCS2.*hCS2;
eiCS2 = Excinhi(:, Events(4):Events(5)-1).*hCS2;

% % CS2 delay
% C = M.CS2final.Cue;
% CS2d = M.CS2final.CS2.pVal(:, C+12:C+12+9);
% bCS2d = M.CS2final.CS2.betas(:, C+12:C+12+9);
% CS2d(:, 11:12) = M.USfinal.CS2.pVal(:, 1:2);
% bCS2d(:, 11:12) = M.USfinal.CS2.betas(:, 1:2);
% hCS2d = Benjamini(CS2d); bCS2d = bCS2d.*hCS2d;
% eiCS2d = Excinhi(:, Events(5):Events(6)-1);
% 
% % US information
% US = M.USfinal.US.pVal(:, C:C+20);
% bUS = M.USfinal.US.betas(:, C:C+20);
% hUS = Benjamini(US); bUS = bUS.*hUS;
% eiUS = Excinhi(:, Events(4):Events(6)-1);


VEX2 = unitID((sum(bCS2, 2, "omitnan")>0 & sum(eiCS2, 2, "omitnan")>0));
VIN2 = unitID((sum(bCS2, 2, "omitnan")<0 & sum(eiCS2, 2, "omitnan")<0));
VEX1 = unitID((sum(bCS1, 2, "omitnan")>0 & sum(eiCS1, 2, "omitnan")>0));
VIN1 = unitID((sum(bCS1, 2, "omitnan")<0 & sum(eiCS1, 2, "omitnan")<0));

V1 = [VEX1; VIN1];
V2 = [VEX2; VIN2];

Tabel = [unitID, ismember(unitID,V1), ismember(unitID,V2), regionID];

Rejection = NaN(5, 5);
Ratio = NaN(5, 3);
Numbers = NaN(5, 3);
for teil = 1:numel(Regions)
        Regio = Tabel(:, 4) == teil;
        Regio = Tabel(Regio,:);
        cs1 = Regio(Regio(:,2) ==1, :);
        cs2 = Regio(Regio(:,3) ==1, :);
        x1 = cs1(cs1(:,3) == 0, :);
        x2 = cs2(cs2(:,2) == 0, :);
        con2 = cs1(cs1(:,3) == 1, :);
        
        DID.(Regions{teil}).cs1 = x1(:,1);
        DID.(Regions{teil}).cs2 = x2(:,1);
        DID.(Regions{teil}).con2 = con2(:,1);
end

for teil = 1:numel(Regions)
    for otto = 1:numel(Regions)
%         x = [sum(Tabel(Tabel(:,4)==teil, 2) & ~ Tabel(Tabel(:,4)==teil, 3)) + sum(~Tabel(Tabel(:,4)==teil, 2) & Tabel(Tabel(:,4)==teil, 3)), sum(Tabel(Tabel(:,4)==teil, 2) & Tabel(Tabel(:,4)==teil, 3));...
%             sum(Tabel(Tabel(:,4)==otto, 2) & ~ Tabel(Tabel(:,4)==otto, 3)) + sum(~Tabel(Tabel(:,4)==otto, 2) &  Tabel(Tabel(:,4)==otto, 3)), sum(Tabel(Tabel(:,4)==otto, 2) & Tabel(Tabel(:,4)==otto, 3))];
        x = [sum(Tabel(Tabel(:,4)==teil, 2) & ~ Tabel(Tabel(:,4)==teil, 3)), sum(Tabel(Tabel(:,4)==teil, 2) & Tabel(Tabel(:,4)==teil, 3));...
            sum(Tabel(Tabel(:,4)==otto, 2) & ~ Tabel(Tabel(:,4)==otto, 3)), sum(Tabel(Tabel(:,4)==otto, 2) & Tabel(Tabel(:,4)==otto, 3))];
        Ratio(teil, 1) = x(1, 1);
        Ratio(teil, 2) = x(1, 2);
        Ratio(teil, 3) = x(1, 2)./x(1, 1);
        Numbers(teil, 1) = sum(Tabel(Tabel(:,4)==teil, 2));
        Numbers(teil, 2) = sum(Tabel(Tabel(:,4)==teil, 3));
        Numbers(teil, 3) = x(1, 2);
                
        
        Valers = sum(x, "all"); % Total value units
        X = NaN(2, Valers); % 
        X(1, 1:sum(x(1,:))) = teil; 
        X(1, end-sum(x(2,:))+1:end) = otto; 
        X(2, :) = 1;
        X(2, 1:x(1,2)) = 2;
        X(2, end-x(2,2) + 1:end) = 2;

        [tabs, chi2, p, labs] = crosstab(X(1,:)',X(2,:)');
        
%         Regions{teil} + " " + Regions{otto} 
%         x
        Rejection(teil, otto) = p;
    end
end



%% ChiSqr global

regionID = Regi;
% CS1 presentation
C = M.CS1final.Cue;
CS1 = M.CS1final.CS1.pVal(:, C:C+11);
bCS1 = M.CS1final.CS1.betas(:, C:C+11);
hCS1 = Benjamini(CS1); bCS1 = bCS1.*hCS1;
eiCS1 = Excinhi(:, Events(1):Events(2)-1).*hCS1;

% CS2 presentation
C = M.CS2final.Cue;
CS2 = M.CS2final.CS2.pVal(:, C:C+11);
bCS2 = M.CS2final.CS2.betas(:, C:C+11);
hCS2 = Benjamini(CS2); bCS2 = bCS2.*hCS2;
eiCS2 = Excinhi(:, Events(4):Events(5)-1).*hCS2;

% % CS2 delay
% C = M.CS2final.Cue;
% CS2d = M.CS2final.CS2.pVal(:, C+12:C+12+9);
% bCS2d = M.CS2final.CS2.betas(:, C+12:C+12+9);
% CS2d(:, 11:12) = M.USfinal.CS2.pVal(:, 1:2);
% bCS2d(:, 11:12) = M.USfinal.CS2.betas(:, 1:2);
% hCS2d = Benjamini(CS2d); bCS2d = bCS2d.*hCS2d;
% eiCS2d = Excinhi(:, Events(5):Events(6)-1);
% 
% % US information
% US = M.USfinal.US.pVal(:, C:C+20);
% bUS = M.USfinal.US.betas(:, C:C+20);
% hUS = Benjamini(US); bUS = bUS.*hUS;
% eiUS = Excinhi(:, Events(4):Events(6)-1);


VEX2 = unitID((sum(bCS2, 2, "omitnan")>0 & sum(eiCS2, 2, "omitnan")>0));
VIN2 = unitID((sum(bCS2, 2, "omitnan")<0 & sum(eiCS2, 2, "omitnan")<0));
VEX1 = unitID((sum(bCS1, 2, "omitnan")>0 & sum(eiCS1, 2, "omitnan")>0));
VIN1 = unitID((sum(bCS1, 2, "omitnan")<0 & sum(eiCS1, 2, "omitnan")<0));

V1 = [VEX1; VIN1];
V2 = [VEX2; VIN2];

Tabel = [unitID, ismember(unitID,V1), ismember(unitID,V2), regionID];

Rejection = NaN(5, 5);
Ratio = NaN(5, 3);
Numbers = NaN(5, 3);
for teil = 1:numel(Regions)
        Regio = Tabel(:, 4) == teil;
        Regio = Tabel(Regio,:);
        cs1 = Regio(Regio(:,2) ==1, :);
        cs2 = Regio(Regio(:,3) ==1, :);
        x1 = cs1(cs1(:,3) == 0, :);
        x2 = cs2(cs2(:,2) == 0, :);
        con2 = cs1(cs1(:,3) == 1, :);
        
        DID.(Regions{teil}).cs1 = x1(:,1);
        DID.(Regions{teil}).cs2 = x2(:,1);
        DID.(Regions{teil}).con2 = con2(:,1);
end

for teil = 1:numel(Regions)
    for otto = 1:numel(Regions)
        x = [sum(Tabel(Tabel(:,4)==teil, 2) & ~ Tabel(Tabel(:,4)==teil, 3)) + sum(~Tabel(Tabel(:,4)==teil, 2) & Tabel(Tabel(:,4)==teil, 3)), sum(Tabel(Tabel(:,4)==teil, 2) & Tabel(Tabel(:,4)==teil, 3));...
            sum(Tabel(Tabel(:,4)==otto, 2) & ~ Tabel(Tabel(:,4)==otto, 3)) + sum(~Tabel(Tabel(:,4)==otto, 2) &  Tabel(Tabel(:,4)==otto, 3)), sum(Tabel(Tabel(:,4)==otto, 2) & Tabel(Tabel(:,4)==otto, 3))];
        Ratio(teil, 1) = x(1, 1);
        Ratio(teil, 2) = x(1, 2);
        Ratio(teil, 3) = x(1, 1)./x(1, 2);
        Numbers(teil, 1) = sum(Tabel(Tabel(:,4)==teil, 2));
        Numbers(teil, 2) = sum(Tabel(Tabel(:,4)==teil, 3));
        Numbers(teil, 3) = x(1, 2);
                
        
        Valers = sum(x, "all"); % Total value units
        X = NaN(2, Valers); % 
        X(1, 1:sum(x(1,:))) = teil; 
        X(1, end-sum(x(2,:))+1:end) = otto; 
        X(2, :) = 1;
        X(2, 1:x(1,2)) = 2;
        X(2, end-x(2,2) + 1:end) = 2;

        [tabs, chi2, p, labs] = crosstab(X(1,:)',X(2,:)');

        Rejection(teil, otto) = p;
    end
end




%% ChiSqr in mice

regionID = Regi;
% CS1 presentation
C = M.CS1final.Cue;
CS1 = M.CS1final.CS1.pVal(:, C:C+11);
bCS1 = M.CS1final.CS1.betas(:, C:C+11);
hCS1 = Benjamini(CS1); bCS1 = bCS1.*hCS1;
eiCS1 = Excinhi(:, Events(1):Events(2)-1).*hCS1;

% CS2 presentation
C = M.CS2final.Cue;
CS2 = M.CS2final.CS2.pVal(:, C:C+11);
bCS2 = M.CS2final.CS2.betas(:, C:C+11);
hCS2 = Benjamini(CS2); bCS2 = bCS2.*hCS2;
eiCS2 = Excinhi(:, Events(4):Events(5)-1).*hCS2;

% % CS2 delay
% C = M.CS2final.Cue;
% CS2d = M.CS2final.CS2.pVal(:, C+12:C+12+9);
% bCS2d = M.CS2final.CS2.betas(:, C+12:C+12+9);
% CS2d(:, 11:12) = M.USfinal.CS2.pVal(:, 1:2);
% bCS2d(:, 11:12) = M.USfinal.CS2.betas(:, 1:2);
% hCS2d = Benjamini(CS2d); bCS2d = bCS2d.*hCS2d;
% eiCS2d = Excinhi(:, Events(5):Events(6)-1);
% 
% % US information
% US = M.USfinal.US.pVal(:, C:C+20);
% bUS = M.USfinal.US.betas(:, C:C+20);
% hUS = Benjamini(US); bUS = bUS.*hUS;
% eiUS = Excinhi(:, Events(4):Events(6)-1);


VEX2 = unitID((sum(bCS2, 2, "omitnan")>0 & sum(eiCS2, 2, "omitnan")>0));
VIN2 = unitID((sum(bCS2, 2, "omitnan")<0 & sum(eiCS2, 2, "omitnan")<0));
VEX1 = unitID((sum(bCS1, 2, "omitnan")>0 & sum(eiCS1, 2, "omitnan")>0));
VIN1 = unitID((sum(bCS1, 2, "omitnan")<0 & sum(eiCS1, 2, "omitnan")<0));

V1 = [VEX1; VIN1];
V2 = [VEX2; VIN2];
Mice = unique(mouseID);
for m = 1:numel(Mice)
    Tabel = [unitID, double(ismember(unitID,V1)), ismember(unitID,V2), regionID];
    Tabel = Tabel(ismember(mouseID, Mice{m}), :);

    Rejection = NaN(5, 5);
    Ratio = NaN(5, 3);
    Numbers = NaN(5, 3);
    for teil = 1:numel(Regions)
            Regio = Tabel(:, 4) == teil;
            Regio = Tabel(Regio,:);
            cs1 = Regio(Regio(:,2) ==1, :);
            cs2 = Regio(Regio(:,3) ==1, :);
            x1 = cs1(cs1(:,3) == 0, :);
            x2 = cs2(cs2(:,2) == 0, :);
            con2 = cs1(cs1(:,3) == 1, :);

            DID.(Regions{teil}).cs1 = x1(:,1);
            DID.(Regions{teil}).cs2 = x2(:,1);
            DID.(Regions{teil}).con2 = con2(:,1);
    end

    for teil = 1:numel(Regions)
        for otto = 1:numel(Regions)
            x = [sum(Tabel(Tabel(:,4)==teil, 2) & ~ Tabel(Tabel(:,4)==teil, 3)), sum(Tabel(Tabel(:,4)==teil, 2) & Tabel(Tabel(:,4)==teil, 3));...
                sum(Tabel(Tabel(:,4)==otto, 2) & ~ Tabel(Tabel(:,4)==otto, 3)), sum(Tabel(Tabel(:,4)==otto, 2) & Tabel(Tabel(:,4)==otto, 3))];
            Ratio(teil, 1) = x(1, 1);
            Ratio(teil, 2) = x(1, 2);
            Ratio(teil, 3) = x(1, 1)./x(1, 2);
            Numbers(teil, 1) = sum(Tabel(Tabel(:,4)==teil, 2));
            Numbers(teil, 2) = sum(Tabel(Tabel(:,4)==teil, 3));
            Numbers(teil, 3) = x(1, 2);


            Valers = sum(x, "all"); % Total value units
            X = NaN(2, Valers); % 
            X(1, 1:sum(x(1,:))) = teil; 
            X(1, end-sum(x(2,:))+1:end) = otto; 
            X(2, :) = 1;
            X(2, 1:x(1,2)) = 2;
            X(2, end-x(2,2) + 1:end) = 2;

            [tabs, chi2, p, labs] = crosstab(X(1,:)',X(2,:)');

            Rejection(teil, otto) = p;
        end
    end
    Mice{m}
    Rejection
    Ratio
    Numbers
end







