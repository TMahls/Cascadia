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
        % UI Colors
        Black ([0, 0, 0]./255)
        Gold ([168, 133, 35]./255)
        White  ([255, 255, 255]./255)
        Red ([255, 0, 0]./255)
        
        % Habitats
        DarkBlue ([36, 39, 255]./255)
        LightGreen ([107, 219, 46]./255)
        DarkGreen ([34, 69, 30]./255)
        Grey ([92, 91, 90]./255)
        Yellow ([204, 163, 0]./255)

        % Animals
        Brown ([46, 31, 17]./255)
        LightBrown ([201, 158, 115]./255)
        Pink ([247, 116, 177]./255)
        LightBlue ([116, 201, 247]./255)
        Orange ([250, 127, 5]./255)
    end
end

