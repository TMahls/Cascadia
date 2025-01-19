classdef SalmonRules < WildlifeScoreObjective
    % IMPORTANT NOTE - There are 2 interpretations for how you can score
    % salmon. The first is following the rulebook: 'Each run of salmon may not
    % have any other salmon adjacent to it'. This means if a run is malformed,
    % you get 0 points for the entire group. However, in the following posts
    % Randy Flynn posits that Salmon should be scored differently:
    %
    % https://boardgamegeek.com/thread/2512694/clarification-on-scoring-salmon-run
    % https://boardgamegeek.com/thread/3087149/salmon-scoring-with-1-wrongly-placed-salmon
    % https://boardgamegeek.com/thread/2809804/tiles-and-salmon-scoring
    % https://boardgamegeek.com/thread/2774858/salmon-card-a-clarification
    %
    % His online version also follows this more forgiving scoring-- a salmon
    % group that isn't wholly a run can have violating tokens removed, and smaller
    % runs scored individually. I choose to follow Randy's approach here.

    properties

    end

    methods
        function obj = SalmonRules()
            obj.Animal = AnimalEnum.Salmon;
        end

        function groupScore = ruleAShape(obj, ~, groupCoords)
            scoreTable = [2 5 8 12 16 20 25];
            groupScore = pointsForAttribute(obj, scoreTable, size(groupCoords,1));
        end

        function groupScore = ruleBShape(obj, ~, groupCoords)
            scoreTable = [2 4 9 11 17];
            groupScore = pointsForAttribute(obj, scoreTable, size(groupCoords,1));
        end

        function groupScore = ruleCShape(obj, ~, groupCoords)
            scoreTable = [0 0 10 12 15];
            groupScore = pointsForAttribute(obj, scoreTable, size(groupCoords,1));
        end

        function groupScore = ruleDShape(obj, environment, groupCoords)
            groupScore = 0;
            if size(groupCoords,1) >= 3
                runLength = size(groupCoords,1);

                adjacentAnimalCoords = [];
                for i = 1:size(groupCoords,1)
                    currTile = tileAtCoords(environment, groupCoords(i,:));
                    neighborTiles = getNeighborTiles(environment, currTile);

                    for j = 1:length(neighborTiles)
                        neighborTile = neighborTiles(j);
                        if ~isempty(neighborTile.WildlifeToken.Animal) && ...
                                (neighborTile.WildlifeToken.Animal ~= obj.Animal) && ...
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

    methods (Access = protected)
        function totalPoints = pointsForGroups(obj, env, animal, shapeFunc)
            % Iterates through all groups in an environment, and returns
            % the total number of points for a particular rule. 'shapeFunc'
            % is the name of a function that returns the number of
            % points a group gets based on its coordinates
            % Overloading from parent class for Salmon -- first we
            % eliminate any violating salmon, then count groups

            % Remove violating salmon
            allTiles = [env.StarterHabitatTile, env.HabitatTiles];
            oldEnv = env; 
            for i = 1:length(allTiles)
                currTile = allTiles(i);
                if ~isempty(currTile.WildlifeToken.Animal) && ...
                        (currTile.WildlifeToken.Animal == obj.Animal)
                    animalsFound = getAdjacentAnimals(obj, oldEnv, currTile);

                    if animalsFound(obj.Animal + 1) > 2
                        if i > length(env.StarterHabitatTile)
                            env.HabitatTiles(i - length(env.StarterHabitatTile)).WildlifeToken = WildlifeToken();
                        else
                            env.StarterHabitatTile(i).WildlifeToken = WildlifeToken();
                        end
                    end
                end
            end

            allTiles = [env.StarterHabitatTile, env.HabitatTiles];
            totalPoints = 0; overallCoordList = [];
            for i = 1:length(allTiles)
                currTile = allTiles(i);

                if ~isempty(overallCoordList)
                    tileNotInList = ~ismember(currTile.Coordinate,overallCoordList,"rows");
                else
                    tileNotInList = true;
                end

                if ~isempty(currTile.WildlifeToken.Animal) && ...
                        (currTile.WildlifeToken.Animal == animal) && tileNotInList
                    groupCoords = recursiveGetAnimalGroupCoords(env, currTile, animal, currTile.Coordinate);

                    totalPoints = totalPoints + feval(shapeFunc, obj, env, groupCoords);

                    overallCoordList = [overallCoordList; groupCoords];
                end
            end
        end
    end

end
