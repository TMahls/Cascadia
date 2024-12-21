classdef ColorEnum
    %COLORENUM Summary of this class goes here
    %   Detailed explanation goes here

    properties
        rgbValues (1,3) double
    end

    methods
        function obj = ColorEnum(rgb)
            obj.rgbValues = rgb;
        end
    end

    enumeration
        Black ([0,0,0])
        
        % Habitats
        DarkBlue ([36, 39, 255])
        LightGreen ([107, 219, 46])
        DarkGreen ([34, 69, 30])
        Grey ([92, 91, 90])
        Yellow ([204, 163, 0])

        % Animals
        Brown ([46, 31, 17])
        LightBrown ([201, 158, 115])
        Pink ([247, 116, 177])
        LightBlue ([116, 201, 247])
        Orange ([250, 127, 5])
    end
end

