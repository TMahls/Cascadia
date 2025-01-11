classdef WildlifeScoreObjective
    %ANIMALSCORERULE Parent class of wildlife scoring objectives
    
    properties
        Animal
        PointsTable
    end
    
    methods
        function obj = WildlifeScoreObjective()
            %ANIMALSCORERULE Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        
    end

    methods (Abstract)
        score = calculateScore(obj,environment)          
    end
end

