function Array = ExtractSignigicance(Regressor, Population, Events)
    n=0;
    Array = NaN(1, Events(7));
    Fields = fields(Population);
    for f = 1:numel(Fields)
        [haim, makom] = ismember(Regressor, Population.(Fields{f}).Labels);
        if haim
            n=1;
            CPD = Population.(Fields{f}).CPD(makom, :);
            pVal = Population.(Fields{f}).pVal(makom, :);
            pVal = pVal<0.05; pVal = double(pVal); pVal(pVal==0) = NaN;
            Array(Population.(Fields{f}).Range(1):Population.(Fields{f}).Range(2)) = CPD.*pVal;
        end
    end
    if n == 0
        "Regressor not found"
    end
end