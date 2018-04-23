EyeCalib:
Graphical User Interface for eye calibration in the context of a setup
described in DeHaan et al 2018
**********************************************************************
Version 2.0

This version includes loading from c3d (KINARM) files or NEV/NS2 (Black
rock microsystems).
This version has been modified to reduce the number of targets to 17 in
order to decrease the calibration duration.
This version shows the correction for order 2, 3 and 4 polynomial
functions and allows the user to select the one he wants to use.

***********************************************************************
GUI requirements and specifications.
------------------------------------
IMPORTANT: Set your path in the preferences before anything.
-----------------------------------------------------------------------
Specifications for the use of c3d files:
Eye position from the eye tracker should be saved on analog channels in
the Kinarm real time computer. The channel names should be eye_x_r and
eye_y_r for X and Y channels respectively for the right eye if present,
and should be named eye_x_l and eye_y_l for the left eye if present.

Specifications for the use of NEV/NSx files:
The specifications will be available on request.

************************************************************************
GUI output:
The GUI outputs parameters of the calibration model into the dtp of a
kinarm experiment.
The parameters can also be exported into a Matfile.