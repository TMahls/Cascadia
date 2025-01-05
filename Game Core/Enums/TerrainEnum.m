classdef TerrainEnum < uint8
    %TERRAINENUM Summary of this class goes here
    %   Detailed explanation goes here
    enumeration
        River (0)
        Wetland (1)
        Forest (2)
        Mountain (3)
        Prairie (4)
        NumTerrains (5)
    end

    methods
        function color = getColor(obj)
            switch obj
                case TerrainEnum.River
                    color = ColorEnum.DarkBlue;
                case TerrainEnum.Wetland
                    color = ColorEnum.LightGreen;
                case TerrainEnum.Forest
                    color = ColorEnum.DarkGreen;
                case TerrainEnum.Mountain
                    color = ColorEnum.Grey;
                case TerrainEnum.Prairie
                    color = ColorEnum.Yellow;
                otherwise
                    color = ColorEnum.Black;
            end
        end
    end
end

