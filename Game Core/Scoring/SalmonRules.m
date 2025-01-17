classdef SalmonRules < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = SalmonRules()
            obj.Animal = AnimalEnum.Salmon;
        end

        function score = ruleAScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'salmonAShape');
        end

        function score = ruleBScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'salmonBShape');
        end

        function score = ruleCScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'salmonCShape');
        end

        function score = ruleDScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'salmonDShape');
        end
        

        function groupScore = salmonAShape(obj, environment, groupCoords)
            groupScore = 0;
            scoreTable = [2 5 8 12 16 20 25];
            if isRun(obj, environment, groupCoords)
                runLength = size(groupCoords,1);
                if runLength > length(scoreTable)
                    groupScore = scoreTable(end);
                else
                    groupScore = scoreTable(runLength);
                end
            end
        end

        function groupScore = salmonBShape(obj, ~, groupCoords)
            groupScore = 0;
            scoreTable = [2 4 9 11 17];
            if isRun(obj, environment, groupCoords)
                runLength = size(groupCoords,1);
                if runLength > length(scoreTable)
                    groupScore = scoreTable(end);
                else
                    groupScore = scoreTable(runLength);
                end
            end
        end

        function groupScore = salmonCShape(obj, ~, groupCoords)
            groupScore = 0;
            scoreTable = [0 0 10 12 15];
            if isRun(obj, environment, groupCoords)
                runLength = size(groupCoords,1);
                if runLength > length(scoreTable)
                    groupScore = scoreTable(end);
                else
                    groupScore = scoreTable(runLength);
                end
            end
        end

        function groupScore = salmonDShape(obj, environment, groupCoords)
            groupScore = 0;
            if isRun(obj, environment, groupCoords)
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

        function tf = isRun(obj, environment, groupCoords)
            % Determines whether a group of animals is a 'run'. Each salmon
            % must have at most 2 neighbor salmon
            tf = true;
            for i = 1:size(groupCoords,1)
                currTile = tileAtCoords(environment, groupCoords(i,:));
                animalsFound = getAdjacentAnimals(obj, environment, currTile);

                if animalsFound(obj.Animal + 1) > 2
                    tf = false;
                end
            end
        end

    end
end

