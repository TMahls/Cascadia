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
            
            allTiles = [obj.StarterHabitatTile, obj.HabitatTiles];
            coordList = []; groupSize = [];
            for i = 1:length(allTiles)
                currTile = allTiles(i);

                tileNotInList = ~ismember(currTile.Coordinate,coordList,"rows");
               
                if currTile.WildlifeToken.Animal == animal && tileNotInList
                    coordList = [coordList;
                        recursiveGetAnimalGroupCoords(env, currTile, terrain, currTile.Coordinate)];
                    groupSize = [groupSize, size(coordList,1)];
                end
            end
        end

    end
end

