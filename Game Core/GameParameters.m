classdef GameParameters
    %GAMEPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here

    properties(Constant)
        NatureTokens = 25;
        WildlifeTokensPerAnimal = 20;
        KeystoneTilesPerTerrain = 5;
        DualTerrainTilesPerCombo = 6; % Number of each terrain combo
        CenterTiles = 4; % How many tiles (and tokens) in the center
        StarterTiles = 5;

        % What terrains each animal appears on (in row order of AnimalEnum)
        % Format - Major (2 keystone), Major (2 keystone), Minor (1 keystone + starter)
        AnimalTerrains = [TerrainEnum.Forest, TerrainEnum.River, TerrainEnum.Mountain;...
            TerrainEnum.Prairie, TerrainEnum.Mountain, TerrainEnum.Forest;...
            TerrainEnum.Prairie, TerrainEnum.Wetland, TerrainEnum.River;...
            TerrainEnum.River, TerrainEnum.Mountain, TerrainEnum.Wetland;...
            TerrainEnum.Wetland, TerrainEnum.Forest, TerrainEnum.Prairie];

        % What animals appear on each terrain (in row order of TerrainEnum)
        % Format - Major (2 keystone), Major (2 keystone), Minor (1 keystone + starter)
        TerrainAnimals = [AnimalEnum.Bear, AnimalEnum.Hawk, AnimalEnum.Salmon;...
            AnimalEnum.Salmon, AnimalEnum.Fox, AnimalEnum.Hawk;...
            AnimalEnum.Bear, AnimalEnum.Fox, AnimalEnum.Elk;...
            AnimalEnum.Elk, AnimalEnum.Hawk, AnimalEnum.Bear;...
            AnimalEnum.Elk, AnimalEnum.Salmon, AnimalEnum.Fox];

        % Dual Terrain Tiles have no discernable (to me) pattern to their
        % compatible wildlife allocation. So, I've manually entered them in a spreadsheet.
        DualTerrainSpreadsheet = 'DualTerrainTileWildlife.xlsx';

        % Starter Tile configuration (in row order of TerrainEnum for top Keystone)
        % Column order: Lower-left tile, lower-right tile
        % Technically with just the lower-left and top tile info you can
        % fill in the rest, but with rule changes or terrain additions that
        % may not hold. So I will make it explicit.
        % Tile orientation for starter tiles is [N/A, 2, 6]. See
        % Orientation convention picture
        StarterTerrain = {[TerrainEnum.Prairie, TerrainEnum.Forest], [TerrainEnum.Wetland, TerrainEnum.Mountain];...
            [TerrainEnum.River, TerrainEnum.Forest], [TerrainEnum.Mountain, TerrainEnum.Prairie];...
            [TerrainEnum.Mountain, TerrainEnum.River], [TerrainEnum.Prairie, TerrainEnum.Wetland];...
            [TerrainEnum.Forest, TerrainEnum.Wetland], [TerrainEnum.Prairie, TerrainEnum.River];...
            [TerrainEnum.Wetland, TerrainEnum.River], [TerrainEnum.Mountain, TerrainEnum.Forest]};

        StarterWildlife = {[AnimalEnum.Salmon, AnimalEnum.Elk, AnimalEnum.Bear], [AnimalEnum.Fox, AnimalEnum.Hawk];...
            [AnimalEnum.Salmon, AnimalEnum.Elk, AnimalEnum.Hawk], [AnimalEnum.Bear, AnimalEnum.Fox];...
            [AnimalEnum.Hawk, AnimalEnum.Bear, AnimalEnum.Elk], [AnimalEnum.Fox, AnimalEnum.Salmon];...
            [AnimalEnum.Hawk, AnimalEnum.Elk, AnimalEnum.Fox], [AnimalEnum.Salmon, AnimalEnum.Bear];...
            [AnimalEnum.Salmon, AnimalEnum.Fox, AnimalEnum.Hawk], [AnimalEnum.Bear, AnimalEnum.Elk]};

        % Score info
        PointsPerNatureToken = 1;
    end

    methods
        function obj = GameParameters()
            %GAMEPARAMETERS Construct an instance of this class
            %   Detailed explanation goes here
        end

        function numTiles = habitatTilesForNPlayers(~, nPlayer)
            numTiles = nPlayer * 20 + 3;
        end

        function numTiles = calculateTotalHabitatTiles(obj)
            numTiles = obj.KeystoneTilesPerTerrain * TerrainEnum.NumTerrains + ...
                obj.DualTerrainTilesPerCombo * 0.5 * double(TerrainEnum.NumTerrains * (TerrainEnum.NumTerrains - 1));
        end

        function starterTiles = initStarterTiles(obj)
            starterTiles = HabitatTile.empty;
            for i = 1:uint8(TerrainEnum.NumTerrains)
                % Keystone tile
                starterTiles(i,1) = HabitatTile();
                starterTiles(i,1).Terrain = TerrainEnum(i - 1);
                idx = find(obj.AnimalTerrains(:,end) == TerrainEnum(i - 1));
                starterTiles(i,1).CompatibleWildlife = AnimalEnum(idx - 1);
                starterTiles(i,1).Coordinate = [0,0,0];
                starterTiles(i,1).Status = StatusEnum.OutOfPlay;

                % Other 2
                starterTiles(i,2) = HabitatTile();
                starterTiles(i,2).Terrain = obj.StarterTerrain{i, 1};
                starterTiles(i,2).CompatibleWildlife = obj.StarterWildlife{i, 1};
                starterTiles(i,2).Status = StatusEnum.OutOfPlay;
                starterTiles(i,2).Coordinate = [0,-1,1];
                starterTiles(i,2).Orientation = 2;

                starterTiles(i,3) = HabitatTile();
                starterTiles(i,3).Terrain = obj.StarterTerrain{i, 2};
                starterTiles(i,3).CompatibleWildlife = obj.StarterWildlife{i, 2};
                starterTiles(i,3).Status = StatusEnum.OutOfPlay;
                starterTiles(i,3).Coordinate = [1,-1,0];
                starterTiles(i,3).Orientation = 6;
            end
        end

        function habitatTiles = initHabitatTiles(obj)
            habitatTiles = HabitatTile.empty;
            idx = 1;

            % Keystone tiles
            for i = 1:uint8(TerrainEnum.NumTerrains)
                for n = 1:obj.KeystoneTilesPerTerrain
                    habitatTiles(idx) = HabitatTile();
                    habitatTiles(idx).Terrain = TerrainEnum(i - 1);
                    if n < 3 % Major 1
                        keystoneAnimal = obj.TerrainAnimals(i,1);
                    elseif n < 5 % Major 2
                        keystoneAnimal = obj.TerrainAnimals(i,2);
                    else % Minor
                        keystoneAnimal = obj.TerrainAnimals(i,3);
                    end
                    habitatTiles(idx).CompatibleWildlife = keystoneAnimal;
                    habitatTiles(idx).Status = StatusEnum.OutOfPlay;
                    idx = idx + 1;
                end
            end

            % Dual-terrain tiles
            i = 1:uint8(TerrainEnum.NumTerrains);
            j = 1:uint8(TerrainEnum.NumTerrains);
            [I,J] = meshgrid(i,j);
            ItriU = triu(I); % Way of building unique combo index matrix

            dualTerrainTable = readDualTerrainSpreadsheet(obj);

            for i = 1:uint8(TerrainEnum.NumTerrains)
                for j = 1:uint8(TerrainEnum.NumTerrains)
                    if i ~= j && ItriU(i,j) ~= 0
                        terrain1 = TerrainEnum(I(i,j) - 1);
                        terrain2 = TerrainEnum(J(i,j) - 1);

                        % Find applicable column in table
                        compatibleWildlifeArr = ...
                            createWildlifeArr(obj, dualTerrainTable, terrain1, terrain2);

                        for n = 1:obj.DualTerrainTilesPerCombo
                            habitatTiles(idx) = HabitatTile();
                            habitatTiles(idx).Terrain = [terrain1, terrain2];                          
                            habitatTiles(idx).CompatibleWildlife = compatibleWildlifeArr{n,:};
                            habitatTiles(idx).Status = StatusEnum.OutOfPlay;
                            idx = idx + 1;
                        end
                    end
                end
            end
        end

        function wildlifeTokens = initWildlifeTokens(obj)
            wildlifeTokens = WildlifeToken.empty;
            idx = 1;
            for i = 1:uint8(AnimalEnum.NumAnimals)
                for n = 1:obj.WildlifeTokensPerAnimal
                    wildlifeTokens(idx) = WildlifeToken();
                    wildlifeTokens(idx).Animal = AnimalEnum(i - 1);
                    wildlifeTokens(idx).Status = StatusEnum.Hidden;
                    idx = idx + 1;
                end
            end
        end

        function natureTokens = initNatureTokens(obj)
            natureTokens = zeros(1,obj.NatureTokens,'uint8');
        end

        function scoreTable = initScoreTable(~, players)
            % Like the score sheet in the real game -- Columns are the
            % player names, rows are the score types. Not including 'Total'

            nPlayers = length(players);

            nRows = AnimalEnum.NumAnimals + 1 + 2 * TerrainEnum.NumTerrains + 3;
            sz = [nRows, nPlayers];

            varTypes = repmat({'uint8'}, 1, nPlayers);

            playerNames = cell(1, nPlayers);
            for i = 1:nPlayers
                playerNames{i} = players(i).Name;
            end

            scoreTypes = cell(nRows, 1);
            for i = 1:uint8(AnimalEnum.NumAnimals)
                scoreTypes{i} = [char(AnimalEnum(i - 1)) ' Score'];
            end
            
            scoreTypes{i + 1} = 'Wildlife Total';
            idx = i + 2;
            for i = 1:uint8(TerrainEnum.NumTerrains)
                scoreTypes{idx} = ['Connected ' char(TerrainEnum(i - 1)) 's'];
                scoreTypes{idx + 1} = [char(TerrainEnum(i - 1)) ' Bonus']; 
                idx = idx + 2;
            end
            scoreTypes{idx} = 'Habitat Total';
            scoreTypes{idx + 1} = 'Nature Tokens';
            scoreTypes{idx + 2} = 'Grand Total';

            scoreTable = table('Size',sz,'VariableTypes',varTypes,...
                'VariableNames',playerNames,'RowNames',scoreTypes);
        end
    end

    methods (Access = private)
        function dualTerrainTable = readDualTerrainSpreadsheet(obj)
            % Make this variable in case number of terrains changes
            numVars = 0.5 * double(TerrainEnum.NumTerrains * (TerrainEnum.NumTerrains - 1));

            % Set up the Import Options and import the data
            opts = spreadsheetImportOptions("NumVariables", numVars);

            % Specify sheet and range
            opts.VariableNamesRange = "B1:K1";
            opts.DataRange = "B2:K7";

            % Specify variable properties
            opts = setvaropts(opts, "WhitespaceRule", "preserve");
            opts = setvaropts(opts, "EmptyFieldRule", "auto");

            % Import the data
            dualTerrainTable = readtable(obj.DualTerrainSpreadsheet, opts, "UseExcel", false);
        end

        function compatibleWildlifeArr = ...
                createWildlifeArr(~, dualTerrainTable, terrain1, terrain2)

            i = 1; colIdx = 0; 
            % Made this efficient for no reason
            while i <= length(dualTerrainTable.Properties.VariableNames) && colIdx == 0
                currentColumn = dualTerrainTable.Properties.VariableNames{i};
                delimIdx = find(currentColumn == '_');
                currentT1 = currentColumn(1:(delimIdx-1));
                currentT2 = currentColumn((delimIdx+1):end);
                if strcmp(currentT1,terrain1) && strcmp(currentT2,terrain2) || ...
                       strcmp(currentT2,terrain1) && strcmp(currentT1,terrain2) 
                    colIdx = i;
                end
                i = i + 1;
            end

            compatibleWildlifeArr = dualTerrainTable{:,colIdx};

            % Replace letters with animal
            for i = 1:length(compatibleWildlifeArr)
                currentChars = compatibleWildlifeArr{i};
                animalArr = AnimalEnum.empty;
                for j = 1:length(currentChars)
                    animalArr(j) = AnimalEnum.initial2Animal(currentChars(j));
                end
                compatibleWildlifeArr(i) = {animalArr};
            end
        end
    end
end