function [ varargout ] = InitMagLev( )

        % System parameters
        Sys.parms.g = 9.8;           % Acceleration due to gravity
        Sys.parms.alfa = 15;         % Field strength constant
        Sys.parms.beta = 12;        % Viscous friction coefficient
        Sys.parms.M = 3;             % Mass of the magnet
        Sys.Yo = [0.5 0.0];             % Initial condition

        % Simulation parameters
        Sim.Tstart = 0.0;
        Sim.dt = 0.01;
        Sim.DT = 50;                    % Min. duration for one TauUmin - TauUmax shift
        Sim.Tend = Sim.DT;          % Testing data final time
        % To accommodate information about both transient and steady-state
        % behaviour, the training signal is separated into two sets. Initial part  
        % of the signal excites the system to capture transient behaviour, and 
        % the rest is for steady-state. So, enter values for Sim.Training as 
        % shown in the example. If transient behavour needs to be captured from 
        % 0-100s & 300-400s and steady-state behaviour needs to be captured from
        % 100+dt to 300s, and 400+dt to 600s use as follows: 
        %               Sim.Training = [ 100 300 400 600 ];
        % This Sim.Training entry is old stuff, and there is no need to
        % bother with this entry. It is used for simulations in GenMaLev of
        % Training, TestSS and TestTR
        Sim.Training = [ 100 300 400 600 700 900 ];

        % Excitation signal parameters
        Excite.Fnc = @ExcitationSignal;
        % AlphaU: Amplitude
        % TauU: Duration at a particular AlphaU
        Excite.AlphaUmin = 0.0;
        Excite.AlphaUmax = 4.0;
        Excite.TauUmin = 0.01;
        Excite.dTau = 1.0;
        Excite.TauUmax = 5.0;
        
        Excite.TauUminTR = 0.01;
        Excite.TauUmaxTR = 1.0;
        Excite.TauUminSS = 1.0;
        Excite.TauUmaxSS = 5.0;

        varargout{ 1 } = Sys;
        varargout{ 2 } = Sim;
        varargout{ 3 } = Excite;
end