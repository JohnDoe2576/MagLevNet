function [ Fnc ] = FncMagLev()
% There are many functions that are used in this project.
% This particular file is used to enter the required functions 
% into a struct named Fnc. The problem discretized resulted 
% requirement of 5 processes.
%       1. Initializing the system
%       2. Generate data
%           a. Function simulating data
%           b. Obtaining 3 sets of combined data for training
%           c. Obtain data for testing
%       3. Initializing neural network parameters

        Fnc.SysInit = @InitMagLev;
        Fnc.SimData = @SimMagLev;
        Fnc.GenData = @GenMagLev;
        Fnc.NetInit = @InitNet;
        Fnc.NetTrain = @NetMagLev;
        Fnc.Plot = @PostProcess;

end