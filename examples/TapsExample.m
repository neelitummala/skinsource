%
% TAPSEXAMPLE is an example script for applying taps at several locations
% on the hand. The given example corresponds to Fig. 2E in the paper.
%

close all
clear all
clc

% Load the constants struct
Constants

%% Parameters

% Upper limb model number (1-4)
model = 3;

% Input locations for the taps (1-20)
inputLocations = [7, 8, 9, 10];
nInputs = length(inputLocations);

% Desired maximum peak-to-peak accelerations (m/s^2) across the upper limb 
% for output skin vibrations resulting from the application of each of the 
% input taps.
amplitudes = ones(1, nInputs);

% Times at which the taps occurr. In this case, they occur simultaneously.
tapTimes = zeros(1, nInputs);

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

% Make input taps
inputTaps = skinsource.generatetapinput(nInputs, tapTimes);

% Get the ouput skin vibrations
vibrations = skinsource.getoutputvibrations(inputTaps, ...
    amplitudes);

% Project the vibrations onto the desired axes with the desired
% projection method. In this case, we are getting the signal magnitude
% across all 3 axes.
projectedVibrations = skinsource.projectvibrations(vibrations, ...
    visualizationProjection, visualizationAxes);

% Plot the RMS amplitudes across the 2D surface
skinsourceVis.plotrmsvibrations(projectedVibrations, interpolationType)
title('Response to multi-digit taps, RMS (dB re. 1 m/s^2)')


% Revision history:
%{
2024-04-05: v1.0.0 released.
%}