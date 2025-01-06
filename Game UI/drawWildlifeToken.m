function drawWildlifeToken(ax, centerX, centerY, size, wildlifeToken, id)
%DRAWHABITATTILE Summary of this function goes here
% Just use circular marker in 'plot' function.

color = getColor(wildlifeToken.Animal);
line = plot(ax, centerX, centerY, 'o', 'MarkerSize', size,...
    'MarkerEdgeColor', ColorEnum.Black.rgbValues, 'MarkerFaceColor', color.rgbValues);
line.HitTest = 'off'; % Clicking will trigger UIAxes callback
line.UserData = id;
end