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
            for groupSize = 1:8
                if groupSize ~= 8
                    score = score + pointAmounts(groupSize) * nnz(elkGroupSizes == groupSize);
                else
                    score = score + pointAmounts(groupSize) * nnz(elkGroupSizes >= groupSize);
                end
            end
        end
    end
end

