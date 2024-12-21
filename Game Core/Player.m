classdef Player
    %PLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Environment Environment % The game map
        NatureTokens (1,1) uint8 % Number of tokens
        Name char
        AvailableActions % Current legal moves
    end
    
    methods
        function obj = Player()
            %PLAYER Construct an instance of this class
            %   Detailed explanation goes here
            obj.Environment = Environment();
            obj.NatureTokens = 0;
        end

        % Player Actions
        function player = getAvailableActions(obj)
        % Perform overpopulation wipe of 4 in while loop
        
            player = obj;

        end
        function rotateHabitatTile(obj, HabitatTile)

        end

        function placeHabitatTile(obj,HabitatTile)

        end

        function placeWildlifeToken(obj,NatureToken)

        end

        function discardWildlifeToken(obj,NatureToken)

        end

        function spendNatureToken(obj)

        end

        function overpopulationWipe(obj)

        end

    end
end