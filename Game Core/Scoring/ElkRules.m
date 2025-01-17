classdef ElkRules < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = ElkRules()
            obj.Animal = AnimalEnum.Elk;
        end

        function groupScore = ruleAShape(obj, ~, groupCoords)
            groupScore = 0;
        end

        function groupScore = ruleBShape(obj, ~, groupCoords)
            groupScore = 0;
        end

        function groupScore = ruleCShape(obj, ~, groupCoords)
            scoreTable = [2 4 7 10 14 18 23 28];
            groupScore = pointsForAttribute(obj, scoreTable, size(groupCoords,1));  
        end

        function groupScore = ruleDShape(obj, ~, groupCoords)
            groupScore = 0;
        end

    end
end

