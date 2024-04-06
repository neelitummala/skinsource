%
% SINUSOIDALVIBRATIONSEXAMPLE is an example script for reconstructing skin
%   oscillations in response to sinusoidal vibrations of different 
%   frequencies. The given example corresponds to Fig. 2B in the
%   paper.
%

close all
clear all
clc

% Load the constants struct
Constants

%% Parameters

% Upper limb model number (1-4)
model = 1;

% Input locations for the sinusoidal vibrations (1-20)
inputLocations = [7];
nInputs = length(inputLocations);

% Frequencies of input vibrations. These will be applied sequentially (not
% superimposed)
inputFrequencyHz = [50, 100, 200, 400];

% Phases (in radians) of input vibrations. Number of phases should match
% the number of input locations
inputPhaseRad = [0];

% Desired maximum peak-to-peak accelerations (m/s^2) across the upper limb 
% for output skin vibrations resulting from the application of each of the 
% input vibrations.
amplitudes = [1];

% Length of the input stimulus. 10 cycles of the vibrations
inputLen = round(10*constants.FS/inputFrequencyHz(1)); 

% For visualization:
% Type of interpolation to use
interpolationType = 'natural';

% Axis to visualize the vibrations on
visualizationAxes = 'xyz';

% Method to project the data from 3 axes to 1 axis
visualizationProjection = 'mag';

%% Determine the skin vibrations in response to the sinusoidal inputs

% Initialize a SkinSource object to get output vibrations across the upper
% limb for given parameters
skinsource = SkinSource(inputLocations, model, constants);

% Initialize a SkinSourceVisualization object to do some plotting
skinsourceVis = SkinSourceVisualization(inputLocations, model, ...
    constants);

% Iterate through a list of input frequencies
for f=1:length(inputFrequencyHz)

    % Make input sinusoid
    inputSinusoids = skinsource.generatesinusoidinput(inputLen, ...
        inputFrequencyHz(f), inputPhaseRad, 'tukey');

    % Get the ouput skin vibrations
    vibrations = skinsource.getoutputvibrations(inputSinusoids, ...
        amplitudes);

    % Project the vibrations onto the desired axes with the desired
    % projection method. In this case, we are getting the signal magnitude
    % across all 3 axes.
    projectedVibrations = skinsource.projectvibrations(vibrations, ...
        visualizationProjection, visualizationAxes);

    % Plot the RMS amplitudes across the 2D surface
    skinsourceVis.plotrmsvibrations(projectedVibrations, interpolationType)
    title(sprintf('RMS acceleration (dB re. 1 m/s^2), %s Hz', ...
        num2str(inputFrequencyHz(f))));
end



% Revision history:
%{
2024-04-05: v1.0.0 released.
%}