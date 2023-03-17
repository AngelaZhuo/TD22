function [Current, Compare] = FindTrial(number)
% Select the proper Current, Compare and ShowUs for a for loop. 

if number == 1
    % A from AR, ANR
    Current = [5, 99, 99]; 
    Compare = [[5, 99, 1]; [5, 99, 0]];
elseif number == 2
    % A from AC, AD
    Current = [5, 99, 99]; 
    Compare = [[5, 7, 99]; [5, 8, 99]];
elseif number == 3
    % A from CR, CNR
    Current = [5, 99 99]; 
    Compare = [[99, 7, 1]; [99, 7, 0]];
elseif number == 4
    % A from CR, CNR, AD
    Current = [5, 99, 99]; 
    Compare = [[99, 7, 1]; [99, 7, 0]; [5, 8, 99]];
elseif number == 5
    % B from BR, BNR
    Current = [6, 99, 99]; 
    Compare = [[6, 99, 1]; [6, 99, 0]];
elseif number == 6
    % B from BC, BD
    Current = [6, 99, 99]; 
    Compare = [[6, 7, 99]; [6, 8, 99]];
elseif number == 7
    % B from DR, DNR
    Current = [6, 99, 99]; 
    Compare = [[99, 8, 1]; [99, 8, 0]];
elseif number == 8
    % B from DR, DNR, BC
    Current = [6, 99, 99]; 
    Compare = [[99, 8, 1]; [99, 8, 0]; [6, 7, 99]];
elseif number == 9
    % C from CR, CNR
    Current = [99, 7, 99]; 
    Compare = [[99, 7, 1]; [99, 7, 0]];
elseif number == 10
    % D from DR, DNR
    Current = [99, 8, 99]; 
    Compare = [[99, 8, 1]; [99, 8, 0]];
elseif number == 11
    % A from BC, BD
    Current = [5, 99, 99]; 
    Compare = [[6, 7, 99]; [6, 8, 99]; [5, 99, 99]];
elseif number == 12
    % B from AC, AD
    Current = [6, 99, 99]; 
    Compare = [[5, 7, 99]; [5, 8, 99]; [6, 99, 99]];
elseif number == 13
    % Satiety Baseline
    Current = [99, 99, 99]; 
    Compare = [[99, 99, 1]; [99, 99, 0]];
elseif number == 14
    % Satiety A
    Current = [5, 99, 99]; 
    Compare = [[99, 99, 1]; [99, 99, 0]];
elseif number == 15
    % Satiety B
    Current = [6, 99, 99]; 
    Compare = [[99, 99, 1]; [99, 99, 0]];
elseif number == 16
    % Satiety C
    Current = [99, 7, 99]; 
    Compare = [[99, 99, 1]; [99, 99, 0]];
elseif number == 17
    % Satiety D
    Current = [99, 8, 99]; 
    Compare = [[99, 99, 1]; [99, 99, 0]];
elseif number == 18
    % Satiety R
    Current = [99, 99, 1]; 
    Compare = [[99, 99, 1]; [99, 99, 0]];
elseif number == 19
    % Satiety NR
    Current = [99, 99, 0]; 
    Compare = [[99, 99, 1]; [99, 99, 0]];
elseif number == 20
    % Satiety AC
    Current = [5, 7, 99]; 
    Compare = [[99, 99, 1]; [99, 99, 0]];
elseif number == 21
    % Satiety BC
    Current = [6, 7, 99]; 
    Compare = [[99, 99, 1]; [99, 99, 0]];
elseif number == 22
    % A from A, B
    Current = [5, 99, 99]; 
    Compare = [[5, 99, 99]; [6, 99, 99]];
elseif number == 23
    % B from A, B
    Current = [6, 99, 99]; 
    Compare = [[5, 99, 99]; [6, 99, 99]];
elseif number == 24
    % A from all A
    Current = [5, 99, 99]; 
    Compare = [[5, 7, 1]; [5, 7, 0]; [5, 8, 1]; [5, 8, 0]];
elseif number == 25
    % B from all B
    Current = [6, 99, 99]; 
    Compare = [[6, 7, 1]; [6, 7, 0]; [6, 8, 1]; [6, 8, 0]];
elseif number == 26
    % A from all AB
    Current = [5, 99, 99]; 
    Compare = [[5, 99, 1]; [5, 99, 0]; [6, 99, 1]; [6, 99, 0]];
elseif number == 27
    % B from all AB
    Current = [6, 99, 99]; 
    Compare = [[5, 99, 1]; [5, 99, 0]; [6, 99, 1]; [6, 99, 0]];    
elseif number == 28
    % A from all C
    Current = [5, 99, 99]; 
    Compare = [[5, 7, 1]; [5, 7, 0]; [6, 7, 1]; [6, 7, 0]];
elseif number == 29
    % B from all D
    Current = [6, 99, 99]; 
    Compare = [[5, 8, 1]; [5, 8, 0]; [6, 8, 1]; [6, 8, 0]];

elseif number == 99
    % Any from R, NR
    Current = [99, 99, 99]; 
    Compare = [[99, 99, 1]; [99, 99, 0]];
elseif number == 98
    % Any from C, D
    Current = [99, 99, 99];
    Compare = [[99, 7, 99]; [99, 8, 99]];
elseif number == 97
    % Any from A, B
    Current = [99, 99, 99]; 
    Compare = [[5, 99, 99]; [6, 99, 99]];
elseif number == 96
    % Any from CR, CNR
    Current = [99, 99, 99]; 
    Compare = [[99, 5, 1]; [99, 5, 0]];
elseif number == 95
    % Any from DR, DNR
    Current = [99, 99, 99]; 
    Compare = [[99, 6, 1]; [99, 6, 0]];
elseif number == 94
    % Any from AR, ANR
    Current = [99, 99, 99]; 
    Compare = [[5, 99, 1]; [5, 99, 0]];
elseif number == 93
    % Any from BR, BNR
    Current = [99, 99, 99]; 
    Compare = [[6, 99, 1]; [6, 99, 0]];
elseif number == 92
    % Any from AC, AD
    Current = [99, 99, 99]; 
    Compare = [[5, 7, 99]; [5, 8, 99]];
elseif number == 91
    % Any from BC, BD
    Current = [99, 99, 99]; 
    Compare = [[6, 7, 99]; [6, 8, 99]];
% elseif number == 
%     Current = []; 
%     Compare = [[]; []];
%     ShowUs = [Events(), Events()];
end

end

