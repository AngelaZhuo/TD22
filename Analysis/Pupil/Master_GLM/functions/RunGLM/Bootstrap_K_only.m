%%% Prepare bootstrap
Lag = 5; 
rng(1); Trials = 150; Batches150 = 1:Lag:Trials; if Batches150(end) - Trials + (Lag-1) > 0; Batches150(end) = []; end; Batches150 = Batches150'; Batches150(:, 2) = Batches150(:, 1) + Lag -1; Batches150(end, 2) = Trials; K150 = []; for i = 1:nboot; k = randperm(size(Batches150, 1)); K150 = cat(1, K150, k); end
rng(1); Trials = 100; Batches100 = 1:Lag:Trials; if Batches100(end) - Trials + (Lag-1) > 0; Batches100(end) = []; end; Batches100 = Batches100'; Batches100(:, 2) = Batches100(:, 1) + Lag -1; Batches100(end, 2) = Trials; K100 = []; for i = 1:nboot; k = randperm(size(Batches100, 1)); K100 = cat(1, K100, k); end
rng(1); Trials = 50; Batches50 = 1:Lag:Trials; if Batches50(end) - Trials + (Lag-1) > 0; Batches50(end) = []; end; Batches50 = Batches50'; Batches50(:, 2) = Batches50(:, 1) + Lag -1; Batches50(end, 2) = Trials; K50 = []; for i = 1:nboot; k = randperm(size(Batches50, 1)); K50 = cat(1, K50, k); end
rng(1); Trials = 145; Batches45 = 1:Lag:Trials; if Batches45(end) - Trials + (Lag-1) > 0; Batches45(end) = []; end; Batches45 = Batches45'; Batches45(:, 2) = Batches45(:, 1) + Lag -1; Batches45(end, 2) = Trials; K45 = []; for i = 1:nboot; k = randperm(size(Batches45, 1)); K45 = cat(1, K45, k); end
clear k Lag i Trials