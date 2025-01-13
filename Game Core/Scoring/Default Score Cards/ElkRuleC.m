classdef ElkRuleC < ElkRule
    
    properties
        
    end
    
    methods
        function obj = ElkRuleC()

        end

        function score = calculateScore(obj, environment)
            elkGroupSizes = calculateElkGroupSizes(obj, environment);
            
            score = 0;
            pointAmounts = [2,4,7,10,14,18,23,28];
            for groupSize = 2:8
                score = score + pointAmounts(groupSize - 1) * nnz(elkGroupSizes == groupSize);
            end
        end
    end
end

