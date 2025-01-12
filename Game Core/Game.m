classdef Game
    %GAME Summary of this class goes here
    %   Detailed explanation goes here

    properties
        GameParameters GameParameters % Constant properties for all games
        Players Player % Array of Player
        StarterHabitatTiles HabitatTile % Array of 'StartHabitatTiles', which is an array of 3 tiles...
        HabitatTiles HabitatTile % Array of HabitatTile
        WildlifeTokens WildlifeToken % Array of WildlifeToken
        NatureTokens uint8 % Array of size NumWildlifeTokens, value is which player owns it (0 default)        

        CenterTileIdx uint8 % Idx in 'HabitatTiles' of center tiles (in center order)
        CenterTokenIdx uint8 % Idx in 'NatureTokens' of center tiles (in center order)
        % 0 indicates empty center

        TurnCount uint8 % How many turns has the game gone?
        PlayerTurn uint8 % Whose turn is it?
        StatusMsg char % Current game status

        GameComplete (1,1) logical % True when game is over
        CurrentScores table % Scores for current turn
        ScoringRules uint8 % Which scoring rule we're using
        HabitatBonus (1,1) logical % Whether we assign largest habitat bonuses
    end

    methods
        function obj = Game()
            %GAME Construct an instance of this class
            %   Detailed explanation goes here

            % Get parameter data store
            obj.GameParameters = GameParameters();

            % Populate Starter Habitat Tiles
            obj.StarterHabitatTiles = initStarterTiles(obj.GameParameters);
        
            obj.GameComplete = true; 
        end

        function obj = startNewGame(obj, nPlayers, options)
            %STARTNEWGAME Summary of this method goes here
            %  vararg in - game mode (default easy), custom scoring rules

            arguments 
                obj Game
                nPlayers (1,1) double
                options.GameMode = GameModeEnum.EasyRules
                options.CustomRules string = ""
                options.PlayerNames string = ""
                options.HabitatBonus (1,1) logical = true
            end

            % Set scoring rules
            obj.ScoringRules = obj.GameParameters.initScoringRules(...
                options.GameMode, options.CustomRules);
            obj.HabitatBonus = options.HabitatBonus;
            
            % Reset players and tokens
            obj = clearPlayersAndTokens(obj);

            % Select subset of all habitat tiles to make 'Hidden'
            numInPlayTiles = obj.GameParameters.habitatTilesForNPlayers(nPlayers);
            idx = randperm(obj.GameParameters.calculateTotalHabitatTiles, numInPlayTiles);
            for i = idx
                obj.HabitatTiles(i).Status = StatusEnum.Hidden;
            end

            % Give player a random starting tile
            idx = randperm(obj.GameParameters.StarterTiles, nPlayers);
            for i = 1:nPlayers
                obj.Players(i) = Player();

                % Set player name (only default for now)
                obj.Players(i).Name = ['Player ' num2str(i)];

                % Set starter tile status as 'Played'
                for j = 1:length(obj.StarterHabitatTiles(idx(i),:))
                    obj.StarterHabitatTiles(idx(i),j).Status = StatusEnum.Played;
                end

                obj.Players(i).Environment.StarterHabitatTile = obj.StarterHabitatTiles(idx(i),:);
            end

            % Center Habitat Tiles and Wildlife tokens
            idx = sort(randperm(numInPlayTiles, obj.GameParameters.CenterTiles));
            inPlayCount = 0; centerIdx = 1;
            for i = 1:length(obj.HabitatTiles)
                if (obj.HabitatTiles(i).Status == StatusEnum.Hidden)
                    inPlayCount = inPlayCount + 1;
                    if any(inPlayCount == idx)
                        obj.HabitatTiles(i).Status = StatusEnum.InCenter;
                        obj.CenterTileIdx(centerIdx) = i;
                        centerIdx = centerIdx + 1;
                    end
                end
            end

            idx = randperm(length(obj.WildlifeTokens), obj.GameParameters.CenterTiles);
            centerIdx = 1;
            for i = idx
                obj.WildlifeTokens(i).Status = StatusEnum.InCenter;
                obj.CenterTokenIdx(centerIdx) = i;
                centerIdx = centerIdx + 1;
            end

            % Start game
            obj.GameComplete = false;
            obj.TurnCount = 1;
            obj.PlayerTurn = 1;
            obj.CurrentScores = obj.GameParameters.initScoreTable(obj.Players);
            obj.StatusMsg = 'Game started!';

            [obj, obj.Players(obj.PlayerTurn)] = ...
                obj.Players(obj.PlayerTurn).getAvailableActions(obj);
        end

        function obj = playerAction(obj, action, moveMetadata)
            %PLAYERACTION Summary of this method goes here
            % Callback triggered by a player selecting a move
            currPlayer = obj.Players(obj.PlayerTurn);

            if ismember(action, currPlayer.AvailableActions)
                originalPlayerIdx = obj.PlayerTurn;

                % Execute selected move
                obj.StatusMsg = [];
                [obj, currPlayer] = MovesEnum.executeMove(obj, currPlayer, action, moveMetadata);

                % Check if player can continue turn, or if game is over
                [obj, currPlayer] = currPlayer.getAvailableActions(obj);

                turnOver = isempty(currPlayer.AvailableActions);

                if turnOver
                    % Reset once-per-turn actions
                    currPlayer = resetTurnFlags(currPlayer);

                    % Update player's score
                    % We do this every turn for the purposes of the AI.
                    % It'll want to know ;)
                    obj.Players(originalPlayerIdx) = currPlayer;
                    obj.CurrentScores = calculateAllScores(obj);

                    % Game is over if there are no hidden tiles left, or in
                    % solo game if there is only 1 hidden tile left. 
                    gameOver = (countTiles(obj, StatusEnum.Hidden) == 0) ||...
                        (countTiles(obj, StatusEnum.Hidden) == 1 && isscalar(obj.Players));

                    if gameOver
                        obj = endGame(obj);                       
                    elseif turnOver
                        % Replace Center
                        if length(obj.Players) ~= 1
                            obj = replaceCenterNormal(obj);
                            turnsRemaining = countTiles(obj, StatusEnum.Hidden) + 1;
                        else
                            obj = replaceCenterSolo(obj);
                            turnsRemaining = (countTiles(obj, StatusEnum.Hidden) + 1)/2;
                        end                       

                        % Prepare for next player's turn
                        obj.TurnCount = obj.TurnCount + 1;
                        obj.PlayerTurn = mod(obj.PlayerTurn, length(obj.Players)) + 1;
                        obj.StatusMsg = sprintf('Player %d''s Turn. %d Turns Remaining', obj.PlayerTurn, ...
                            turnsRemaining);
                        [obj, obj.Players(obj.PlayerTurn)] = ...
                            obj.Players(obj.PlayerTurn).getAvailableActions(obj);
                    end
                else
                    if isempty(obj.StatusMsg)
                        obj.StatusMsg = sprintf('Player %d Continues Turn', obj.PlayerTurn);
                    end
                end
                % Most of the time update old player, except at end of turn
                % in solo game.
                if ~turnOver || originalPlayerIdx ~= obj.PlayerTurn
                    obj.Players(originalPlayerIdx) = currPlayer;
                end
            else
                obj.StatusMsg = 'Action not available to player!';
            end
        end

        function obj = endGame(obj)
             obj.GameComplete = true;
             obj.StatusMsg = 'Game over!';
        end

        function nAnimals = countSameCenterAnimals(obj)
            % Count number of 'same animals' in the center. For overpopulation
            % purposes

            % Create array of center token animals
            tokenIndexes = obj.CenterTokenIdx;
            centerTokenAnimals = AnimalEnum.empty;
            idx = 1;
            for i = tokenIndexes
                if i ~= 0 % We could have a partially empty center when we check this
                    centerTokenAnimals(idx) = obj.WildlifeTokens(i).Animal;
                    idx = idx + 1;
                end
            end

            % Count largest number of repeated animals
            nAnimals = 1;
            for i = 1:length(centerTokenAnimals)
                currAnimal = centerTokenAnimals(i);
                animalCount = 1;
                for j = (i+1):length(centerTokenAnimals)
                    if centerTokenAnimals(j) == currAnimal
                        animalCount = animalCount + 1;
                    end
                end
                if animalCount > nAnimals
                    nAnimals = animalCount;
                end
            end
        end

        function nTiles = countTiles(obj, status)
            %COUNTTILES How many tiles of a particular status exist
            %   Detailed explanation goes here
            nTiles = 0;
            for i = 1:length(obj.HabitatTiles)
                if obj.HabitatTiles(i).Status == status
                    nTiles = nTiles + 1;
                end
            end
        end

        function nTokens = countTokens(obj, status)
            %COUNTTOKENS How many tokens of a particular status exist
            %   Detailed explanation goes here
            nTokens = 0;
            for i = 1:length(obj.WildlifeTokens)
                if obj.WildlifeTokens(i).Status == status
                    nTokens = nTokens + 1;
                end
            end
        end
    end

    methods (Access = private)
        function obj = clearPlayersAndTokens(obj)
            % Populate empty player
            obj.Players = Player.empty;

            % Populate Habitat Tiles
            obj.HabitatTiles = initHabitatTiles(obj.GameParameters);

            % Populate Wildlife Tokens
            obj.WildlifeTokens = initWildlifeTokens(obj.GameParameters);

            % Populate Nature Tokens
            obj.NatureTokens = initNatureTokens(obj.GameParameters);
        end

        function obj = replaceCenterNormal(obj)
            % Procedure for replacing center tile/token after turn

            % 1 - Pick random hidden tile
            tileIdx = randi(length(obj.HabitatTiles));
            randTile = obj.HabitatTiles(tileIdx);
            while (randTile.Status ~= StatusEnum.Hidden)
                tileIdx = randi(length(obj.HabitatTiles));
                randTile = obj.HabitatTiles(tileIdx);
            end

            % 2 - Pick random hidden token
            tokenIdx = randi(length(obj.WildlifeTokens));
            randToken = obj.WildlifeTokens(tokenIdx);
            while (randToken.Status ~= StatusEnum.Hidden)
                tokenIdx = randi(length(obj.WildlifeTokens));
                randToken = obj.WildlifeTokens(tokenIdx);
            end

            % 3 - Fill empty tile/token slots with them
            obj.HabitatTiles(tileIdx).Status = StatusEnum.InCenter;
            obj.WildlifeTokens(tokenIdx).Status = StatusEnum.InCenter;

            obj.CenterTileIdx(obj.CenterTileIdx == 0) = tileIdx;
            obj.CenterTokenIdx(obj.CenterTokenIdx == 0) = tokenIdx;
        end

        function obj = replaceCenterSolo(obj)
            % Procedure for replacing center in solo mode -- the furthest
            % right tile and token are removed, and all tiles and tokens
            % are slid to the right. 

            % Remove furthest right tile / token
            furthestTile = find(obj.CenterTileIdx, 1, 'last');
            furthestToken = find(obj.CenterTokenIdx, 1, 'last');

            furthestTileIdx = obj.CenterTileIdx(furthestTile);
            furthestTokenIdx = obj.CenterTokenIdx(furthestToken);

            obj.HabitatTiles(furthestTileIdx).Status = StatusEnum.OutOfPlay;
            obj.WildlifeTokens(furthestTokenIdx).Status = StatusEnum.OutOfPlay;

            obj.CenterTileIdx(furthestTile) = 0;
            obj.CenterTokenIdx(furthestToken) = 0;

            % Slide tiles and tokens over
            furthestTile = find(obj.CenterTileIdx, 1, 'last');        
            if furthestTile ~= length(obj.CenterTileIdx)
                obj.CenterTileIdx(end) = obj.CenterTileIdx(furthestTile);
                obj.CenterTileIdx(furthestTile) = 0;
            end

            furthestTile = find(obj.CenterTileIdx(1:end-1), 1, 'last');
            if furthestTile ~= (length(obj.CenterTileIdx) - 1)
                obj.CenterTileIdx(end-1) = obj.CenterTileIdx(furthestTile);
                obj.CenterTileIdx(furthestTile) = 0;
            end

            furthestToken = find(obj.CenterTokenIdx, 1, 'last');        
            if furthestToken ~= length(obj.CenterTokenIdx)
                obj.CenterTokenIdx(end) = obj.CenterTokenIdx(furthestToken);
                obj.CenterTokenIdx(furthestToken) = 0;
            end

            furthestToken = find(obj.CenterTokenIdx(1:end-1), 1, 'last');
            if furthestToken ~= (length(obj.CenterTokenIdx) - 1)
                obj.CenterTokenIdx(end-1) = obj.CenterTokenIdx(furthestToken);
                obj.CenterTokenIdx(furthestToken) = 0;
            end

            % Draw new tiles / tokens
            while any(find(~obj.CenterTileIdx))
                tileIdx = randi(length(obj.HabitatTiles));
                randTile = obj.HabitatTiles(tileIdx);
                while (randTile.Status ~= StatusEnum.Hidden)
                    tileIdx = randi(length(obj.HabitatTiles));
                    randTile = obj.HabitatTiles(tileIdx);
                end

                obj.HabitatTiles(tileIdx).Status = StatusEnum.InCenter;
                obj.CenterTileIdx(find(~obj.CenterTileIdx,1)) = tileIdx;
            end

            while any(find(~obj.CenterTokenIdx))
                tokenIdx = randi(length(obj.WildlifeTokens));
                randToken = obj.WildlifeTokens(tokenIdx);
                while (randToken.Status ~= StatusEnum.Hidden)
                    tokenIdx = randi(length(obj.WildlifeTokens));
                    randToken = obj.WildlifeTokens(tokenIdx);
                end

                obj.WildlifeTokens(tokenIdx).Status = StatusEnum.InCenter;
                obj.CenterTokenIdx(find(~obj.CenterTokenIdx,1)) = tokenIdx;
            end
        end
    end
end