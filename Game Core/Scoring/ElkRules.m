classdef ElkRules < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = ElkRules()
            obj.Animal = AnimalEnum.Elk;
        end

        function groupScore = ruleAShape(obj, ~, groupCoords)
            % Line shape
            scoreTable = [2 5 9 13];

            lineCoords = [0 0 0; 1 0 -1; 2 0 -2; 3 0 -3];

            % Make struct array
            shapes = constructShapeComponentArray(obj, lineCoords, scoreTable);

            groupScore = recursiveGetBestShapeFit(obj, groupCoords, shapes);
        end

        function groupScore = ruleBShape(obj, ~, groupCoords)
            % Diamond shape
            scoreTable = [2 5 9 13];

            diamondCoords = [0 0 0; 0 -1 1; 1 -1 0; 1 -2 1];

            % Make struct array
            shapes = constructShapeComponentArray(obj, diamondCoords, scoreTable);

            groupScore = recursiveGetBestShapeFit(obj, groupCoords, shapes);
        end

        function groupScore = ruleCShape(obj, ~, groupCoords)
            scoreTable = [2 4 7 10 14 18 23 28];
            groupScore = pointsForAttribute(obj, scoreTable, size(groupCoords,1));  
        end

        function groupScore = ruleDShape(obj, ~, groupCoords)
            % Ring shape
            scoreTable = [2 5 8 12 16 21];

            ringCoords = [0 0 0; 1 0 -1; 2 -1 -1; 2 -2 0; 1 -2 1; 0 -1 1];

            % Make struct array
            shapes = constructShapeComponentArray(obj, ringCoords, scoreTable);

            groupScore = recursiveGetBestShapeFit(obj, groupCoords, shapes);
        end             

    end
    
end

