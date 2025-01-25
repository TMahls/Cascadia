classdef DifficultyEnum < uint8
    %GAMEMODEENUM Summary of this class goes here
    %   Detailed explanation goes here

    enumeration
        Easy (0)
        Medium (1)
        Hard (2)
    end

    methods
        function text = getString(obj)
            switch obj
                case DifficultyEnum.Easy
                    text = "EZ";
                case DifficultyEnum.Medium
                    text = "Mid";
                case DifficultyEnum.Hard
                    text = "Smart";
                otherwise
                    text = "Difficulty text not found. This is a bug!";
            end
        end
    end
end