classdef ElkRules < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = ElkRules()
            obj.Animal = AnimalEnum.Elk;
        end

        function score = ruleAScore(obj, environment)
            score = 0;
        end

        function score = ruleBScore(obj, environment)
            score = 0;
        end

        function score = ruleDScore(obj, environment)
            score = 0;
        end

        function groupScore = ruleCShape(obj, ~, groupCoords)
            scoreTable = [2 4 7 10 14 18 23 28];
            groupScore = pointsForAttribute(obj, scoreTable, size(groupCoords,1));  
        end

    end
end

