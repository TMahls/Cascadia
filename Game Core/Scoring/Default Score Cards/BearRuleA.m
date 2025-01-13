classdef BearRuleA < BearRule
    
    properties
        
    end
    
    methods
        function obj = BearRuleA()

        end

        function score = calculateScore(obj, environment)
            bearGroupSizes = calculateBearGroupSizes(obj, environment);
            bearPairs = nnz(bearGroupSizes == 2);
            
            score = 0;
            if bearPairs == 1
                score = 4;
            elseif bearPairs == 2
                score = 11;
            elseif bearPairs == 3
                score = 19;
            elseif bearPairs >= 4
                score = 27;
            end
        end
    end
end

