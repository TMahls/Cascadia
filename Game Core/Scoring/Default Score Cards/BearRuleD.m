classdef BearRuleD < BearRule
    
    properties
        
    end
    
    methods
        function obj = BearRuleD()

        end

        function score = calculateScore(obj, environment)
            bearGroupSizes = calculateBearGroupSizes(obj, environment);
            score = 5 * nnz(bearGroupSizes == 2) + 8 * nnz(bearGroupSizes == 3) + ...
                13 * nnz(bearGroupSizes == 4);
        end
    end
end

