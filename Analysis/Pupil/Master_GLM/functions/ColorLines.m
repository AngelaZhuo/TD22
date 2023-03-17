function RGB = ColorLines(experimentCode)
% This is a function to manually set the colors of the plot
% These groups of colors go well together. 

    if experimentCode == 10 % Baseline
        RGB = [10 10 10]; % Black
        
    elseif experimentCode == 11 % A
        RGB = [255 0 255]; % Fucsia   
       
    elseif experimentCode == 12 % B
        RGB = [1 45 110]; % Eleonora Blue
        
    elseif experimentCode == 13 % C_A
        RGB = [255 0 0]; % Red
         
    elseif experimentCode == 14 % C_B
        RGB = [150 3 150]; % Dark Fucsia

    elseif experimentCode == 15 % D_A
        RGB = [19 159 255]; % Eleonora purple
        
    elseif experimentCode == 16 % D_B
        RGB = [0 0 255]; % Blue
        
    elseif experimentCode == 17 % R_C
        RGB = [252 202 0]; % C1 color
        
    elseif experimentCode == 18 % R_D
        RGB = [250 98 32]; % D1 color
        
    elseif experimentCode == 19 % NR_C
        RGB = [56 184 17]; % C0 color
        
    elseif experimentCode == 20 % NR_D
        RGB = [1 82 22]; % D0 color
        
   %%%% Option A for full trajs  
        
    elseif experimentCode == 1 % A C R
        RGB = [255, 0, 0]; % Red
    
    elseif experimentCode == 2 % A C NR
        RGB = [180,30,180]; % Light Coral
        
    elseif experimentCode == 3 % A D R
        RGB = [0, 48, 175]; % Saddle brown
        
    elseif experimentCode == 4 % A D NR
        RGB = [48, 135, 175]; % Golden rod
        
    elseif experimentCode == 5 % B C R
        RGB = [0, 128, 0]; % Green
        
    elseif experimentCode == 6 % B C NR
        RGB = [0, 255, 0]; % Lime   
        
    elseif experimentCode == 7 % B D R
        RGB = [30, 144, 255]; % Dodger blue

    elseif experimentCode == 8 % 
        RGB = [0, 206, 209]; % dark turquoise
        
    elseif experimentCode == 9 % B D NR
        RGB = [150 3 150]; % Dark Fucsia
        
%     %%%% Option B for full trajs
%     
%     elseif experimentCode == 1 % A C R
%         RGB = [230, 0, 0]; % Red
%     
%     elseif experimentCode == 2 % A C NR
%         RGB = [255,128,128]; % Light Coral
%         
%     elseif experimentCode == 3 % A D R
%         RGB = [190,0,190]; % Dark Violet
%         
%     elseif experimentCode == 4 % A D NR
%         RGB = [255,128,255]; % Violet
%         
%     elseif experimentCode == 5 % B C R
%         RGB = [0 0 230]; % Blue
%         
%     elseif experimentCode == 6 % B C NR
%         RGB = [100,145,255]; % Royal blue
%         
%     elseif experimentCode == 7 % B D R
%         RGB = [0 200 200]; % Darkish cyan
%         
%     elseif experimentCode == 8 % B D NR
%         RGB = [128 200 200]; % 
%             
    else
        RGB = [200 200 200];
    end   
    
    RGB = RGB / 255;
  
end

