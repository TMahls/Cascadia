classdef WildlifeToken
    %WILDLIFETOKEN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Animal
        Status % Hidden (in bag), used by player, or in center
    end
    
    methods
        function obj = WildlifeToken()
            %WILDLIFETOKEN Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

