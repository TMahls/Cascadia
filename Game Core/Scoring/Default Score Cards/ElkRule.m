classdef ElkRule < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = ElkRule()

        end

        function elkGroupSizes = calculateElkGroupSizes(obj, env)
            elkGroupSizes = calculateGroupSizes(obj, env, AnimalEnum.Elk);
        end

    end
end

