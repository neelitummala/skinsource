%
% SINUSOIDSUPERPOSITIONEXAMPLE is an example script for reconstructing skin
%   oscillations in response to two simultaneous sinusoidal vibrations.
%   The given example corresponds to Fig. 2F in the paper.
%

close all
clear all
clc

% Load the constants struct
Constants

%% Parameters

% Upper limb model number (1-4)
model = 3;

% Input locations for the sinusoidal vibrations (1-20)
inputLocations = [8, 13];
nInputs = length(inputLocations);

% Frequencies of input vibrations. Number of frequencies should match the
% number of input locations
inputFrequencyHz = [200, 200];

% Phases (in radians) of input vibrations. Number of phases should match
% the number of input locations
inputPhaseRad = [0, 0];

% Desired maximum peak-to-peak accelerations (m/s^2) across the upper limb 
% for output skin vibrations resulting from the application of each of the 
% input vibrations.
amplitudes = [1, 1];

% Length of the input stimulus. 10 cycles of the vibrations
inputLen = round(10*constants.FS/inputFrequencyHz(1)); 

% For visualization:
% Type of interpolation to use
interpolationType = 'natural';

% Axis to visualize the vibrations on
visualizationAxes = 'x';

% Method to project the data from 3 axes to 1 axis
visualizationProjection = 'none';

%% Determine the skin vibrations in response to the sinusoid input(s)

% Initialize a SkinSource object to get output vibrations across the upper
% limb for given parameters
skinsource = SkinSource(inputLocations, model, constants);

% Make the input stimuli. This outputs a cell array with one cell for each
% input stimulus (for each input location)
inputSinusoids = skinsource.generatesinusoidinput(inputLen, ...
    inputFrequencyHz, inputPhaseRad, 'tukey');

% Get the ouput skin vibrations
vibrations = skinsource.getoutputvibrations(inputSinusoids, amplitudes);


% Project the vibrations onto the desired axes with the desired projection
% method. In this case, we are only looking at the x axis.
projectedVibrations = skinsource.projectvibrations(vibrations, ...
    visualizationProjection, visualizationAxes);

% Initialize a SkinSourceVisualization object to do some plotting
skinsourceVis = SkinSourceVisualization(inputLocations, model, ...
    constants);

% Indices of output locations at which to plot the resulting vibrations. 
% You can select locations by going to documentation/outputLocations.png
selectedLocations = [19, 21, 24, 32];
skinsourceVis.plotselectedtimedomainvibrations(projectedVibrations, ...
    selectedLocations)



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}