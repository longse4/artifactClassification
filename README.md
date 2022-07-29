## artifactClassification
GUI-based preprocessing pipeline to implement artifact classification on SEEG data. Developed using Matlab R2017a.

Example data can be downloaded: https://www.dropbox.com/sh/vcjyznmfa0977qp/AACDMeF7uCvKuYyrrt-f3fv7a?dl=0. This data folder contains a .dat file that contains data acquired from a subject as they performed a visual search task. This data folder also contains a .csv file with the appropriate channel information and column titles that will be needed to properly run the processing pipeline. 

#HOW TO RUN THIS CODE:

(1) Navigate to the artifactClassification folder (or add it to your path) and then run 'SetupArtifactClass' in the command window to set the appropriate paths. 

(2) After completing this you initiate the pipeline by running 'preprosEEG' in the command window. This will bring up a GUI that requires you to select the subject folder, data file(s), and .csv file along with selecting the steps you would like to complete. 

(3) Hit the "Next" button to proceed to the next step. You will be prompted whether you would like to back up this step. If you are going to continue on in the processing, I would suggest holding off on backing up the data. 

(4) Next, you will be asked to review the monopolar data and reject channels. At this point I would only reject channels that are flat or have a lot a machine or muscle artifact. You most likely want to leave the Spiking channels for the IED detection step. 

(5) After hitting next, your re-referenced data will be calculated and plotted for visual inspection and channel rejection. Once again, I would only reject channels that are flat or have a lot a machine or muscle artifact. You most likely want to leave the Spiking channels for the IED detection step.

(6) Next you will be presented with GUI for actually performing the artifact detection and classification. In this step you first need to run the detection (green button), you can adjust the signal type and k-value used for detection. This will take several minutes to run. Additionally, you can adjust the estimated prior probabilities to better reflect the event class distribution of your data before or after running the event detection.

(7) After running the detection, visually inspect the the results by scrolling through the data using the arrows above the signal and navigating between probes using "Probe Controls". You can reclassify any event markers by clicking the yellow "Reclassify event" button, selecting any event(s) you would like to reclassify by clicking on them with the cursor (hit enter when you are done selecting), and then pick the event type you would like these to be classified as ('artifact', 'pathology', or 'physiology'). There are several "View Controls" you can utilize while visualizing your data including "Pan%" (how much you move through the data at a time), "Gain%" (amplitude), "Amp Span" (incremental amplitude control), and "Timebase" (time-axis control per mm). Additionally, you can reset your time axis to zero by clicking "Reset Time Axis". At this point you can also choose to reject additional channels.  

(8) Don't forget to save your data!
