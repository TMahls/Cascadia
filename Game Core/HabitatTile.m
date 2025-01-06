classdef HabitatTile
    %HABITATTILE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Terrain % 1-2 array Enumeration Terrain
        CompatibleWildlife % 1-3 array of Animal Enum
        Status % Out of play, hidden, used by player, in center
        Orientation (1,1) uint8 % When in play, for non-keystone
        Coordinate (1,3) int8 % When in play
        WildlifeToken (1,1) WildlifeToken % When in play
    end

    methods
        function obj = HabitatTile()
            %HABITATTILE Construct an instance of this class
            % Ensure we start at the default (upright) orientation
            obj.Orientation = 1; 
        end

        function tf = isKeystoneTile(obj)
            %ISKEYSTONETILE Returns true when the tile is a keystone tile
            %   Tiles either have 1 terrain and are keystone tiles, or 2
            %   and are not.
            tf = isscalar(obj.Terrain);
        end
    end

    methods (Static)
        function [centerX, centerY] = hex2cart(coordinate, sideLength)
            coordinate = double(coordinate);
            centerX = sideLength * sqrt(3)/2 * (coordinate(1) - coordinate(3));
            centerY = sideLength * (coordinate(2) + -0.5*(coordinate(1) + coordinate(3)));
        end
    end
end

