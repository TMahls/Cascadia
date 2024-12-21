classdef Environment
    %ENVIRONMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        StarterHabitatTile (3,1) HabitatTile % The 'origin' 3 tiles
        HabitatTiles 
    end
    
    methods
        function obj = Environment()
            %ENVIRONMENT Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

