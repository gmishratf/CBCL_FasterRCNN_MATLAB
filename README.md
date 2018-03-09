# CBCL_FasterRCNN_MATLAB
Module to train a faster RCNN using the MIT CBCL dataset for vehicle detection, using MATLAB

CBCL dataset here: cbcl.mit.edu/software-datasets/streetscenes/

build_data() may be used standalone to extract bounding box annotation information from the CBCL annotations.
CBCL annotations in XML format have more than 4 points for each annotated vehicle, build_data() converts that information to bounding
box information that can be used with a faster RCNN object in MATLAB.

This:
![alt text](https://github.com/tallestfinder/CBCL_FasterRCNN_MATLAB/blob/master/CBCL%20XML.png)


Becomes this:  
![alt text](https://github.com/tallestfinder/CBCL_FasterRCNN_MATLAB/blob/master/CBCL%20Matlab.jpg)

Use 'Mod_MIT_training.m' to train your detector, change parameters in the options variable.
2 pre-trained detectors in the "detectors" folder, 1 trained on 300 random images and another on 900 random images from the CBCL dataset.
(These detectors have horrible accuracy, you have been warned!)

detection_with_faster_r_cnn.m uses the faster RCNN to detect vehicles from video
detection_bgsub_faster_rcnn.m applies a gaussian mixture model to extract only moving objects, then uses the trained faster RCNN to 
detect if those moving objects are vehicles or not. This performs faster than just a plain faster RCNN, accuracy is reduced though.


TODO:
  - Video links
  - Organize code
  - Write a better readme
