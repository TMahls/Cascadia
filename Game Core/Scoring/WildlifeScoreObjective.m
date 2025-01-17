classdef WildlifeScoreObjective
    %ANIMALSCORERULE Parent class of wildlife scoring objectives
    
    properties
        Animal
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
            animalTiles = [];
            for i = 1:length(allTiles)
                currTile = allTiles(i);
                if ~isempty(currTile.WildlifeToken.Animal) && ...
                        (currTile.WildlifeToken.Animal == animal)
                    animalTiles = [animalTiles; currTile];
                end
            end
        end

    end
end

