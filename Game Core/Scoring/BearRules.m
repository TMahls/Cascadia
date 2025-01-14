classdef BearRules < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = BearRules()

        end

        function bearGroupSizes = calculateBearGroupSizes(obj, env)
            bearGroupSizes = calculateGroupSizes(obj, env, AnimalEnum.Bear);
        end

        function score = ruleAScore(obj, environment)
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

        function score = ruleBScore(obj, environment)
            bearGroupSizes = calculateBearGroupSizes(obj, environment);
            bearTrios = nnz(bearGroupSizes == 3);           
            score = 10 * bearTrios;
        end

        function score = ruleCScore(obj, environment)
            bearGroupSizes = calculateBearGroupSizes(obj, environment);
            score = 2 * nnz(bearGroupSizes == 1) + 5 * nnz(bearGroupSizes == 2) + ...
                8 * nnz(bearGroupSizes == 3);
            if any(bearGroupSizes == 1) && any(bearGroupSizes == 2) && ...
                    any(bearGroupSizes == 3)
                score = score + 3;
            end
        end

        function score = ruleDScore(obj, environment)
            bearGroupSizes = calculateBearGroupSizes(obj, environment);
            score = 5 * nnz(bearGroupSizes == 2) + 8 * nnz(bearGroupSizes == 3) + ...
                13 * nnz(bearGroupSizes == 4);
        end
    end
end