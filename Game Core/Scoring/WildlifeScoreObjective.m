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

        function totalPoints = pointsForGroups(~, env, animal, shapeFunc)
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
                    
                    totalPoints = totalPoints + feval(shapeFunc, env, groupCoords);

                    overallCoordList = [overallCoordList; groupCoordList];                
                end
            end
        end

        function animalsFound = getAdjacentAnimals(~, environment, tile)
            % Gets list of animals adjacent to a tile. Uses AnimalEnum + 1
            % as index. Ex: numBears = animalList(AnimalEnum.Bear + 1);

            neighborChange = int8([1,0,-1; 0,1,-1; -1,1,0]);
            neighborChange = [neighborChange; -1.*neighborChange];

            % Array of whether we have found a particular animal
            animalsFound = zeros(1, AnimalEnum.NumAnimals);

            for j = 1:size(neighborChange,1)
                % Get neighbor tile
                neighborCoords = tile.Coordinate + neighborChange(j,:);
                neighborTile = tileAtCoords(environment, neighborCoords);
                if ~isempty(neighborTile.Animal)
                    animalsFound(neighborTile.Animal + 1) = 1;
                end
            end
        end

    end
end

