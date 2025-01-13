classdef BearRuleC < BearRule
    
    properties
        
    end
    
    methods
        function obj = BearRuleC()

        end

        function score = calculateScore(obj, environment)
            bearGroupSizes = calculateBearGroupSizes(obj, environment);
            score = 2 * nnz(bearGroupSizes == 1) + 5 * nnz(bearGroupSizes == 2) + ...
                8 * nnz(bearGroupSizes == 3);
            if any(bearGroupSizes == 1) && any(bearGroupSizes == 2) && ...
                    any(bearGroupSizes == 3)
                score = score + 3;
            end
        end
    end
end

