classdef IntermediateVariantRule < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = IntermediateVariantRule()

        end 

        function score = calculateScore(obj, environment, animal)
            score = 0;
            groupSizes = calculateGroupSizes(obj, environment, animal);

            score = score + 5 * nnz(groupSizes == 2) + 8 * nnz(groupSizes == 3) + ...
                12 * nnz(groupSizes >= 4);
        end
    end
end

