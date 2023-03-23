function [WT_animal,Mutant_animal] = isMutant(session_mouselist)

    WT_animal = [];
    Mutant_animal = [];

    for M = 1:size(session_mouselist,1)
        mouse_num = str2double(session_mouselist{M}(2:end));
        if mod(mouse_num, 2) ~= 0
            WT_animal(end+1) = M;
            
        else
            Mutant_animal(end+1) = M;
            
        end
    end


%     for M = 1:size(session_mouselist,1)
%     WT_animal = find(session_mouselist(mod(str2double(session_mouselist{M}(2:end)),2)~=0), 10);
%     Mutant_animal = find(session_mouselist(mod(str2double(session_mouselist{M}(2:end)),2)==0), 10);
%     end

end