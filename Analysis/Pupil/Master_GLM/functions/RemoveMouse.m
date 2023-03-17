function Matrices = RemoveMouse(Matrices, MiceNames)
    Regions = fields(Matrices);
    Felder = ["matrix", "trialMatrix", "jitter", "excinhi", "unitPVid", "unitDid", "mirko_session", "mouse"];
    for teil = 1:numel(Regions)
        Mice = Matrices.(Regions{teil}).mouse;
        for m = 1:numel(MiceNames)
            idx = Mice == MiceNames(m);
            for f = 1:numel(Felder)
                Matrices.(Regions{teil}).(Felder(f))(idx, :, :) = [];
            end
        end
    end
end