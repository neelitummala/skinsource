function projData = project3d(ax1, ax2, ax3, projType)
% 
% PROJECT3D  projects data with 3 axes to 1 axis.
% 
%   USAGE
%       projData = PROJECT3D(ax1, ax2, ax3, projType)
%
%   INPUT PARAMETERS
%       ax1 - Data in first axis.
%       ax2 - Data in second axis.
%       ax3 - Data in third axis.
%       projType - Type of projection. Must be:
%           'mag' - Magnitude of components.
%           'pca' - Principal component analysis.
%           'rms' - Project onto axis with the most energy.
%           'soc' - Sum of components.
%
%   OUTPUT PARAMETERS
%       projData - Projected data (1 axis).
%

% Vector magnitude of acceleration signal. Has a rectifying property,
% making it less useful for frequency analysis
if strcmp(projType,'mag')
    projData = (ax1.^2 + ax2.^2 + ax3.^2).^0.5;

% Project onto only first principal component of data variance 
elseif strcmp(projType,'pca')
    projData = zeros(size(ax1));
        
    sig = cat(3,cat(3,ax1,ax2),ax3);
    for i = 1:size(sig,2)
        dummy = squeeze(sig(:,i,:));        
        [COEFF, ~, ~, ~, ~] = pca(dummy, 'Centered', true);
        projData(:,i) = dummy*COEFF(:,1); %project
    end
    
% Project onto axis of primary energy
elseif strcmp(projType,'rms')
    
    projData = zeros(size(ax1));
    sig = cat(3,cat(3,ax1,ax2),ax3);
    e = squeeze(rms(sig, 1));  
    normVec = e ./ vecnorm(e,2,2);
    for i = 1:length(e)
        projData(:,i) = squeeze(sig(:,i,:))*(normVec(i,:)');
    end
    
% Sum of components
elseif strcmp(projType,'soc')
    projData = ax1 + ax2 + ax3;

% If not any of the above projection types, throw error.
else
    error("Type not supported. Must be 'mag', 'pca', 'rms', or 'soc'.")
end

end



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}