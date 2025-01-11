classdef GameModeEnum < uint8
    %GAMEMODEENUM Summary of this class goes here
    %   Detailed explanation goes here

    enumeration
        EasyRules (0)
        RandomRules (1)
        FamilyVariant (2)
        IntermediateVariant (3)
        CustomRules (4)
        NumGameModes (5)
    end

    methods
        function text = getString(obj)
            switch obj
                case GameModeEnum.EasyRules
                    text = "Easy (A) Scoring Objectives";
                case GameModeEnum.RandomRules
                    text = "Random Scoring Objectives";
                case GameModeEnum.FamilyVariant
                    text = "Family Variant";
                case GameModeEnum.IntermediateVariant
                    text = "Intermediate Variant";
                case GameModeEnum.CustomRules
                    text = "Custom Scoring Objectives";
                otherwise
                    text = "Rule text not found. This is a bug!";
            end
        end
    end
end