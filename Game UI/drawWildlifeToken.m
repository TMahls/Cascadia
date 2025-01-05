function drawWildlifeToken(ax, centerX, centerY, size, wildlifeToken)
%DRAWHABITATTILE Summary of this function goes here
% Just use circular marker in 'plot' function.

color = getColor(wildlifeToken.Animal);
plot(ax, centerX, centerY, 'o', 'MarkerSize', size,...
    'MarkerEdgeColor', ColorEnum.Black.rgbValues, 'MarkerFaceColor', color.rgbValues);
end