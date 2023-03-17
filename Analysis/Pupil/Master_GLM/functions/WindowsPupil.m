function Matrices = WindowsPupil(Matrices)
% 7 Windows: One second before CS1 (baseline); Last second of CS1 delay; Last second of CS2 delay; First
% second after US; One second from 500ms after US onset; One second from 2s
% after US onset; One second around bin 127;
Regions = fields(Matrices);
Events = Matrices.(Regions{1}).events;
for teil = 1:numel(Regions)
    M = Matrices.(Regions{teil}).matrix;
    [rows, ~, trials] = size(M);
    NM = NaN(rows, 7, trials);
    % Baseline
    NM(:, 1, :) = mean(M(:, Events(1)-10: Events(1)-1, :), 2, "omitnan");
    % 1sec before jitter (1sec at end of CS1 delay)
    NM(:, 2, :) = mean(M(:, Events(3)-10: Events(3)-1, :), 2, "omitnan");
    % 1sec before US (1sec at end of CS2 delay)
    NM(:, 3, :) = mean(M(:, Events(6)-10: Events(6)-1, :), 2, "omitnan");
    % First second after US onset (expected CS2 differenciation)
    NM(:, 4, :) = mean(M(:, Events(6): Events(6)+9, :), 2, "omitnan");
    % One second from 500ms after US onset (expected US differenciation)
    NM(:, 5, :) = mean(M(:, Events(6)+5: Events(6)+14, :), 2, "omitnan");
    % One second from 2s after US onset (expected US differenciation)
    NM(:, 6, :) = mean(M(:, Events(6)+20: Events(6)+29, :), 2, "omitnan");
    % One second around bin 127
    NM(:, 7, :) = mean(M(:, 127-4: 127+5, :), 2, "omitnan");
    Matrices.(Regions{teil}).matrix = NM;
    Matrices.(Regions{teil}).events = [2, 3, NaN, 3, 5, 5, 7];
end 
    
    
    
end 