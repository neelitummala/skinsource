function projectedData = projectaxes(data, projectionType, projectionAxes)
%
% PROJECTAXES  projects skin vibrations from 3 axes to 1 axis.
%
%   USAGE
%       projectedData = PROJECTAXES(data, projectionType, projectionAxes)
%
%   INPUT PARAMETERS
%       data - Skin vibrations with 3 axes. Dimensions should be
%           (nTimesteps, nOutputLocations, nAxes).
%       projectionType - Type of projection to perform. 
%           'mag' - Magnitude of components.
%           'pca' - Principal component analysis.
%           'rms' - Project onto axis with the most energy.
%           'soc' - Sum of components.
%       projectionAxes - Axes to project onto. Must be 'x', 'y', 'z', 'xy', 
%           'xz', 'yz', or 'xyz'. 
%
%   OUTPUT PARAMETERS
%       projectedData - Skin vibrations projected onto 1 axis.
%

    nAxes = size(data, 3);
    
    if nAxes < 3
        error('Function expects 3-axis signal')
    end
    
    x = data(:, :, 1);
    y = data(:, :, 2);
    z = data(:, :, 3);
    
    if strcmp('none', projectionType) && strcmp('none', projectionAxes)
        projectedData = data;
    elseif strcmp('xyz', projectionAxes)
        projectedData = project3d(x, y, z, projectionType);
    elseif strcmp('xy', projectionAxes)
        projectedData = project2d(x, y, projectionType);
    elseif strcmp('xz', projectionAxes)
        projectedData = project2d(x, z, projectionType);
    elseif strcmp('yz', projectionAxes)
        projectedData = project2d(y, z, projectionType);
    elseif strcmp('x', projectionAxes)
        projectedData = x;
    elseif strcmp('y', projectionAxes)
        projectedData = y;
    elseif strcmp('z', projectionAxes)
        projectedData = z;
    else
        error('Axis not supported.');
    end


end



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}