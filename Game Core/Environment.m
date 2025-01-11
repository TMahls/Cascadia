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

        function nTiles = largestCorridorSize(obj, terrain)
            % Calculates the size of the largest contiguous block of a
            % given terrain, in number of connected tiles.
            nTiles = 1;
        end
    end
end

