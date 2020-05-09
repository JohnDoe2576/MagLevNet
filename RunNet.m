function [ varargout ] = RunNet( SimType, DataSave, FigSave, FigName, CaseNumber )
% This function is the heart. This is where the problem is discretized. The
% structuring is three-fold.
%               1. Generate input-output data
%               2. Train the network and close the feedback loop
%               3. Check performance of network
% 
% In the first step of generating input-output data, three sets of data are
% generated.
%               a. A training set that accommodates both transient and
%                  steady-state behaviour.
%               b. Test set to check steady-state performance 
%               c. Test set to check transient performance
% 
% The second step is self-explanatory.
% 
% In the third step, network performance is checked. The criteria is
% two-fold.
%       1. A correlation test is done to check if any further information
%           can be extracted from the above data.
%       2. Generalization qualities ( how well the network performs outside
%           of the training data set ) is checked. This is done by checking
%           closed-loop network performance subjected to new set of data.

        % Preset Data Store
        WorkDir = [ pwd '\' ];
        DSDir = [ WorkDir 'DataStore\' ];
        DataDir = [ DSDir 'Dat\' ];
        NetDir = [ DSDir 'Net\' ];
        FigDir = [ DSDir 'Fig\' ];
        
        % Date and Time extensions to save data
        DateExtension = [ datestr( today, 'yyyymmdd' ) datestr( now, 'HHMMSS' ) ];
        
        disp( 'Checking for DataStore directories' );
        CheckDir( DSDir, DataDir, NetDir, FigDir );
        
        if FigSave == false
                FigName = [ ];
        end
        
        % Load function handles
        Fnc = FncMagLev(  );
        
        % Initialize System
        [ Sys, Sim, Excite ] = InitializeSystem( Fnc );
        disp( 'Initialized system parameters' );
        
        % Standard simulation
        if strcmpi( SimType, 'Standard' )
                
                % Generate training data-set
                [ TrainData ] = GenerateData( Fnc, Sys, Sim, Excite, 'Robust Training' );
                disp( 'Generated training data' );
                
                % Plot training data
                PlotData( Fnc, TrainData, 'Training', FigDir, FigName, CaseNumber( 1 ) );
                
                % Generate testing data-set
                [ TestData ] = GenerateData( Fnc, Sys, Sim, Excite, 'Robust Testing' );
                disp( 'Generated testing data' );
                
                % Plot testing data
                PlotData( Fnc, TestData, 'Testing', FigDir, FigName, CaseNumber( 1 ) );
                
                % Train Neural Net
                [ MyNet ] = TrainNeuralNet( Sim, Fnc, TrainData );
                disp( 'Trained Neural Net' );
                
                if DataSave == true
                        SaveAll( DataDir, ...
                                 NetDir, ...
                                 TrainData, ...
                                 TestData, ...
                                 MyNet, ...
                                 CaseNumber( 1 ), ...
                                 DateExtension );
                        disp( 'Saved generated data' );
                end
                
                PlotAll( Fnc, MyNet, TrainData, TestData, FigDir, FigName, CaseNumber( 1 ) );
                
                varargout{ 1 } = TrainData;
                varargout{ 2 } = TestData;
                varargout{ 3 } = MyNet;
                
        end
        
        if strcmpi( SimType, 'Train using existing data-set' )

                % Load Training Data-Set
                [ TrainData ] = LoadData( DataDir, CaseNumber( 1 ) );
                disp( 'Loaded training data' );
                
                % Plot Training Data
                PlotData( Fnc, TrainData, 'Training', FigDir, FigName, CaseNumber( 1 ) );
                
                % Load Testing DataSet
                [ TestData ] = LoadData( DataDir, CaseNumber( 2 ) );
                disp( 'Loaded test data' );
                
                PlotAll( Fnc, MyNet, TrainData, TestData, FigDir, FigName, CaseNumber( 1 ) );
                
                varargout{ 1 } = TrainData;
                varargout{ 2 } = TestData;
                varargout{ 3 } = MyNet;

        end
        
        if strcmpi( SimType, 'Use a pre-trained network' )
                
                % Load Training Data-Set
                [ TrainData ] = LoadData( DataDir, CaseNumber( 1 ) );
                disp( [ 'Loaded training data from ' DataDir 'DataSet' num2str( CaseNumber( 1 ) ) ] );
                
                % Load Testing DataSet
                [ TestData ] = LoadData( DataDir, CaseNumber( 2 ) );
                disp( [ 'Loaded test data from ' DataDir 'DataSet' num2str( CaseNumber( 2 ) ) ] );

                [ MyNet ] = LoadNet( NetDir, CaseNumber( 3 ) );
                disp( [ 'Loaded Neural Net from ' NetDir 'NetData' num2str( CaseNumber( 3 ) ) ] );
                
                PlotAll( Fnc, MyNet, TrainData, TestData, FigDir, FigName, CaseNumber( 1 ) );
                
                varargout{ 1 } = TrainData;
                varargout{ 2 } = TestData;
                varargout{ 3 } = MyNet;

        end
        
        if strcmpi( SimType, 'Simulate using Trained Neural Net' )
                
                [ TestData ] = LoadData( DataDir, CaseNumber( 1 ) );
                disp( [ 'Loaded data from ' DataDir 'DataSet' num2str( CaseNumber( 1 ) ) ] );

                [ MyNet ] = LoadNet( NetDir, CaseNumber( 3 ) );
                disp( [ 'Loaded Neural Net from ' NetDir 'NetData' num2str( CaseNumber( 3 ) ) ] );
                
                [ DatNet ] = SimNet( MyNet.NetC, TestData );
                
                PlotDataCL( Fnc, DatNet, 'Some', FigDir, FigName, CaseNumber( 1 ) );
                
                varargout{ 1 } = TestData;
                varargout{ 2 } = MyNet;

        end

end

function [ Sys, Sim, Excite ] = InitializeSystem( Fnc )

        % Initialize system parameters
        [ Sys, Sim, Excite ] = Fnc.SysInit(  );

end

function [ Dat ] = GenerateData( Fnc, Sys, Sim, Excite, TypeOfData )

        % Generate training data
        [ Dat ] = Fnc.GenData( Fnc, Sys, Sim, Excite, TypeOfData );

end

function [  ] = SaveAll( varargin )

        DataDir = varargin{ 1 };
        NetDir = varargin{ 2 };
        CaseNumber = varargin{ nargin - 1 };
        DateExtension = varargin{ nargin };
        
        if nargin > 4
                DataSet1 = varargin{ 3 };
                SaveData( DataDir, DataSet1, 'TrainData', CaseNumber, DateExtension );
        end
        
        if nargin > 5
                DataSet2 = varargin{ 4 };
                SaveData( DataDir, DataSet2, 'TestData', CaseNumber, DateExtension );
        end
        
        if nargin > 6
                NetData = varargin{ 5 };
                SaveNet( NetDir, NetData, 'NetData', CaseNumber, DateExtension );
        end

end

function [  ] = SaveData( DataDir, DataSet, FileName, CaseNumber, DateExtension )

        DataFileC = [ DataDir FileName num2str( CaseNumber ) '.mat' ];
        DataFileD = [ DataDir FileName DateExtension '.mat' ];
        
        t = DataSet.t;
        u = DataSet.u;
        y = DataSet.y;
        
        if ~isfile( DataFileC )
                save( DataFileC, 't', 'u', 'y' );
                disp( [ '       ' FileName 'File saved to ' DataFileC ] );
        else
                save( DataFileD, 't', 'u', 'y' );
                disp( [ '       ' FileName 'File saved to ' DataFileD ] );
        end

end

function [  ] = SaveNet( NetDir, NetData, FileName, CaseNumber, DateExtension )

        NetFileC = [ NetDir FileName num2str( CaseNumber ) '.mat' ];
        NetFileD = [ NetDir FileName DateExtension '.mat' ];
        
        NetT = NetData.NetT;
        NetC = NetData.NetC;
        
        if ~isfile( NetFileC )
                save( NetFileC, 'NetT', 'NetC' );
                disp( [ '       ' FileName 'File saved to ' NetFileC ] );
        else
                save( NetFileD, 'NetT', 'NetC' );
                disp( [ '       ' FileName 'File saved to ' NetFileD ] );
        end

end

function [ NetData ] = TrainNeuralNet( Sim, Fnc, DataSet )

        % Initialize the network using parameters provided by the user
        [ Net ] = Fnc.NetInit(  );

        % Train the network and close the loop
        [ NetT, NetC ] = Fnc.NetTrain( Sim, DataSet, Net );
        
        NetData.NetT = NetT;
        NetData.NetC = NetC;

end

function [ DataSet ] = LoadData( DataDir, CaseNumber )

        DataFile = [ DataDir 'DataSet' num2str( CaseNumber ) '.mat' ];
        if isfile( DataFile )
                DataSet = load( DataFile );
        else
                error( 'Data-Set unrecogonized. Please re-check file name' );
        end

end

function [ NetData ] = LoadNet( NetDir, CaseNumber )

        NetFile = [ NetDir 'NetData' num2str( CaseNumber ) '.mat' ];
        if isfile( NetFile )
                NetData = load( NetFile );
        else
                error( 'Neural Net unavailable. Please re-check file name' );
        end

end

function [ DatNet ] = SimNet( Net, Dat )

        if ~isrow( Dat.t )
                t = Dat.t.';
        end
        if ~isrow( Dat.u )
                u = Dat.u.';
        end
        if ~isrow( Dat.y( :,1 ) )
                y = Dat.y( :,1 ).';
        end
        
        Useq = con2seq( u );
        Yseq = con2seq( y );
        
        [ U, Ui, ~, Y ] = preparets( Net, Useq, {  }, Yseq );
        
        [ Ypred ] = sim( Net, U, Ui );
        
        StartIdx = length( y ) - length( cell2mat( Ypred ) ) + 1;
        
%         DatNet.N = length( t );
        DatNet.T = t( StartIdx:end );
        DatNet.U = u( 1, StartIdx:end );
        DatNet.Y = cell2mat( Y );
        DatNet.Ypred = cell2mat( Ypred );
        
        E = DatNet.Y - DatNet.Ypred;
        DatNet.RMSE = rms( E );

end

function [  ] = PlotData( Fnc, DataSet, FileName, FigDir, FigName, CaseNumber )

        FigSp = [ FileName 'Data' num2str( CaseNumber ) ];

        Fnc.Plot( DataSet, ...
                'Plot Input-Output', ...        % Type of Plot
                FileName, ...                   % Type of Data
                [ ], ...                        % Time Lag ( Irrellevant here )
                FigDir, ...                     % Directory to Save Figures
                FigName, ...                    % Name of Figure
                FigSp );                        % Type of Figure

end

function [  ] = PlotDataOL( Fnc, DataSet, FileName, Tlag, FigDir, FigName, CaseNumber )

        FigSp = [ FileName 'DataOL' num2str( CaseNumber ) ];
        
        FileName = [ FileName ' data' ' open-loop' ];

        Fnc.Plot( DataSet, ...
                'Plot comparison', ...          % Type of Plot
                FileName, ...                   % Type of Data
                [ ], ...                        % Time Lag ( Irrellevant here )
                FigDir, ...                     % Directory to Save Figures
                FigName, ...                    % Name of Figure
                FigSp );                        % Type of Figure

        Fnc.Plot( DataSet, ...
                'Plot correlation analysis', ...% Type of Plot
                FileName, ...                   % Type of Data
                Tlag, ...                       % Time Lag ( Irrellevant here )
                FigDir, ...                     % Directory to Save Figures
                FigName, ...                    % Name of Figure
                [  ] );                         % Type of Figure

end

function [  ] = PlotDataCL( Fnc, DataSet, FileName, FigDir, FigName, CaseNumber )

        FigSp = [ FileName 'DataCL' num2str( CaseNumber ) ];

        Fnc.Plot( DataSet, ...
                'Plot comparison', ...          % Type of Plot
                FileName, ...                   % Type of Data
                [ ], ...                        % Time Lag ( Irrellevant here )
                FigDir, ...                     % Directory to Save Figures
                FigName, ...                    % Name of Figure
                FigSp );                        % Type of Figure

end

function [  ] = PlotAll( Fnc, MyNet, TrainData, TestData, FigDir, FigName, CaseNumber )

        % Simulate system with training data in open-loop
        [ DatNet ] = SimNet( MyNet.NetT, TrainData );
        disp( 'Simulated training data using Neural Net in open-loop' );
        disp( [ '       RMSE: ' num2str( DatNet.RMSE ) ] );

        % Plot open-loop data ( includes comparison of actual &
        % predicted and correlation analysis
        PlotDataOL( Fnc, DatNet, 'Train', 20, FigDir, FigName, CaseNumber );

        clear DatNet;

        % Simulate system with training data in close-loop
        [ DatNet ] = SimNet( MyNet.NetC, TrainData );
        disp( 'Simulated training data using Neural Net in closed-loop' );
        disp( [ '       RMSE: ' num2str( DatNet.RMSE ) ] );

        % Plot closed simulation data comparison between actual and
        % predicted
        PlotDataCL( Fnc, DatNet, 'Train', FigDir, FigName, CaseNumber );

        clear DatNet;

        % Simulate system with test data in close-loop
        [ DatNet ] = SimNet( MyNet.NetC, TestData );
        disp( 'Simulated test data using Neural Net in closed-loop' );
        disp( [ '       RMSE: ' num2str( DatNet.RMSE ) ] );

        % Plot closed simulation data comparison between actual and
        % predicted
        PlotDataCL( Fnc, DatNet, 'Test', FigDir, FigName, CaseNumber );

end

function [  ] = CheckDir( DSDir, DataDir, NetDir, FigDir )

        CreateDir( DSDir );
        CreateDir( DataDir );
        CreateDir( NetDir );
        CreateDir( FigDir );

end

function [  ] = CreateDir( MyFolder )

        if ~exist( MyFolder, 'dir' )
                mkdir( MyFolder );
        end

end