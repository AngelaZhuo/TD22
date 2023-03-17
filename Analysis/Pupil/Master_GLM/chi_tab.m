function [tabs, chi2, p, labs] = chi_tab(x)
        Valers = sum(x, "all"); % Total value units
        X = NaN(2, Valers); % 
        X(1, 1:sum(x(1,:))) = 1; 
        X(1, end-sum(x(2,:))+1:end) = 2; 
        X(2, :) = 1;
        X(2, 1:x(1,2)) = 2;
        X(2, end-x(2,2) + 1:end) = 2;

        [tabs, chi2, p, labs] = crosstab(X(1,:)',X(2,:)');
end



x = [537, 1073-537; 206, 883-206] % p<e-34
x = [137, 1073-137; 337, 883-337]; % p<e-38

x = [360, 902-360; 26, 69-26] % p = 0.75
x = [337, 883-337; 137, 1073-137] % p < e-38





%%
Tot = 113
a = 6
b = 2

x = [a, Tot-a; b, Tot-b]
Valers = sum(x, "all"); % Total value units
X = NaN(2, Valers); % 
X(1, 1:sum(x(1,:))) = 1; 
X(1, end-sum(x(2,:))+1:end) = 2; 
X(2, :) = 1;
X(2, 1:x(1,2)) = 2;
X(2, end-x(2,2) + 1:end) = 2;

[tabs, chi2, p, labs] = crosstab(X(1,:)',X(2,:)')


for teil = 1:numel(Regions)
    Regions{teil}
    X = [DID.(Regions{teil}).ve1(1), DID.(Regions{teil}).lvi1(1);...
        DID.(Regions{teil}).lve1(1), DID.(Regions{teil}).vi1(1)];
    [tabs, chi2, p, labs] = crosstab(X(1,:)',X(2,:)');
    "CS1 p "
    p
    
    X = [DID.(Regions{teil}).ve2(1), DID.(Regions{teil}).lvi2(1);...
        DID.(Regions{teil}).lve2(1), DID.(Regions{teil}).vi2(1)];
    [tabs, chi2, p, labs] = crosstab(X(1,:)',X(2,:)');
    "CS2 p "
    p
end

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    





