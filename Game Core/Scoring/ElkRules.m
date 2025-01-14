classdef ElkRules < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = ElkRules()

        end

        function elkGroupSizes = calculateElkGroupSizes(obj, env)
            elkGroupSizes = calculateGroupSizes(obj, env, AnimalEnum.Elk);
        end

        function score = ruleAScore(obj, environment)
            score = 0;
        end

        function score = ruleBScore(obj, environment)
            score = 0;
        end

        function score = ruleCScore(obj, environment)
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

        function score = ruleDScore(obj, environment)

        end

    end
end

