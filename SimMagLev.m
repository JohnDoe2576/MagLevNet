function [ varargout ] = SimMagLev( varargin )
% This function simulates the system. At present, simulation is done 
% in three ways: 
%               1. Actual system using ode45
%               2. Trained Neural Network in Open-Loop 
%               3. Trained Neural Network in Closed-Loop 
%         if nargin == 4
%                 TypeOfData = varargin{ 4 };
%         elseif nargin == 3
%                 TypeOfData = varargin{ 3 };
%         end
        TypeOfData = varargin{ nargin };

        if strcmpi( TypeOfData, 'Actual' )
        % This part simulates the actual system using ode45. 
        % Usage: [t_vec, u_vec, y_vec] = SimMagLev( Sys, Sim, Excite, 'Actual' );
        
        % This code generates data for a magnetic leviation system 
        % given in the "NN_control.pdf" paper by Martin T. Hagan.
        % Input signal to this system is the current through the 
        % electromagnet. This is given by an Amplitude modulated 
        % Pseudo Random Sequence (APRBS). This APRBS is obtained 
        % using 'skyline' function. This is a signal with randomly 
        % distributed amplitudes and randomly distributed delays for 
        % shifts in these amplitudes. The shift in these amplitudes 
        % occur between randomly between 'MinDelay' & 'MaxDelay'.
        % 
        % The equation given in paper does not accommodate for 
        % zero-crossings (an un-phycical scenario). In this code, 
        % the ODE solver stops when there is a zero-crossing. It 
        % It then regenerates the signal from this point to end 
        % of time samples. The ODE45 solver then accordingly 
        % integrates from this particular time to the next 
        % zero-crossing or final time, whichever comes first. 
        % 
        % Regeneration of signal can cause changes in 'MinDelay' 
        % of the final signal. Such situations are appropriately 
        % handled.
        % 
        % Inputs: 
        %       1. Simulation parameters: dt, t_start, t_end
        %       2. Initial conditions
        %       3. System parameters: g, alfa, beta, M
        %       4. Input signal parameters: MinDelay & MaxDelay
        %       5. Actuator limits: MinVolt, MaxVolt

        % Extract parameters
        Sys = varargin{ 1 };
        Sim = varargin{ 2 };
        Excite = varargin{ 3 };

        % System parameters
        parms = Sys.parms;
        y0 = Sys.Yo;

        Tspan = Sim.Tstart:Sim.dt:Sim.Tend;
        if isrow(Tspan)
                Tspan = Tspan.';
        end

        % Pre-initialize arrays
        t_vec = zeros(length(Tspan), 1);
        u_vec = zeros(length(Tspan), 1);
        y_vec = zeros(length(Tspan), 2);

        % Create APRBS signal using 'skyline' function
        u = Excite.Fnc('skyline', Sim, Excite).';

        % disp( [ 'Inner loop: ' num2str( y0 ) ] );
        % Options for ODE45 solver
        options = odeset( 'Events', @events );

        start_idx = 1; t_final = 0.0; iter = 0;
        while t_final < Sim.Tend
                % Solve till zero crossing
                [ t_, y_, te, ~, ~ ] = ode45(@( t, y ) MagLevODE( t, y,...
                        parms, Tspan, u ), Tspan, y0, options );

                % Check if the time for zero crossing is empty?
                if ~isempty( te )
                        % If not, Nt is the (last-1) index of time array from ode45
                        Nt = length( t_ ) - 1;
                        % Find index of last shift in amplitude
                        a = find( logical( diff( u( 1:Nt ) ) ) );
                        if ~isempty( a )
                                Nt = a( end );
                        end
                        iter = iter + 1;
                else
                        Nt = length( t_ );
                end

                % Update indices
                stop_idx = start_idx + Nt - 1;

                % Save data generated unitl zero-crossing
                t_vec( start_idx:stop_idx ) = t_( 1:Nt );
                y_vec( start_idx:stop_idx,: ) = y_( 1:Nt,: );
                u_vec( start_idx:stop_idx ) = u( 1:Nt );

                start_idx = stop_idx + 1;

                % Simulation is restarted from the last shift in amplitude 
                % before zero-crossing. For this, t, u & Ic needs to be updated.

                % Update t
                sim_.Tstart = t_(Nt) + Sim.dt;
                sim_.dt = Sim.dt;
                sim_.Tend = Sim.Tend;
                Tspan = ( sim_.Tstart:sim_.dt:sim_.Tend ).';

                % Update IC
                y0 = y_( Nt,: ).';

                % Update u
                if ~isempty( Tspan )
                        u = Excite.Fnc( 'skyline', sim_, Excite ).';
                end
                t_final = t_( end );
        end
        varargout{ 1 } = t_vec;
        varargout{ 2 } = u_vec;
        varargout{ 3 } = y_vec;
        varargout{ 4 } = iter;
        
