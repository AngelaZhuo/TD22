Captu = [];

for s = [1:15, 17:30]
for u = Sesser{s}
for tr = 1:150
Adder = [Session(tr).fv_on_odorcue - Session(tr).fv_on_rewcue, Session(tr).fv_on_rewcue - Session(tr).reward_time];
Captu = cat(1, Captu, Adder);
end
end
end