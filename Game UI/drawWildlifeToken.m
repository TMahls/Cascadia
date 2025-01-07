function drawWildlifeToken(ax, centerCoords, size, wildlifeToken, id)
%DRAWHABITATTILE Summary of this function goes here
% Just use circular marker in 'plot' function.

centerX = centerCoords(1); centerY = centerCoords(2);
color = getColor(wildlifeToken.Animal);
line = plot(ax, centerX, centerY, 'o', 'MarkerSize', size,...
    'MarkerEdgeColor', ColorEnum.Black.rgbValues, 'MarkerFaceColor', color.rgbValues);
line.HitTest = 'off'; % Clicking will trigger UIAxes callback
line.UserData = id;
end