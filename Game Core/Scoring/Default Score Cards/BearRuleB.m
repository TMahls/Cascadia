classdef BearRuleB < BearRule
    
    properties
        
    end
    
    methods
        function obj = BearRuleB()

        end

        function score = calculateScore(obj, environment)
            bearGroupSizes = calculateBearGroupSizes(obj, environment);
            bearTrios = nnz(bearGroupSizes == 3);           
            score = 10 * bearTrios;
        end
    end
end

