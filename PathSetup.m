% PATHSETUP  Run this file to set up your MATLAB path for SkinSource.


addpath('examples/')
addpath('dataset/') 
addpath('GUI/') 
addpath('source/')
addpath('source/visualization')
addpath('source/internal/')

% The impulse response dataset must be downloaded and put in the dataset/
% folder. It can be found in the SkinSource Zenodo repository:
% https://doi.org/10.5281/zenodo.10547601
if ~exist('dataset/impulseResponses.mat', 'file')
  warningMessage = ['Warning: the dataset (impulseResponses.mat) ', ...
      'has not been downloaded. Please download it from the Zenodo ', ...
      'repository (https://doi.org/10.5281/zenodo.10547601) and put ', ...
      'it in the dataset/ folder.'];
  uiwait(msgbox(warningMessage));
end


% Revision history:
%{
2024-04-05: v1.0.0 released.
%}