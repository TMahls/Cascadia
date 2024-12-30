classdef AnimalScoreRule
    %ANIMALSCORERULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Animal
        PointsTable
    end
    
    methods
        function obj = AnimalScoreRule(inputArg1,inputArg2)
            %ANIMALSCORERULE Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        
    end

    methods (Abstract)
        score = calculateScore(obj,environment)          
    end
end

