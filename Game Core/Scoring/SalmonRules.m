classdef SalmonRules < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = SalmonRules()

        end

        function score = ruleAScore(obj, environment)
            score = pointsForGroups(obj, environment, AnimalEnum.Salmon, 'salmonAShape');
        end

        function score = ruleBScore(obj, environment)
            score = pointsForGroups(obj, environment, AnimalEnum.Salmon, 'salmonBShape');
        end

        function score = ruleCScore(obj, environment)
            score = pointsForGroups(obj, environment, AnimalEnum.Salmon, 'salmonCShape');
        end

        function score = ruleDScore(obj, environment)
            score = pointsForGroups(obj, environment, AnimalEnum.Salmon, 'salmonDShape');
        end
        
    end

    methods (Access = private)

        function groupScore = salmonAShape(~, ~, groupCoords)
            groupScore = 0;
            scoreTable = [2 5 8 12 16 20 25];
            if isRun(groupCoords)
                runLength = size(groupCoords,1);
                if runLength > length(scoreTable)
                    groupScore = scoreTable(end);
                else
                    groupScore = scoreTable(runLength);
                end
            end
        end

        function groupScore = salmonBShape(~, ~, groupCoords)
            groupScore = 0;
            scoreTable = [2 4 9 11 17];
            if isRun(groupCoords)
                runLength = size(groupCoords,1);
                if runLength > length(scoreTable)
                    groupScore = scoreTable(end);
                else
                    groupScore = scoreTable(runLength);
                end
            end
        end

        function groupScore = salmonCShape(~, ~, groupCoords)
            groupScore = 0;
            scoreTable = [0 0 10 12 15];
            if isRun(groupCoords)
                runLength = size(groupCoords,1);
                if runLength > length(scoreTable)
                    groupScore = scoreTable(end);
                else
                    groupScore = scoreTable(runLength);
                end
            end
        end

        function groupScore = salmonDShape(~, environment, groupCoords)
            groupScore = 0;
            if isRun(groupCoords)
                runLength = size(groupCoords,1);

                adjacentAnimalCoords = [];
                for i = 1:size(groupCoords,1)                                      
                    neighborTiles = getNeighborTiles(environment, groupCoords(i,:));

                    for j = 1:length(neighborTiles)
                        neighborTile = neighborTiles(j);
                        if ~isempty(neighborTile.WildlifeToken.Animal) && ...
                                ~ismember(neighborTile.Coordinate, adjacentAnimalCoords, "rows")
                            adjacentAnimalCoords = [adjacentAnimalCoords; neighborTile.Coordinate];
                        end
                    end                   
                end

                adjacentAnimals = size(adjacentAnimalCoords, 1);
                
                groupScore = runLength + adjacentAnimals;
            end
        end

        function tf = isRun(obj, groupCoords)
            % Determines whether a group of animals is a 'run'. Each salmon
            % must have at most 2 neighbor salmon
            tf = true;
            for i = 1:size(groupCoords,1)
                currTile = tileAtCoords(environment, groupCoords(i,:));
                runNeighbors = getAdjacentAnimals(obj, environment, currTile);

                if runNeighbors(AnimalEnum.Salmon + 1) > 2
                    tf = false;
                end
            end
        end

    end
end

