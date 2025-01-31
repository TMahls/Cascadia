classdef Autoplayer < Player
    %PLAYER Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Difficulty 
        Game
    end

    methods
        function obj = Autoplayer(gameObj)
            %PLAYER Construct an instance of this class
            %   Detailed explanation goes here

            % Set up scheduled game probing
            F = parfeval(backgroundPool,probeGame,numFcnOut,X1,...,Xm);
           
        end


    end
end