classdef SalmonRules < WildlifeScoreObjective

    properties

    end

    methods
        function obj = SalmonRules()
            obj.Animal = AnimalEnum.Salmon;
        end

        function groupScore = ruleAShape(obj, environment, groupCoords)
            groupScore = 0;
            scoreTable = [2 5 8 12 16 20 25];
            if isRun(obj, environment, groupCoords)
                groupScore = pointsForAttribute(obj, scoreTable, size(groupCoords,1));
            end
        end

        function groupScore = ruleBShape(obj, environment, groupCoords)
            groupScore = 0;
            scoreTable = [2 4 9 11 17];
            if isRun(obj, environment, groupCoords)
                groupScore = pointsForAttribute(obj, scoreTable, size(groupCoords,1));
            end
        end

        function groupScore = ruleCShape(obj, environment, groupCoords)
            groupScore = 0;
            scoreTable = [0 0 10 12 15];
            if isRun(obj, environment, groupCoords)
                groupScore = pointsForAttribute(obj, scoreTable, size(groupCoords,1));
            end
        end

        function groupScore = ruleDShape(obj, environment, groupCoords)
            groupScore = 0;
            if isRun(obj, environment, groupCoords)
                runLength = size(groupCoords,1);

                adjacentAnimalCoords = [];
                for i = 1:size(groupCoords,1)
                    currTile = tileAtCoords(environment, groupCoords(i,:));
                    neighborTiles = getNeighborTiles(environment, currTile);

                    for j = 1:length(neighborTiles)
                        neighborTile = neighborTiles(j);
                        if ~isempty(neighborTile.WildlifeToken.Animal) && ...
                                (isempty(adjacentAnimalCoords) || ...
                                ~ismember(neighborTile.Coordinate, adjacentAnimalCoords, "rows"))
                            adjacentAnimalCoords = [adjacentAnimalCoords; neighborTile.Coordinate];
                        end
                    end
                end

                adjacentAnimals = size(adjacentAnimalCoords, 1);

                groupScore = runLength + adjacentAnimals;
            end
        end
    end

    methods(Access = private)
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

