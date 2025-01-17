classdef BearRules < WildlifeScoreObjective

    properties

    end

    methods
        function obj = BearRules()
            obj.Animal = AnimalEnum.Bear;
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

        function groupScore = ruleBShape(obj, environment, groupCoords)
            groupScore = 0;
            if size(groupCoords,1) == 3
                groupScore = 10;
            end
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

        function groupScore = ruleDShape(obj, environment, groupCoords)
            groupScore = 0;
            switch size(groupCoords,1)
                case 2
                    groupScore = 5;
                case 3
                    groupScore = 8;
                case 4
                    groupScore = 13;
            end
        end
    end

    methods (Access = private)
        function bearGroupSizes = calculateBearGroupSizes(obj, env)
            bearGroupSizes = calculateGroupSizes(obj, env, obj.Animal);
        end
    end

end