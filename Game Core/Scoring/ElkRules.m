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
            % This one's a bit unique-- while other cards have a 'score
            % cap' for having many of the same scoring animal, Elk groups
            % can be connected. So a group of 10 is meant to be scored as 8
            % + 2, despite the card suggesting otherwise. 
            % https://boardgamegeek.com/thread/3128275/a-contradiction-in-elk-c-scoring-rulebook-vs-card/page/2

            scoreTable = [2 4 7 10 14 18 23 28];
            groupSize = size(groupCoords,1);
            if groupSize <= length(scoreTable)
                groupScore = pointsForAttribute(obj, scoreTable, groupSize);  
            else % Modified behavior for groups over the cap
                biggestGroups = floor(groupSize / length(scoreTable));
                remainder = mod(groupSize, length(scoreTable));
                groupScore = biggestGroups * scoreTable(end) + scoreTable(remainder);
            end
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

