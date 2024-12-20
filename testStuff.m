% This script can be used as a sandbox for testing things out

clear;clc;
tic
obj = Game;

obj = obj.startNewGame(3);

toc

obj.CurrentScores

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