%         elseif strcmpi( TypeOfData, 'Open-Loop' )
%         % This part simulates open-loop Neural Net in open-loop
%         % Usage: [ t, U, Ypred ] = SimMagLev( Dat, MLP, 'Open-Loop' );
%                 
%                 Dat = varargin{ 1 }; MLP = varargin{ 2 };
%                 net = MLP.net;
% 
%                 % Prepare data for open-loop simulation
%                 [ UU, Ui, ~, Y ] = preparets( net,...
%                                 con2seq( Dat.u.' ), { }, ...
%                                 con2seq( Dat.y( :,1 ).' ) );
% 
%                 % Simulating open-loop data
%                 Ypred = sim( net, UU, Ui );
% 
%                 % Simulating training data in open-loop
%                 DatOL.t = Dat.t;
%                 DatOL.U = UU( 1, : );
%                 DatOL.Ui = Ui;
%                 DatOL.UU = UU;
%                 DatOL.Y = Y;
%                 DatOL.Ypred = Ypred;
%                 
%                 varargout{ 1 } = DatOL;
% 
%         elseif strcmpi( TypeOfData, 'Closed-Loop' )
%         % This part simulates open-loop Neural Net in closed-loop
%         % Usage: [ U, Ypred ] = SimMagLev( Dat, MLP, 'Closed-Loop' );
% 
%                 Dat = varargin{ 1 }; MLP = varargin{ 2 };
%                 netc = MLP.netc;
% 
%                 % Prepare data for closed-loop simulation
%                 [ U, Ui, ~, Y ] = preparets( netc, ...
%                                 con2seq( Dat.u.' ), { }, ...
%                                 con2seq( Dat.y( :,1 ).' ) );
%                 [ Ypred, ~, ~ ] = sim( netc, U, Ui, { } );
%                 
% %                 varargout{ 1 } = Dat.t;
%                 varargout{ 1 } = U;
%                 
%                 varargout{ 2 } = Y;
%                 varargout{ 3 } = Ypred;

        end
end

function [ value, isterminal, direction] = events( t, y )

        % Locate the time when height passes through zero 
        % in a decreasing direction and stop integration.
        value = y( 1 );     % detect height = 0
        isterminal = 1;   % stop the integration
        direction = -1;   % negative direction

end

function [ dydt ] = MagLevODE( t, y, parms, t_span, u )

        % Extract parameters
        g = parms.g;
        alfa = parms.alfa;
        beta = parms.beta;
        M = parms.M;
        
        % Interpolate value of 'u' to required time for ode45 operation
        int_u = interp1( t_span, u, t );
        
        % Second order ODE separated into 2 first-order ODEs
        dydt = [ y( 2 );...
                    -g + ( ( alfa / M ) * ( int_u * int_u * sign( int_u ) / y( 1 ) ) ) ...
                                                        - ( ( beta / M ) * y( 2 ) ) ];
end