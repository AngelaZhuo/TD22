function Matrices = BrainToMouse(Matrices1)
    Regions = fields(Matrices1);
    Felder = ["matrix", "trialMatrix", "jitter", "excinhi", "unitPVid", "unitDid", "mirko_session", "mouse"];
    Mice = [];
    for teil = 1:numel(Regions)
        Mice = cat(1, Mice, Matrices1.(Regions{teil}).mouse);
    end
    Mice = unique(Mice);
    
    for m = 1:numel(Mice)
        for teil = 1:numel(Regions)
            
            index = Matrices1.(Regions{teil}).mouse == Mice(m);
            for f = 1:numel(Felder)
                Matrices.(Mice(m)).(Regions{teil}).(Felder(f)) = Matrices1.(Regions{teil}).(Felder(f))(index, :, :);
            end
            Matrices.(Mice(m)).(Regions{teil}).events = Matrices1.(Regions{teil}).events;
        end
        
    end
end