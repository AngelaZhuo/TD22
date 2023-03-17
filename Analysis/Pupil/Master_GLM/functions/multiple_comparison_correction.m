function [H,alph_corrected]=multiple_comparison_correction(p_values,alph,type)
%     [H,alph_corrected]=multiple_comparison_correction(p_values,alph,type)
%  'holm'  'benjamini'  'bonferroni'
    M1=size(p_values,1);
    M2=size(p_values,2);
    p_values_aus=p_values(:);
    if size(p_values_aus,1)<size(p_values_aus,2)
        p_values_aus=p_values_aus';
    end
    number_tests=length(p_values_aus);
    
    switch type
        case 'holm'
            %% Holm–Bonferroni 
            x=1:length(p_values_aus);
            p_values_aus=sort(p_values_aus);          
            p_values_aus_alpha=alph./(number_tests+1-x)';
            aus=find((p_values_aus-p_values_aus_alpha)<=0);

            if isempty(aus)
                alph_corrected=min(p_values_aus);
            else
                alph_corrected=p_values_aus_alpha(aus(end));
            end   
            h=p_values<alph_corrected;

        case 'benjamini'
            %% Benjamini-Hochberg 
            x=1:length(p_values_aus);
            p_values_aus=sort(p_values_aus);
            p_values_alpha=(alph*x)./number_tests;
            aus=find((p_values_aus'-p_values_alpha)<=0);
            
            
            
            if isempty(aus)
                alph_corrected=alph./number_tests;
                h=p_values<=(alph_corrected-1); %no value
            else
                alph_corrected=p_values_aus(aus(end));   
                h=p_values<=alph_corrected;
            end

        case 'bonferroni'
            %% Bonferroni
            alph_corrected=alph./number_tests;
            h=p_values<alph_corrected;
     
    end   
    H=reshape(h,[M1,M2]);
end