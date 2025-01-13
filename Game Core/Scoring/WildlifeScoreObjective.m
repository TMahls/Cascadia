classdef WildlifeScoreObjective
    %ANIMALSCORERULE Parent class of wildlife scoring objectives
    
    properties
        Animal
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

    methods (Access = protected) % Implemented subclass methods
        
        function groupSize = calculateGroupSizes(~, env, animal)
            % List of group sizes for a particular animal and environment
            
            allTiles = [env.StarterHabitatTile, env.HabitatTiles];
            overallCoordList = []; groupSize = [];
            for i = 1:length(allTiles)
                currTile = allTiles(i);

                if ~isempty(overallCoordList)
                    tileNotInList = ~ismember(currTile.Coordinate,overallCoordList,"rows");
                else
                    tileNotInList = true;
                end
               
                if ~isempty(currTile.WildlifeToken.Animal) && ...
                        (currTile.WildlifeToken.Animal == animal) && tileNotInList
                    groupCoordList = recursiveGetAnimalGroupCoords(env, currTile, animal, currTile.Coordinate);
                    overallCoordList = [overallCoordList; groupCoordList];
                    groupSize = [groupSize, size(groupCoordList,1)];
                end
            end
        end

    end
end

