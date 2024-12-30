% This script can be used as a sandbox for testing things out

clear;clc;
tic
obj = Game;


for n = 1:500
obj = obj.startNewGame(3);

toc

obj.WildlifeTokens(obj.CenterTokenIdx).Animal

obj.Players(1).AvailableActions

if ismember(obj.Players(1).AvailableActions, MovesEnum.OverpopulationWipe)
    fprintf('Performing voluntary overpop wipe\n');
    obj = playerAction(obj, MovesEnum.OverpopulationWipe);
    
    
    obj.WildlifeTokens(obj.CenterTokenIdx).Animal

    if obj.countSameCenterAnimals() >= 3
       fprintf('Here! n = %d\n', n)
    end
    
    obj.CurrentScores;
end
end


% Try out moves


% See starter Tiles
% for nStarterTile = 1:5
%     for tileNum = 1:3
%         obj.StarterHabitatTiles(nStarterTile, tileNum)
%     end
% end
% 
% % See habitat tiles
% for nHabitatTile = 1:length(obj.HabitatTiles)
%     obj.HabitatTiles(nHabitatTile)
% end

