classdef Environment
    %ENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here

    properties
        StarterHabitatTile HabitatTile % The 'origin' 3 tiles
        HabitatTiles HabitatTile
        PreviewTile HabitatTile % The current spot a tile may be placed
        PreviewToken WildlifeToken % The token we are trying on for size
    end

    methods
        function obj = Environment()
            %ENVIRONMENT Construct an instance of this class
            %   Detailed explanation goes here
        end

        function tf = isPlaceableTileCoord(obj, hexCoords)
            % Determines if the hex coordinate provided is placeable in the
            % environment. Coords must not match a currently played tile in
            % environment, and must have distance of 1 from some tile in
            % the environment.

            unitDistance = false; inCurrentEnv = false;

            allTiles = [obj.StarterHabitatTile, obj.HabitatTiles];
            for i = 1:length(allTiles)
                if all(hexCoords == allTiles(i).Coordinate)
                    inCurrentEnv = true;
                end

                if HabitatTile.distance(hexCoords, allTiles(i).Coordinate) == 1
                    unitDistance = true;
                end
            end

            tf = unitDistance && ~inCurrentEnv;
        end

        function tf = isPlaceableTokenCoord(obj, hexCoords)
            % Determines if the hex coordinate provided is suitable to
            % receive a wildlife token (does not check compatibility)
            inCurrentEnv = false;
            allTiles = [obj.StarterHabitatTile, obj.HabitatTiles];
            for i = 1:length(allTiles)
                if all(hexCoords == allTiles(i).Coordinate)
                    inCurrentEnv = true;
                end
            end
            tf = inCurrentEnv;
        end

        function allTilesIdx = getTileIdx(obj, tile)
            % Given a tile, return the index in the commonly used
            % 'allTiles' array
            allTiles = [obj.StarterHabitatTile, obj.HabitatTiles];
            allTilesIdx = 0; i = 0; foundTile = false;
            while i < length(allTiles) && ~foundTile
                i = i + 1;
                if all(tile.Coordinate == allTiles(i).Coordinate)
                    foundTile = true;
                end
            end

            if foundTile
                allTilesIdx = i;
            end
        end

        function tile = tileAtCoords(obj, hexCoords)
            tile = HabitatTile();
            allTiles = [obj.StarterHabitatTile, obj.HabitatTiles];
            i = 1; tileFound = false;
            while i <= length(allTiles) && ~tileFound
                if all(hexCoords == allTiles(i).Coordinate)
                    tile = allTiles(i);
                end
                i = i + 1;
            end
        end

        function neighborTiles = getNeighborTiles(obj, tile)
            % Returns list of 6 neighbor tiles. If tile does not exist, an
            % empty tile will be returned.

            neighborTiles = HabitatTile.empty;

            neighborCoords = HabitatTile.getNeighborCoordinates(tile.Coordinate);

            for i = 1:size(neighborCoords,1)
                % Get neighbor tile
                neighborTiles(i) = tileAtCoords(obj, neighborCoords(i,:));
            end
        end

        function nTiles = largestCorridorSize(obj, terrain)
            % Calculates the size of the largest contiguous block of a
            % given terrain, in number of connected tiles.
            nTiles = 0;
            allTiles = [obj.StarterHabitatTile, obj.HabitatTiles];
            for i = 1:length(allTiles)
                currTile = allTiles(i);
                if any(currTile.Terrain == terrain)
                    coordList = recursiveGetTerrainGroupCoords(obj, currTile, terrain, currTile.Coordinate);
                    groupSize = size(coordList,1);
                    if groupSize > nTiles
                        nTiles = groupSize;
                    end
                end
            end
        end

        function newCoords = recursiveGetTerrainGroupCoords(obj, tile, terrain, coordList)
            % Returns the coordinates of a terrain group, starting from a
            % tile. Recursively builds the coords list

            % Base recursive case - list is unchanged
            newCoords = coordList;

            % Search neighbors for connected tile
            neighborTiles = getNeighborTiles(obj, tile);

            for i = 1:length(neighborTiles)
                % Get neighbor tile
                neighborTile = neighborTiles(i);
                neighborCoords = neighborTile.Coordinate;

                % If they are not currently in coords list, add and call again
                tileInCoordList = ismember(neighborCoords,coordList,"rows");

                if ~tileInCoordList && hasConnectedTerrain(tile, neighborTile, terrain)
                    coordList = [coordList; neighborCoords];
                    coordList = recursiveGetTerrainGroupCoords(obj, neighborTile, terrain, coordList);
                    % Add unique vals to newCoords - don't overwrite
                    locInA = ~ismember(coordList,newCoords,"rows");
                    newCoords = [newCoords; coordList(locInA,:)];
                end
            end
        end

        function newCoords = recursiveGetAnimalGroupCoords(obj, tile, animal, coordList)
            % Very similar to the above, but simpler in that we don't have
            % to worry about rotation.

            % Base recursive case - list is unchanged
            newCoords = coordList;

            % Search neighbors for connected tile
            neighborChange = int8([1,0,-1; 0,1,-1; -1,1,0]);
            neighborChange = [neighborChange; -1.*neighborChange];

            for i = 1:size(neighborChange,1)
                % Get neighbor tile
                neighborCoords = tile.Coordinate + neighborChange(i,:);
                neighborTile = tileAtCoords(obj, neighborCoords);

                % If they are not currently in coords list, add and call again
                tileInCoordList = ismember(neighborCoords,coordList,"rows");

                if ~isempty(neighborTile.WildlifeToken.Animal) && ...
                        (neighborTile.WildlifeToken.Animal == animal) && ~tileInCoordList
                    coordList = [coordList; neighborCoords];
                    coordList = recursiveGetAnimalGroupCoords(obj, neighborTile, animal, coordList);
                    % Add unique vals to newCoords - don't overwrite
                    locInA = ~ismember(coordList,newCoords,"rows");
                    newCoords = [newCoords; coordList(locInA,:)];
                end
            end
        end
    end
end