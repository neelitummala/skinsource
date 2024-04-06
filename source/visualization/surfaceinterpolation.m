function interpolatedData = surfaceinterpolation(data, ...
    originalPoints, interpolationX, interpolationY, boundaryPoints, ...
    adjacencyMatrix, surfaceMask, interpolationType)
%
% SURFACEINTERPOLATION  Interpolates data taken at measurement locations to
%   any point within the 2D hand surface.
%
%   USAGE
%       interpolatedData = SURFACEINTERPOLATION(data, measurementPoints,
%           interpolationX, interpolationY, boundaryPoints,
%           adjacencyMatrix, surfaceMask)
%       interpolatedData = SURFACEINTERPOLATION(data, measurementPoints,
%           interpolationX, interpolationY, boundaryPoints,
%           adjacencyMatrix, surfaceMask, interpolationType)
%
%   INPUT PARAMETERS
%       data - 2D matrix of data to interpolate. Dim 1 is time, dim 2 is 
%           measurement location. 
%       originalPoints - 2D matrix of original locations on the 2D hand 
%           surface. Each row is an original point (x and y coordinates).
%       interpolationX - 2D matrix of x grid coordinates of points on the 
%           2D hand surface to interpolate data to. Each row is a copy of 
%           the x coordinates.
%       interpolationY - 2D matrix of y grid coordinates of points on the 
%           2D hand surface to interpolate data to. Each column is a copy 
%           of the y coordinates.
%       boundaryPoints - 2D matrix of locations of pixels on the boundary 
%           of the 2D hand surface. Each row is a boundary pixel location 
%           (x and y coordinates).
%       adjacencyMatrix - 2D matrix that contains distances between 
%           boundary points on the 2D hand surface and each measurement 
%           location. NaN values mark where the edge between the boundary 
%           location and measurement location has a segment that is outside 
%           the 2D hand surface.
%       surfaceMask - 2D logical matrix that contains 1s for interpolation 
%           coordinates that are inside the 2D hand surface and zeros 
%           otherwise. 
%       interpolationType - String specifying the type of interpolation to 
%           perform. Options are the same as for MATLAB griddata: "linear", 
%           "nearest", "natural", "cubic", and "v4". (Optional, default is 
%           "natural".)
%
%   OUTPUT PARAMETERS
%       interpolatedData - 3D matrix of interpolated values. Dim 1 is time. 
%           Dims 2 and 3 are values on the 2D surface at each timestep.
%

    if nargin < 8
        interpolationType = 'natural';
    end

    % Data should be a column vector
    if isrow(data)
        data = data';
    end    

    % Pick the alpha accs with the minimum distance from each boundary
    % point
    alpha = 2;
    [minDists, minLocs] = mink(adjacencyMatrix, alpha, 2);

    % Make a weight matrix for extrapolation
    % Replace weights at the closest measurement locations with their 
    % distance from the boundary point
    weights = nan(size(adjacencyMatrix));
    for ii=1:alpha
        indices = sub2ind(size(weights), 1:length(minLocs(:, ii)), ...
            minLocs(:, ii)');
        weights(indices) = minDists(:, ii);
    end

    % Create the weight matrix by splitting the weights proportionally by
    % distance.
    weights = 1 - weights./sum(weights, 2, 'omitnan');   
    weights(isnan(weights)) = 0;

    % Replace any NaNs in data with zeros
    data(isnan(data)) = 0;

    % Pad extrapolated values onto the data
    extrapolatedData = weights*data;
    allData = [data; extrapolatedData]; % one big column vector
    allMeasurementPoints = [originalPoints; boundaryPoints];

    % Remove NaN measurement points
    nanLocations = logical(sum(isnan(allMeasurementPoints), 2));
    allData = allData(~nanLocations);
    allMeasurementPoints = allMeasurementPoints(~nanLocations, :);

    % Interpolate
    interpolatedData = griddata(allMeasurementPoints(:, 1), ...
        allMeasurementPoints(:, 2), allData, interpolationX, ...
        interpolationY, interpolationType);

    % Mask off the part of the hand outside the polyshape boundary
    interpolatedData(~surfaceMask) = nan;
end



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}