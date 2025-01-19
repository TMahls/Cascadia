classdef BearRules < WildlifeScoreObjective

    properties

    end

    methods
        function obj = BearRules()
            obj.Animal = AnimalEnum.Bear;
        end

        function score = ruleAScore(obj, environment)
            bearGroupSizes = calculateGroupSizes(obj, environment, obj.Animal);
            bearPairs = nnz(bearGroupSizes == 2);

            scoreTable = [4 11 19 27];
            score = pointsForAttribute(obj, scoreTable, bearPairs);
        end

        function groupScore = ruleBShape(obj, ~, groupCoords)
            scoreTable = [0 0 10];
            groupScore = pointsForAttribute(obj, scoreTable, size(groupCoords,1));  
        end

        function score = ruleCScore(obj, environment)
            bearGroupSizes = calculateGroupSizes(obj, environment, obj.Animal);
            score = 2 * nnz(bearGroupSizes == 1) + 5 * nnz(bearGroupSizes == 2) + ...
                8 * nnz(bearGroupSizes == 3);
            if any(bearGroupSizes == 1) && any(bearGroupSizes == 2) && ...
                    any(bearGroupSizes == 3)
                score = score + 3;
            end
        end

        function groupScore = ruleDShape(obj, ~, groupCoords)
            scoreTable = [0 5 8 13];
            groupScore = pointsForAttribute(obj, scoreTable, size(groupCoords,1));           
        end
    end

end