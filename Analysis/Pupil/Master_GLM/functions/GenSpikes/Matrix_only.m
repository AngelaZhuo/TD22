function Matrices = Matrix_only(Structure_directory, IDs)
    Matrices = OrderSessions_ifr(Structure_directory, IDs(1)); Regions = fields(Matrices);
    Line = NaN(1,168,150); LineTM = NaN(1, 3, 150);  LineJ = NaN(1, 150);
    
    for teil = 1:numel(Regions)
        if ~isempty(Matrices.(Regions{teil}).trialMatrix)
            Matrix = NaN(size(Matrices.(Regions{teil}).matrix, 1), size(Matrices.(Regions{teil}).matrix, 2), 150);
            Matrix(:, :, 1:size(Matrices.(Regions{teil}).matrix, 3)) = Matrices.(Regions{teil}).matrix;
            Jitter = NaN(size(Matrices.(Regions{teil}).jitter, 1), 150); Jitter(:, 1:size(Matrices.(Regions{teil}).jitter, 2)) = Matrices.(Regions{teil}).jitter;
            Matrices.(Regions{teil}).matrix = cat(1, Line, Matrix);
            Matrices.(Regions{teil}).trialMatrix = cat(1, LineTM, Matrices.(Regions{teil}).trialMatrix);
            Matrices.(Regions{teil}).jitter = cat(1, LineJ, Jitter);
            Matrices.(Regions{teil}).mouse = cat(1, "", Matrices.(Regions{teil}).mouse);
            Matrices.(Regions{teil}).unitPVid = cat(1, 0, Matrices.(Regions{teil}).unitPVid);
            Matrices.(Regions{teil}).unitDid = cat(1, 0, Matrices.(Regions{teil}).unitDid);
            Matrices.(Regions{teil}).mirko_session = cat(1, 0, Matrices.(Regions{teil}).mirko_session);
            
            
        else
            Matrices.(Regions{teil}).matrix = Line;
            Matrices.(Regions{teil}).trialMatrix = LineTM;
            Matrices.(Regions{teil}).jitter = LineJ;
            Matrices.(Regions{teil}).unitPVid = [0];
            Matrices.(Regions{teil}).unitDid = [0];
            Matrices.(Regions{teil}).mirko_session = [0];
            Matrices.(Regions{teil}).mouse = [""];
        end
    end
    for i = 2:numel(IDs)
        Other = OrderSessions_ifr(Structure_directory, IDs(i));
        for teil = 1:numel(Regions)
            if isempty(Other.(Regions{teil}).trialMatrix)
                continue
            end
            Matrix = NaN(size(Other.(Regions{teil}).matrix, 1), size(Other.(Regions{teil}).matrix, 2), 150);
            Matrix(:, :, 1:size(Other.(Regions{teil}).matrix, 3)) = Other.(Regions{teil}).matrix;
            Matrices.(Regions{teil}).matrix = cat(1, Matrices.(Regions{teil}).matrix, Matrix);
            Matrices.(Regions{teil}).trialMatrix = cat(1, Matrices.(Regions{teil}).trialMatrix, Other.(Regions{teil}).trialMatrix);
            Jitter = NaN(size(Other.(Regions{teil}).jitter, 1), 150); Jitter(:, 1:size(Other.(Regions{teil}).jitter, 2)) = Other.(Regions{teil}).jitter;
            Matrices.(Regions{teil}).jitter = cat(1, Matrices.(Regions{teil}).jitter, Jitter);
            Matrices.(Regions{teil}).mouse = cat(1, Matrices.(Regions{teil}).mouse, Other.(Regions{teil}).mouse);
            Matrices.(Regions{teil}).unitPVid = cat(1, Matrices.(Regions{teil}).unitPVid, Other.(Regions{teil}).unitPVid);
            Matrices.(Regions{teil}).unitDid = cat(1, Matrices.(Regions{teil}).unitDid, Other.(Regions{teil}).unitDid);
            Matrices.(Regions{teil}).mirko_session = cat(1, Matrices.(Regions{teil}).mirko_session, Other.(Regions{teil}).mirko_session);
        end
    end
    for teil = 1:numel(Regions)
        Matrices.(Regions{teil}).matrix(1, :, :) = [];
        Matrices.(Regions{teil}).trialMatrix(1, :, :) = [];
        Matrices.(Regions{teil}).jitter(1, :, :) = [];
        Matrices.(Regions{teil}).mouse(1, :) = [];
        Matrices.(Regions{teil}).unitPVid(1, :) = [];
        Matrices.(Regions{teil}).unitDid(1, :) = [];
        Matrices.(Regions{teil}).mirko_session(1, :) = [];
    end
end