classdef FamilyVariantRule < WildlifeScoreObjective
    
    properties
        
    end
    
    methods
        function obj = FamilyVariantRule()

        end 

        function score = calculateScore(obj, environment, animal)
            score = 0;
            groupSizes = calculateGroupSizes(obj, environment, animal);

            score = score + 2 * nnz(groupSizes == 1) + 5 * nnz(groupSizes == 2) + ...
                9 * nnz(groupSizes >= 3);
        end
    end
end

