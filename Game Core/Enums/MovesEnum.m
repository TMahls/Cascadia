classdef MovesEnum < uint8
    %MOVESENUM Summary of this class goes here
    %   Detailed explanation goes here

    enumeration
        OverpopulationWipe (0)
        SpendNatureToken (1)
        SelectTile (1)
        SelectToken (2)
        RotateTile (3)
        PlaceTile (4)
        PlaceToken (5)
        DiscardToken (6)
    end

    methods (Static)
        function moveList = checkMoveAvailability(gameObj, playerObj)
            moveList = MovesEnum.empty; 

            if MovesEnum.checkVoluntaryOverpopulationWipe(gameObj, playerObj)
                moveList = [moveList MovesEnum.OverpopulationWipe];
            end

        end

        function [gameObj, playerObj] = executeMove(gameObj, playerObj, move)
            switch move
                case MovesEnum.OverpopulationWipe
                    gameObj = MovesEnum.overpopulationWipe(gameObj);
                    playerObj.UsedVoluntaryOverpopulationWipe = true;
                otherwise

            end
        end

        function tf = checkVoluntaryOverpopulationWipe(gameObj, playerObj)
             numAnimals = gameObj.countSameCenterAnimals();
             tf = (numAnimals == (gameObj.GameParameters.CenterTiles - 1)) && ...               
             ~playerObj.UsedVoluntaryOverpopulationWipe;                
        end

        function gameObj = overpopulationWipe(gameObj)
            % Remove animal that appears for all center tiles (auto-wipe), 
            % or all but one (voluntary wipe)
            centerIdx = gameObj.CenterTokenIdx;

            % Display animals before
            fprintf('Animals before: \n')
            gameObj.WildlifeTokens(centerIdx).Animal

            % Identify animal to be removed
            animalCount = zeros(1,AnimalEnum.NumAnimals,'uint8');
            for i = 1:length(centerIdx)
                currToken = gameObj.WildlifeTokens(centerIdx(i));
                animalCount(currToken.Animal + 1) = animalCount(currToken.Animal + 1) + 1;
            end
            [n,idx] = max(animalCount);
            problemAnimal = AnimalEnum(idx - 1);

            % Find the indexes of those tokens
            animalReplaceIdx = [];
            if n < (gameObj.GameParameters.CenterTiles - 1)
                disp('Cannot do an overpopulation wipe');
            else
                for i = 1:length(centerIdx)
                    currToken = gameObj.WildlifeTokens(centerIdx(i));
                    if currToken.Animal == problemAnimal
                        animalReplaceIdx = [animalReplaceIdx centerIdx(i)];
                    end
                end
            end

            % Set tokens aside
            for i = animalReplaceIdx
                gameObj.WildlifeTokens(i).Status = StatusEnum.OutOfPlay;
                gameObj.CenterTokenIdx(gameObj.CenterTokenIdx == i) = 0;
            end

            % Draw replacement tokens
            for i = 1:length(animalReplaceIdx)
                nextCenterIdx = find(gameObj.CenterTokenIdx == 0, 1);
                randIdx = randi(length(gameObj.WildlifeTokens));
                newToken = gameObj.WildlifeTokens(randIdx);
                while newToken.Status ~= StatusEnum.Hidden
                    randIdx = randi(length(gameObj.WildlifeTokens));
                    newToken = gameObj.WildlifeTokens(randIdx);
                end
                newToken.Status = StatusEnum.InCenter;
                gameObj.WildlifeTokens(randIdx) = newToken;
                gameObj.CenterTokenIdx(nextCenterIdx) = randIdx;
            end

            % Place wiped tokens back in bag
            for i = animalReplaceIdx
                gameObj.WildlifeTokens(i).Status = StatusEnum.Hidden;
            end

            % Display animals after
            fprintf('Animals after: \n')
            gameObj.WildlifeTokens(gameObj.CenterTokenIdx).Animal
        end

        function spendNatureToken(player)

        end

        function rotateHabitatTile(player, HabitatTile)

        end

        function placeHabitatTile(player,HabitatTile)

        end

        function placeWildlifeToken(player,NatureToken)

        end

        function discardWildlifeToken(player,NatureToken)

        end
    
    end

    methods 
        % We may or may not need this
        function moveText = getText(obj)
            switch obj
                case MovesEnum.OverpopulationWipe
                    moveText = 'Overpopulation Wipe';
                otherwise
                    moveText = '';
            end
        end
    end
end

