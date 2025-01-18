classdef GroupShape
    %GROUPSHAPE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Coordinates int8
        Score (1,1) int8
    end

    methods
        function obj = GroupShape(coords, score)
            %GROUPSHAPE Construct an instance of this class
            %   Detailed explanation goes here
            obj.Coordinates = coords;
            obj.Score = score;
        end

        function obj = rotateShape(obj, n)
            % Rotates shape about the first point clockwise by 60 degrees * n

            centerOfRotation = obj.Coordinates(1,:);
            newCoords = obj.Coordinates - centerOfRotation; % Normalized

            signFlip = mod(n,2); % Flip sign if 1, don't if 0
            shiftAmount = mod(n,3); % Positive = clockwise

            obj.Coordinates = circshift(newCoords, shiftAmount, 2) * (-2*signFlip + 1) + ...
                centerOfRotation;
        end

    end
end