# artifactClassification
GUI-based preprocessing pipeline to implement artifact classification on SEEG data. Developed using Matlab R2017a.

Example data can be downloaded: https://www.dropbox.com/sh/vcjyznmfa0977qp/AACDMeF7uCvKuYyrrt-f3fv7a?dl=0. This data folder contains a .dat file that contains data acquired from a subject as they performed a visual search task. This data folder also contains a .csv file with the appropriate channel information and column titles that will be needed to properly run the processing pipeline. 

To run this code you will want to navigate to the artifactClassification folder (or add it to your path) and then run SetupArtifactClass to set the appropriate paths. After completing this you initiate the pipeline by running preprosEEG. This will bring up a GUI that requires you to select the subject folder, data file(s), and .csv file along with selecting the steps you would like to complete. 
