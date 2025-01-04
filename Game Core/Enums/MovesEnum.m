classdef MovesEnum < uint8
    %MOVESENUM Summary of this class goes here
    %   Detailed explanation goes here
    % Order:
    % 1. Overpop Wipe / Select Tile / Select Token / Spend nature token
    % After overpop wipe or first spend nature token
    % 2. Spend nature token / Select Tile / Select Token
    % After all nature tokens spent
    % 3. Select Tile / Select Token
    % After tile and token selected
    % 4. Rotate Tile / Place Tile
    % After place tile
    % 5. Place Token / Discard Token
    % Overpop wipe -> Spend nature token -> Select tile / token -> Rotate /
    % place tile -> Place / discard token

    enumeration
        OverpopulationWipe (0)
        SpendNatureToken (1)
        SelectTile (2)
        SelectToken (3)
        RotateTile (4)
        PlaceTile (5)
        PlaceToken (6)
        DiscardToken (7)
    end

    methods (Static)
        function moveList = checkMoveAvailability(gameObj, playerObj)
            moveList = MovesEnum.empty;

            if ~playerObj.TilePlaced
                if playerObj.SelectedTileIdx == 0 || playerObj.SelectedTokenIdx == 0
                    % Stage 1
                    if MovesEnum.checkVoluntaryOverpopulationWipe(gameObj, playerObj)
                        moveList = [moveList MovesEnum.OverpopulationWipe];
                    end

                    % Stage 2
                    if MovesEnum.checkSpendNatureToken(gameObj, playerObj)
                        moveList = [moveList MovesEnum.SpendNatureToken];
                    end

                    % Stage 3
                    if playerObj.SelectedTileIdx == 0
                        moveList = [moveList MovesEnum.SelectTile];
                    end

                    if playerObj.SelectedTokenIdx == 0
                        moveList = [moveList MovesEnum.SelectToken];
                    end
                else
                    % Stage 4
                    moveList = [moveList MovesEnum.RotateTile MovesEnum.PlaceTile];
                end
            else
                % Stage 5
                moveList = [MovesEnum.PlaceToken MovesEnum.DiscardToken];
            end
        end

        function [gameObj, playerObj] = executeMove(gameObj, playerObj, move)
            switch move
                case MovesEnum.OverpopulationWipe
                    gameObj = MovesEnum.overpopulationWipe(gameObj);
                    playerObj.UsedVoluntaryOverpopulationWipe = true;
                case MovesEnum.SpendNatureToken

                case MovesEnum.SelectTile

                case MovesEnum.SelectToken

                case MovesEnum.RotateTile

                case MovesEnum.PlaceTile

                case MovesEnum.PlaceToken

                case MovesEnum.DiscardToken

            end
        end

        function tf = checkVoluntaryOverpopulationWipe(gameObj, playerObj)
             numAnimals = gameObj.countSameCenterAnimals();
             tf = (numAnimals == (gameObj.GameParameters.CenterTiles - 1)) && ...               
             ~playerObj.UsedVoluntaryOverpopulationWipe &&...
             ~playerObj.SpentNatureToken;                
        end

        function tf = checkSpendNatureToken(gameObj, playerObj)
            tf = (playerObj.NatureTokens > 0);              
        end



        function gameObj = overpopulationWipe(gameObj)
            % Remove animal that appears for all center tiles (auto-wipe), 
            % or all but one (voluntary wipe)
            centerIdx = gameObj.CenterTokenIdx;
       
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

