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

            % Give it a NaN starting coordinate
            obj.Coordinate = uint8([127,127,127]);
        end

        function tf = isKeystoneTile(obj)
            %ISKEYSTONETILE Returns true when the tile is a keystone tile
            %   Tiles either have 1 terrain and are keystone tiles, or 2
            %   and are not.
            tf = isscalar(obj.Terrain);
        end
    end

    methods (Static)
        function cartCoords = hex2cart(coordinate, sideLength)
            % Gets cartesian coordinate of hex center from hex coords
            coordinate = double(coordinate);
            centerX = sideLength * sqrt(3)/2 * (coordinate(1) - coordinate(3));
            centerY = sideLength * (coordinate(2) + -0.5*(coordinate(1) + coordinate(3)));
            cartCoords = [centerX centerY];
        end

        function hexCoords = cart2hex(coordinate, sideLength)
            % Gets hex coordinates from cartesian coords, snaps to nearest
            % integer hex center coords

            % 'a' axis is -30 degrees offset from x axis
            theta = deg2rad(-30);
            a = (cos(theta) * coordinate(1) + sin(theta) * coordinate(2)) / sideLength * 2/3; 

            % 'b' axis is coaxial with y axis
            b = coordinate(2) / sideLength * 2/3;

            % Snap to nearest integer coordinates
            % There's probably a smarter way to do this beyond trial and
            % error. But it's only 4 combos to test. round() wouldn't always
            % work here because hex coord distance is weird.
            aCombos = [floor(a) ceil(a)];
            bCombos = [floor(b) ceil(b)];
            euclidDist = zeros(2);
            for i = 1:length(aCombos)
                for j = 1:length(bCombos)
                    testHexCoords = [aCombos(i), bCombos(j), 0 - aCombos(i) - bCombos(j)];
                    centerCartCoords = HabitatTile.hex2cart(testHexCoords, sideLength);
                    euclidDist(i,j) = norm(centerCartCoords - coordinate(1:2));
                end
            end

            [~,idx] = min(euclidDist,[],'all');        
            [aIdx, bIdx] = ind2sub(size(euclidDist),idx);
            a = aCombos(aIdx);
            b = bCombos(bIdx);

            c = 0 - a - b; % Axial coords to cube coords - c is derived
            hexCoords = int8([a b c]);
        end

        function dist = distance(coords1, coords2)
            % Manhattan distance between 2 tiles
            diffVec = coords1 - coords2;
            dist = sum(abs(diffVec)) / 2;
        end
    end
end

