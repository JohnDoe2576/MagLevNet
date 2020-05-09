function varargout = ExcitationSignal(varargin)

% There arethree inputs to this function 
%       name:   Type of signal
%       sim:      Simulation parameters
%       parms:  Signal parameters

        name = varargin{1};
        sim = varargin{2};
        parms = varargin{3};
        t = sim.Tstart:sim.dt:sim.Tend;

        if strcmp(name, "impulse")
                u = zeros(size(t));
                u(1:parms.fin) = parms.aMax;

        elseif strcmp(name, "step")
                u = parms.aMax*ones(size(t));

        elseif strcmp(name, "rectangular")
                u = ones(size(t));
                for i = 2:length(t)
                        if (rem(i,parms.nsc) ~= 0)
                                u(i) = u(i-1);
                        else
                                u(i) = -1*u(i-1);
                        end
                end
                u = parms.aMax*u;

        elseif strcmp(name, "sine")
                u = parms.aMax * sin( (2 * pi * parms.f * t)+( 2 * pi * parms.phy ) );

        elseif strcmp(name, "chirp")
                u = parms.aMax * chirp( t, parms.f0, parms.t1, parms.f1 );

        elseif strcmp(name, "prbs")
                n_frq = 0.5 * round( 1 / ( sim.t(2) - t(1) ) );
                u = parms.aMax * idinput( length(t), 'rbs' , [parms.f0 parms.f1] / n_frq );

        elseif strcmp(name, "aprbs")
                u = aprbs( parms.aMax, parms.f0, parms.f1, t );

        elseif strcmp(name, "skyline")
                parms.TauUmin = round( parms.TauUmin / sim.dt );
                parms.TauUmax = round( parms.TauUmax / sim.dt );
                u = GenSkyline(length(t), parms);
        end

        if isrow(u)
                u = u.';
        end
        varargout{1} = u;
end

function [Signal] = GenSkyline(N, params)
%     This function generates a skyline (aprbs) function.
%     It requires 4 parameters
%     Inputs: Number of samples, N
%                Min. delay, TauUmin
%                Max. delay, TauUmax
%                Min. amplitude, AlphaUmin
%                Max. amplitude, AlphaUmax
%     Output: Signal
    
        % Extract parameters
        TauUmin = params.TauUmin;
        TauUmax = params.TauUmax;
        AlphaUmin = params.AlphaUmin;
        AlphaUmax = params.AlphaUmax;

        % Initialize a few arrays
	TauArray = zeros(1, N);
	AlphaArray = zeros(1, N);
	Signal = zeros(1, N);

        TauRange = TauUmax - TauUmin;
	AlphaRange = AlphaUmax - AlphaUmin;
    
	Total = 0; count = 0;
	while Total < N
                count = count + 1;
                TauArray(count) = fix( rand * TauRange + TauUmin );
                Total = Total + TauArray(count);
                AlphaArray(count) = rand * AlphaRange + AlphaUmin;
	end

        TauArray(count) = TauArray(count) - (Total - N);
        num_w = count;

        Start = 0;
        for count=1:num_w
                Signal(Start+(1:TauArray(count))) = AlphaArray(count);
                Start = Start + TauArray(count);
        end
end