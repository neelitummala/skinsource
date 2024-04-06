# SkinSource Documentation
This Github repository contains the code for the SkinSource toolbox released as part of the publication “SkinSource: A Data-Driven Toolbox for Predicting Touch-Elicited Vibrations in the Upper Limb.” The dataset that must be downloaded to use this toolbox can be found in the Zenodo repository: https://doi.org/10.5281/zenodo.10547601. If you use our dataset or toolbox, please cite our publication.

Full citation: “Tummala, N., Reardon, G., Fani, S., Goetz, D., Bianchi, M., and Visell, Y. (2024) SkinSource: A Data-Driven Toolbox for Predicting Touch-Elicited Vibrations in the Upper Limb. IEEE Haptics Symposium 2024.” 

This code has been on MATLAB R2019b and R2023a.

## SkinSource Dataset
The SkinSource toolbox is based on a dataset containing measured impulse responses. The dataset is provided as a MATLAB table in the Zenodo repository (https://doi.org/10.5281/zenodo.10547601) and should be copied into the dataset/ folder. The dataset contains impulse responses captured for 20 different input locations (see documentation/input.png) and measured at 72 output locations (66 dorsal, 6 volar; see documentation/output.png) in 3 axes. Each row of the table contains the impulse responses (variable name: "Data") for a given upper limb model (variable name: "Model") to a given input stimulus location (variable name: "Location"). The impulse responses are provided as 3-dimensional arrays (522 time samples x 72 output locations x 3 axes). The 3 axes refer to the X-, Y-, and Z-axis of the accelerometer in the array, respectively (see publication). The Z axis is always normal to the skin surface, while the X and Y axes are tangential to the skin surface. We note that though the X and Y axes are tangential to the skin, they were not oriented with respect to consistent global axes across accelerometers, so caution is advised when interpreting results from individual X and Y axes. All impulse responses are sampled at 1300 Hz.

### Upper limb model information
SkinSource allows users to choose between four different upper limb models based on data collected from four different participants. Below are details about each upper limb model, including hand length (measured in millimeters from the tip of digit III to the middle of the wrist) and sex. The participants ages were an average of 27.5 years with a 3.1 year standard deviation.
- Model 1: 175 mm, M
- Model 2: 165 mm, F
- Model 3: 185 mm, M
- Model 4: 165 mm, F

## Graphical user interface (GUI)
To get started using SkinSource, we encourage users to begin with the graphical user interface (GUI), then look through and run the scripts in the examples/ folder. The GUI provides a simple introduction to SkinSource. To use the GUI, run SkinSourceGUI.m in the GUI/ folder. The GUI allows users to generate input signals to be applied at specified input locations, visually display the results, and save the output data for further analysis. To begin, first define the input signal and then apply it to a specific input "Location." The input location is specified using the drop-down menu in the top middle of the GUI. These input numbers correspond with specific input locations on the palmar hand surface that is displayed on the graphic on the left of the screen. For more information, please see our publication. You can select from four different input signals: "Sinusoids," "Impulses," "White Noise," and "Custom" using the drop-down menu in the middle of the screen. Each different signal is associated with a different set of input parameters. For the "Sinusoids" set the "Amplitude" and "Frequency" (in Hz). For the "Impulse" set the "Amplitude." For the "Noise" set the "Amplitude" and the "RNG Seed." The "RNG Seed" sets the seed of the random number generator to produce predictable sequences of white noise. For "Custom" users can read in custom .wav files that have been written out at 1300 Hz sample rate. Simply type the filename into the box and the signal will be loaded in. The signal can then be applied to the specified input location (given by the location drop-down menu) using the "Apply Signal" button. To clear the input signal from a specified location use the "Clear Signal" button. To clear all applied input signals use the "Clear All Signals" button. The length of the input signals can be controlled globally using the editable text box on the top right of the GUI. The maximum allowable signal length for the GUI is 1000 ms in length (and a minimum of 30 ms). To use longer input signals, users must write their own code. Custom signals with lengths greater than 1000 ms are cut to length. The GUI includes an interactive plot of the input signals on the left-hand side of the screen.

You can select which skin acceleration axis you wish to view using the "Axis" drop-down menu. For multi-axis viewing (i.e., viewing the "xy" axis or "xyz" axis), please select a projection method from the "Projection" drop-down menu. This determines how the multi-axis measurements are compressed into a single axis for viewing. The options available in the GUI are "mag," "pca," "soc," and "rms," which correspond to a vector magnitude projection, a projection onto the principle component axis computed via PCA, a sum of components projection, and a root mean square projection. See the SkinSource documentation for a better understanding of these different available dimensionality reduction schemes. Finally, select a model to use from the "Model" drop-down menu. Use the "Render" button to render the SkinSource outputs given the inputs and the specified rendering parameters. To render outputs with different parameters simply change them via the drop-down menu and press the "Rendering" button again. Results can be rapidly inspected in the GUI in this manner.

For simplicity, the GUI only displays the time-averaged (RMS) skin acceleration interpolated to a 2D hand surface. The time-domain results can be stored for later analysis using the "Save" button. This button writes an output file named SkinsourceGUI-Output.mat, which includes the single-axis projected vibrations in the time domain along with the array of input signals that generated the results and the rendering parameters. Be sure to rename the filename after every save or the data may be overwritten. We encourage users who are seeking more advanced functionality, such as integration of SkinSource with user-captured data (e.g., from a skin-object interaction of interest) or for systematic studies of vibration transmission, to examine the code examples and write their own code.

## Example Overviews
The example scripts in the examples/ folder may provide a helpful introduction to writing your own code that interfaces with SkinSource. Before running the examples, please be sure to run PathSetup.m, which will set up the MATLAB paths required to run these scripts. The SkinSource toolbox includes two objects---SkinSource and SkinSourceVisualization. The SkinSource object is primarily responsible for interfacing with the dataset, convolving user-specified inputs with the impulse responses, and projecting 3-axis results to a single axis (if desired by the user). The SkinSourceVisualization object includes a number of helpful methods to enable users to visualize the results of the SkinSource object on a 2D hand model. For more information about these objects, use "help SkinSource" and "help SkinSourceVisualization" in the MATLAB command line and click on Documentation.

### Walking through an Example - SinusoidVibrationsExample.m
- Load "Constants", which is a struct containing several necessary constants, such as the sampling frequency and file paths. This should be called at the beginning of any file you write. 
- Define the following:
    - Upper limb model number. This must be an integer between 1 and 4. 
    - One or more input location numbers. This must be an array of non-repeating integers between 1 and 20 (see documentation/input.png). 
    - Parameters for the sinusoid input stimuli, including frequency, phase, amplitude, and signal length. 
    - Interpolation and projection parameters for visualization of the resulting skin vibrations.
- Instantiate SkinSource and SkinSourceVisualization objects.
- For each sinusoid frequency:
    - Construct an input sinusoid stimulus using the generatesinusoidinput function.
    - Predict the resulting skin vibrations with the getoutputvibrations function. This function convolves the stimulus with the impulse responses for the selected impulse responses.
    - Project the output skin vibrations onto a single axes with the desired projection parameters using the projectvibrations function.
    - Visualize the RMS amplitude of the projected skin vibrations (in dB) on a 2D upper limb surface using the plotrmsvibrations function.

### ImpulseResponseExample.m
- Plots the z-axis time-domain impulse response at 7 output locations for an input applied to the tip of digit III (perpendicular) of upper limb model 4. Also plots the interpolated impulse response field across the whole upper limb at individual time steps. Corresponds to Fig. 1C in the associated publication.

### SinusoidVibrationsExample.m
- Plots the RMS of the vector-magnitude response for 4 different sinusoidal inputs applied to the tip of digit II (perpendicular) of upper limb model 1. Corresponds to Fig. 2B in the associated publication.

### SinusoidSuperpositionExample.m
- Plots the x-axis time-domain response at 4 output locations for a 200 Hz sinusoid applied at the tip (perpendicular) and base of digit III of upper limb model 3. Corresponds to Fig. 2F in the associated publication.

### TapsExample.m
- Plots the RMS of the vector-magnitude response of an impulsive tap applied to digits II-V (perpendicular) of upper limb model 3. Corresponds to Fig. 2E in the associated publication.

### WhiteNoiseExample.m
- Plots the x-axis frequency domain response at 7 output locations for white noise stimuli applied at the tip of digit V (in-axis) of upper limb model 2. Corresponds to Fig. 2D in the associated publication.
