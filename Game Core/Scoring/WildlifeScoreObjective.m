classdef WildlifeScoreObjective
    %ANIMALSCORERULE Parent class of wildlife scoring objectives
    
    properties
        Animal
        PointsTable
    end
    
    methods
        function obj = WildlifeScoreObjective(inputArg1,inputArg2)
            %ANIMALSCORERULE Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        
    end

    methods (Abstract)
        score = calculateScore(obj,environment)          
    end
end

