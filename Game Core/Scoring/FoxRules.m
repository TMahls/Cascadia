classdef FoxRules < WildlifeScoreObjective

    properties

    end

    methods
        function obj = FoxRules()
            obj.Animal = AnimalEnum.Fox;
        end

        function groupScore = ruleAShape(obj, environment, groupCoords)
            groupScore = 0;
            for i = 1:size(groupCoords,1) % For each fox in the group
                tile = tileAtCoords(environment, groupCoords(i,:));

                neighborAnimals = getAdjacentAnimals(obj, environment, tile);

                groupScore = groupScore + nnz(neighborAnimals);
            end
        end

        function groupScore = ruleBShape(obj, environment, groupCoords)
            groupScore = 0;
            for i = 1:size(groupCoords,1) % For each fox in the group
                tile = tileAtCoords(environment, groupCoords(i,:));

                neighborAnimals = getAdjacentAnimals(obj, environment, tile);

                pairIdx = (neighborAnimals >= 2); % Number of pairs
                % Choosing to count trios/larger groups as 1 unique pair
                
                % Remove fox pairs 
                pairIdx(obj.Animal + 1) = 0;

                if any(pairIdx)
                    groupScore = groupScore + (2 * nnz(pairIdx) + 1);
                end
            end
        end

        function groupScore = ruleCShape(obj, environment, groupCoords)
            groupScore = 0;
            for i = 1:size(groupCoords,1) % For each fox in the group
                tile = tileAtCoords(environment, groupCoords(i,:));

                neighborAnimals = getAdjacentAnimals(obj, environment, tile);
                neighborAnimals(obj.Animal + 1) = 0; % Don't include foxes in count

                maxAnimals = max(neighborAnimals);
                groupScore = groupScore + maxAnimals;
            end
        end

        function groupScore = ruleDShape(obj, environment, groupCoords)
            % This one has complicated edge-cases. Luckily, it's been
            % answered by Randy! https://boardgamegeek.com/thread/2817617/fox-card-d-rule-clarification
            groupScore = 0;

        end
    end

end

