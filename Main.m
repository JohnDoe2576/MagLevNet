close all; clear all; clc;

% SimType = 'Standard';
% SimType = 'Generate Data only';
% SimType = 'Load and plot pre-existing data';
% SimType = 'Train using existing data-set';
% SimType = 'Use a pre-trained network';
SimType = 'Simulate using Trained Neural Net';
DataSave = false;
FigSave = true;
FigName = 'MagLev';
% CaseNumber = [ TrainData TestData NetData ];
CaseNumber = [ 20 8 4 ];

% [ TrainData, TestData, NetData ] = RunNet( SimType, DataSave, FigSave, FigName, CaseNumber );
[ TestData, NetData ] = RunNet( SimType, DataSave, FigSave, FigName, CaseNumber );
% [ TrainData, TestData ] = RunNet( SimType, DataSave, FigSave, FigName, CaseNumber );
% [ DataSet ] = RunNet( SimType, DataSave, FigSave, FigName, CaseNumber );

clear SimType; clear DataSave; clear FigSave; clear FigName; clear CaseNumber;































% close all; clear all; clc;
% 
% % This code can be utilized in multiple ways
% %       1. Standard: Generate new sets of data, train a neural network
% %       2. Load a pre-existing data-set and train a neural network
% %       3. Load pre-trained neural network
% %       4. Generate new data-set
% % 
% % Figure naming convention:
% % LoadFile + _ + Case- + CaseNumber + _ + Lmin-Lmax + _ + Mmin-Mmax + _ + H
% % L: Number of previous delayed inputs
% % M: Number of previous delayed outputs
% % H: Number of Hidden layer neurons
% 
% % CaseNumber = 3;
% Lmin = 1;
% Lmax = 8;
% Mmin = 1;
% Mmax = 8;
% H = 10;
% 
% LoadFile = 'MagLevDS3';
% % LoadFile = 'default';
% SaveFile = { };
% % SaveFigureAs = { };
% % SaveFigureAs = SaveFile;
% SaveFigureAs = [ LoadFile '_L' ...
%         num2str( Lmin ) '-' num2str( Lmax ) '_M' num2str( Mmin ) '-' ...
%         num2str( Mmax ) '_H' num2str( H ) ];
% % disp( SaveFigureAs );
% 
% % MySys = RunNet( 'Standard', LoadFile, SaveFile, SaveFigureAs );
% MySys = RunNet( 'Load pre-trained Neural Network', LoadFile, SaveFile, SaveFigureAs );
% % MySys = RunNet( 'Generate new data-set', LoadFile, SaveFile, SaveFigureAs );
% % MySys = RunNet( 'Simulate Neural Network with pre-existing data', LoadFile, SaveFile, SaveFigureAs );
% 
% clear LoadFile; clear SaveFile; clear SaveFigureAs; clear Lm*; clear Mm*; clear H;
% clear CaseNumber;
