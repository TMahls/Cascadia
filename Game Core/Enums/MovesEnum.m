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

            if ~playerObj.TokenDiscarded
                if ~playerObj.TilePlaced
                    % Stage 1
                    if MovesEnum.checkVoluntaryOverpopulationWipe(gameObj, playerObj)
                        moveList = [moveList MovesEnum.OverpopulationWipe];
                    end

                    % Stage 2
                    if MovesEnum.checkSpendNatureToken(playerObj)
                        moveList = [moveList MovesEnum.SpendNatureToken];
                    end

                    % Stage 3
                    moveList = [moveList MovesEnum.SelectTile MovesEnum.SelectToken];

                    if playerObj.SelectedTileIdx ~= 0
                        % Stage 4
                        moveList = [moveList MovesEnum.SelectToken MovesEnum.RotateTile MovesEnum.PlaceTile];
                    end
                else
                    % Stage 5
                    moveList = [MovesEnum.PlaceToken MovesEnum.DiscardToken];
                end
            end
        end

        function [gameObj, playerObj] = executeMove(gameObj, playerObj, move, moveMetadata)
            switch move
                case MovesEnum.OverpopulationWipe
                    [gameObj, playerObj] = MovesEnum.overpopulationWipe(gameObj, playerObj);
                    numAnimals = gameObj.countSameCenterAnimals();
                    if numAnimals ~= gameObj.GameParameters.CenterTiles
                        playerObj.UsedVoluntaryOverpopulationWipe = true;
                    end

                case MovesEnum.SpendNatureToken
                    [gameObj, playerObj] = MovesEnum.spendNatureToken(playerObj);

                case MovesEnum.SelectTile
                    tileCenterIdx = moveMetadata;
                    playerObj = MovesEnum.selectHabitatTile(playerObj, tileCenterIdx);

                case MovesEnum.SelectToken
                    tokenCenterIdx = moveMetadata;
                    playerObj = MovesEnum.selectWildlifeToken(playerObj, tokenCenterIdx);

                case MovesEnum.RotateTile
                    tileCenterIdx = moveMetadata;
                    tileGameIdx = gameObj.CenterTileIdx(tileCenterIdx);
                    habitatTile = gameObj.HabitatTiles(tileGameIdx);
                    habitatTile = MovesEnum.rotateHabitatTile(habitatTile);
                    gameObj.HabitatTiles(tileGameIdx) = habitatTile;

                case MovesEnum.PlaceTile
                    tileCenterIdx = moveMetadata{1};
                    tileGameIdx = gameObj.CenterTileIdx(tileCenterIdx);
                    habitatTile = gameObj.HabitatTiles(tileGameIdx);

                    coordinate = moveMetadata{2};
                    [gameObj, playerObj] = MovesEnum.placeHabitatTile(playerObj, gameObj, tileGameIdx, habitatTile, coordinate);

                case MovesEnum.PlaceToken
                    tokenCenterIdx = moveMetadata{1};
                    tokenGameIdx = gameObj.CenterTokenIdx(tokenCenterIdx);
                    wildlifeToken = gameObj.WildlifeTokens(tokenGameIdx);

                    coordinate = moveMetadata{2};
                    [gameObj, playerObj] = MovesEnum.placeWildlifeToken(gameObj, playerObj, tokenGameIdx, wildlifeToken, coordinate);

                case MovesEnum.DiscardToken
                    tokenCenterIdx = moveMetadata{1};
                    tokenGameIdx = gameObj.CenterTileIdx(tokenCenterIdx);

                    [gameObj, playerObj] = MovesEnum.discardWildlifeToken(gameObj, playerObj, tokenGameIdx);
            end
        end

        function tf = checkVoluntaryOverpopulationWipe(gameObj, playerObj)
            numAnimals = gameObj.countSameCenterAnimals();
            tf = (numAnimals == (gameObj.GameParameters.CenterTiles - 1)) && ...
                ~playerObj.UsedVoluntaryOverpopulationWipe &&...
                ~playerObj.SpentNatureToken;
        end

        function tf = checkSpendNatureToken(playerObj)
            tf = (playerObj.NatureTokens > 0);
        end

        function [gameObj, playerObj] = overpopulationWipe(gameObj, playerObj)
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

            % Reset player selections
            playerObj.SelectedTileIdx = 0;
            playerObj.SelectedTokenIdx = 0;
        end

        function [gameObj, playerObj] = spendNatureToken(gameObj, playerObj)
            % Option 1: Decouple habitat tile and wildlife token selection

            if ~playerObj.DecoupledTileToken
                playerObj.DecoupledTileToken = true;
                playerObj.NatureTokens = playerObj.NatureTokens - 1;
                tokenIdx = find(gameObj.NatureTokens == gameObj.PlayerTurn, 1);
                gameObj.NatureTokens(tokenIdx) = 0;
            else
                fprintf('Nature token already spent for this purpose!\n');
            end

            % Option 2: Wipe any wildlife tokens (player must select, do this later.)

        end

        function playerObj = selectHabitatTile(playerObj, tileCenterIdx)
            if playerObj.DecoupledTileToken
                playerObj.SelectedTileIdx = tileCenterIdx;
            else
                playerObj.SelectedTileIdx = tileCenterIdx;
                playerObj.SelectedTokenIdx = tileCenterIdx;
            end
        end

        function playerObj = selectWildlifeToken(playerObj, tokenCenterIdx)
            if playerObj.DecoupledTileToken
                playerObj.SelectedTokenIdx = tokenCenterIdx;
            else
                playerObj.SelectedTokenIdx = tokenCenterIdx;
                playerObj.SelectedTileIdx = tokenCenterIdx;
            end
        end

        function habitatTile = rotateHabitatTile(habitatTile)
            habitatTile.Orientation = habitatTile.Orientation + 1;
        end

        function [gameObj, playerObj] = placeHabitatTile(playerObj, gameObj, tileIdx, habitatTile, coordinate)
            habitatTile.Coordinate = coordinate;
            currEnv = playerObj.Environment.HabitatTiles;
            playerObj.Environment.HabitatTiles = [currEnv habitatTile];

            gameObj.HabitatTiles(tileIdx).Status = StatusEnum.Played;
        end

        function [gameObj, playerObj] = placeWildlifeToken(gameObj, playerObj, gameTokenIdx, wildlifeToken, coordinate)
            % Find Habitat Tile with that coordinate
            playerTiles = playerObj.Environment.HabitatTiles;

            i = 0; tileFound = false;
            while i <= length(playerTiles) && ~tileFound
                i = i + 1;
                if all(playerTiles(i).Coordinate == coordinate)
                    tileFound = true;
                end
            end

            % Place wildlife token on it
            playerObj.Environent.HabitatTiles(i).WildlifeToken = wildlifeToken;

            % Increment Nature Token if Keystone
            if isKeystoneTile(playerObj.Environent.HabitatTiles(i))
                takeNatureToken(playerObj, gameObj);
            end

            % Change gameObj
            gameObj.WildlifeTokens(gameTokenIdx).Status = StatusEnum.Played;
        end

        function [gameObj, playerObj] = discardWildlifeToken(gameObj, playerObj, tokenIdx)
            gameObj.WildlifeTokens(tokenIdx).Status = StatusEnum.Hidden;
            playerObj.TokenDiscarded = true;
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

