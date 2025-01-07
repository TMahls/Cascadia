classdef Environment
    %ENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StarterHabitatTile (3,1) HabitatTile % The 'origin' 3 tiles
        HabitatTiles HabitatTile
        PreviewTile HabitatTile % The current spot a tile may be placed
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
    end
end

