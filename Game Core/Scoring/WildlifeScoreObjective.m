classdef WildlifeScoreObjective
    %ANIMALSCORERULE Parent class of wildlife scoring objectives

    properties
        Animal (1,1) AnimalEnum
    end

    methods
        function obj = WildlifeScoreObjective()
            %ANIMALSCORERULE Construct an instance of this class
            %   Detailed explanation goes here
        end

        % By default we populate the score rules as 'points for groups'
        % meaning we assign some number of points to a each group based on
        % its properties. These methods can be overriden for different
        % scenarios.

        function score = ruleAScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'ruleAShape');
        end

        function score = ruleBScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'ruleBShape');
        end

        function score = ruleCScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'ruleCShape');
        end

        function score = ruleDScore(obj, environment)
            score = pointsForGroups(obj, environment, obj.Animal, 'ruleDShape');
        end
    end

    methods (Access = protected) % Common utility functions

        function groupSize = calculateGroupSizes(~, env, animal)
            % List of group sizes for a particular animal and environment

            allTiles = [env.StarterHabitatTile, env.HabitatTiles];
            overallCoordList = []; groupSize = [];
            for i = 1:length(allTiles)
                currTile = allTiles(i);

                if ~isempty(overallCoordList)
                    tileNotInList = ~ismember(currTile.Coordinate,overallCoordList,"rows");
                else
                    tileNotInList = true;
                end

                if ~isempty(currTile.WildlifeToken.Animal) && ...
                        (currTile.WildlifeToken.Animal == animal) && tileNotInList
                    groupCoordList = recursiveGetAnimalGroupCoords(env, currTile, animal, currTile.Coordinate);
                    overallCoordList = [overallCoordList; groupCoordList];
                    groupSize = [groupSize, size(groupCoordList,1)];
                end
            end
        end

        function totalPoints = pointsForGroups(obj, env, animal, shapeFunc)
            % Iterates through all groups in an environment, and returns
            % the total number of points for a particular rule. 'shapeFunc'
            % is the name of a function that returns the number of
            % points a group gets based on its coordinates

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

        function points = pointsForAttribute(~, scoreTable, attribute)
            % Gives points for a certain attribute based on a score table.
            % For instance if you get 3 points for a group of size 1, 5 for
            % a group of size 2, and 7 for a group of size 3, calling
            % pointsForAttribute([3,5,7],2) returns 5
            % pointsForAttribute([3,5,7],0) returns 0
            % pointsForAttirbute([3,5,7],4) returns 7

            if attribute > length(scoreTable)
                points = scoreTable(end);
            elseif attribute > 0
                points = scoreTable(attribute);
            else
                points = 0;
            end
        end

        function animalsFound = getAdjacentAnimals(~, environment, tile)
            % Gets list of animals adjacent to a tile. Uses AnimalEnum + 1
            % as index. Ex: numBears = animalList(AnimalEnum.Bear + 1);
            % Counts number of time animal appears

            neighborTiles = getNeighborTiles(environment, tile);

            % Array of whether we have found a particular animal
            animalsFound = zeros(1, AnimalEnum.NumAnimals);

            for i = 1:length(neighborTiles)
                neighborTile = neighborTiles(i);
                neighborAnimal = neighborTile.WildlifeToken.Animal;
                if ~isempty(neighborAnimal)
                    animalsFound(neighborAnimal + 1) = ...
                        animalsFound(neighborAnimal + 1) + 1;
                end
            end
        end

        function animalTiles = getAllAnimalTiles(~, env, animal)
            % Return list of all tiles in an environment with a certain
            % animal
            allTiles = [env.StarterHabitatTile, env.HabitatTiles];
            animalTiles = HabitatTile.empty;
            for i = 1:length(allTiles)
                currTile = allTiles(i);
                if ~isempty(currTile.WildlifeToken.Animal) && ...
                        (currTile.WildlifeToken.Animal == animal)
                    animalTiles = [animalTiles; currTile];
                end
            end
        end

        function shapes = constructShapeComponentArray(~, coords, scoreTable)
            % Creates array of shape objects. Each element adds one more
            % tile until the last element is our full shape.
            % Assumes that the shape can be drawn as one line, and that we
            % care about the unit shape (1 tile)

            shapes = GroupShape.empty;
            for i = 1:length(coords)
                shapes(i) = GroupShape(coords(1:i,:), scoreTable(i));
            end
        end

        function largestScore = recursiveGetBestShapeFit(obj, groupCoords, shapes)
            % Gets the highest score for an arrangement of shapes within a
            % group

            largestScore = 0;

            for i = 1:size(groupCoords,1) % For each tile in group

                currCoords = groupCoords(i,:);

                shapeList = getShapesThatStartWith(obj, currCoords, groupCoords, shapes);

                % ASSUMPTION TIME -- Without this the algorithm is thorough
                % (and can handle un-balanced points) but super slow. We
                % will assume we only want to put the biggest shapes we
                % can-- this assumes balanced points (4 > 1 + 1 + 1 + 1).
                % That is, maximizing points / tile. This assumption also
                % only holds when we are scoring down to the unit tile. 
                shapeList = trimShapeListToLargestShapes(obj, shapeList);

                for j = 1:length(shapeList) % For each shape that starts with that tile
                    currShape = shapeList(j);
                    subGroupCoords = groupCoords;

                    % Remove shape coords from coord list
                    shapeCoords = currShape.Coordinates;
                    [~, groupCoordsIdx] = ismember(shapeCoords, groupCoords, 'rows');
                    subGroupCoords(groupCoordsIdx,:) = [];

                    % Add shape score to current score, recurse with
                    % sub-group
                    score = currShape.Score + recursiveGetBestShapeFit(obj, subGroupCoords, shapes);

                    if score > largestScore
                        largestScore = score;
                    end
                end
            end
        end

        function shapeList = getShapesThatStartWith(~, currCoords, groupCoords, shapes)
            % Based on shape set, group coordinates, and starting
            % coordinate, returns all shapes (all orientations) that can
            % start at that coordinate and fit in the group.
            % Assumes the 'shapes' array is normalized at the origin--
            % first coordinate is always [0,0,0]

            shapeList = GroupShape.empty;

            % 6 Possible rotations for each shape depending on 6 possible
            % locations for the 2nd tile in the pattern.
            idx = 1;
            for i = 1:length(shapes)
                currShape = shapes(i);
                currShape.Coordinates = currShape.Coordinates + currCoords;
                if size(currShape.Coordinates,1) > 1
                    for rot = 0:5
                        testShape = rotateShape(currShape, rot);

                        if all(ismember(testShape.Coordinates, groupCoords, 'rows'))
                            shapeList(idx) = testShape;
                            idx = idx + 1;
                        end
                    end
                else
                    if ismember(currShape.Coordinates, groupCoords, 'rows')
                        shapeList(idx) = currShape;
                        idx = idx + 1;
                    end
                end
            end
        end

        function shapeList = trimShapeListToLargestShapes(~, shapeList)
            % 1 - Get largest shape size in list
            biggestShape = 0;
            for i = 1:length(shapeList)
                currShape = shapeList(i);
                shapeSize = size(currShape.Coordinates, 1);
                if shapeSize > biggestShape
                    biggestShape = shapeSize;
                end
            end

            % 2 - Remove all smaller shapes
            i = 1;
            while i <= length(shapeList)
                currShape = shapeList(i);
                shapeSize = size(currShape.Coordinates, 1);
                if shapeSize < biggestShape
                    shapeList(i) = [];
                else
                    i = i + 1;
                end
            end
        end

    end
end

