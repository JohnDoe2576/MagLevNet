# MagLevNet
Neural Network Model for Magnetic Levitation System

References:
-----------
[**BeHaDe2010**] Beale, M. H., M. T. Hagan, H. B. Demuth ( 2010 ). Neural Network Toolbox 7: User's guide, The Mathworks Inc.

[**Ha2014**] Hagan M. ( 2014 ). Neural Network Design.

[**HaDeJe2002**] Hagan, M. T., H. B. Demuth and O. D. Jesus ( 2002 ). An introduction to use of neural networks in control systems. International Journal of Robust and Nonlinear Control, 12( 11 ), 959-985.

Code
----
The problem is discretized into three stages:
> 1. Obtaining input-output data from the system
> 2. Training a Neural Net ( Multi-Layer Perceptron ) using this data
> 3. Check performance of Neural Net

## Magnetic Levitation System
The system consists of a vertically-only movable levitating magnet whose position is controlled by current flowing through an electromagnet. This is modelled as a second-order nonlinear system [**BeHaDe2010**].
### Obtaining input-output data
To obtain a good data-based model, all frequencies and amplitudes within the desired operating range of this nonlinear dynamical system needs to be excited. An **A**mplitude-modulated **P**seudo **R**andom **B**inary **S**equence does the job The `GenSkyline` function in [ `Files/ExcitationSignal.m` ]( https://github.com/JohnDoe2576/MagLevNet/blob/master/Files/ExcitationSignal.m ).
