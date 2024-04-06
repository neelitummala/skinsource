%
% WHITENOISEEXAMPLE is an example script for reconstructing skin
%   oscillations in response to a white noise stimulus and looking at the
%   frequency domain magnitude spectrums. The given example corresponds to
%   Fig. 2D in the paper.
%

close all
clear all
clc

% Load the constants struct
Constants

%% Parameters

% Upper limb model number (1-4)
model = 2;

% Input locations (1-20)
inputLocations = [5];
nInputs = length(inputLocations);

% Random seed for the white noise stimulus
randomSeed = 0;

% Desired maximum peak-to-peak accelerations (m/s^2) across the upper limb 
% for output skin vibrations resulting from the input stimulus.
amplitudes = [1];

% Length of the input stimulus in samples
inputLen = 1000; 

% For visualization:
% Type of interpolation to use
interpolationType = 'natural';

% Axis to visualize the vibrations on
visualizationAxes = 'x';

% Method to project the data from 3 axes to 1 axis
visualizationProjection = 'none';

%% Determine the skin vibrations in response to the sinusoidal inputs

% Initialize a SkinSource object to get output vibrations across the upper
% limb for given parameters
skinsource = SkinSource(inputLocations, model, constants);

% Initialize a SkinSourceVisualization object to do some plotting
skinsourceVis = SkinSourceVisualization(inputLocations, model, ...
    constants);

% Make input white noise stimulus
inputStimulus = skinsource.generatewhitenoise(inputLen, nInputs, ...
    randomSeed);

% Get the ouput skin vibrations
vibrations = skinsource.getoutputvibrations(inputStimulus, ...
    amplitudes);

% Project the vibrations onto the desired axes with the desired
% projection method. In this case, we are looking at only the x axis.
projectedVibrations = skinsource.projectvibrations(vibrations, ...
    visualizationProjection, visualizationAxes);

% Get frequency domain magnitude spectrums
[f, frequencySpectrums] = ....
    skinsource.getfrequencymagnitudespectrums(projectedVibrations);

% Plot the frequency spectrums at selected points
selectedLocations = [1, 6, 8, 9, 48, 49, 72];
skinsourceVis.plotselectedfrequencydomainsignals(f, frequencySpectrums, ...
    selectedLocations, 1)


% Revision history:
%{
2024-04-05: v1.0.0 released.
%}