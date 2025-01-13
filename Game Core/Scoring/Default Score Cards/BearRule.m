classdef BearRule < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = BearRule()

        end

        function bearGroupSizes = calculateBearGroupSizes(obj, env)
            bearGroupSizes = calculateGroupSizes(obj, env, AnimalEnum.Bear);
        end
    end
end

