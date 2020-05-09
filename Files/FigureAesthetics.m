function [  ] = FigureAesthetics( varargin )
%               1. fn: Font Name
%               2. fs: Font Size
%               3. clr: Custom color object
%               4. FigScaling: Scale by Default ( [ width height ] = [ 24 10 ] )
%               5. FigHdl: Figure Handle
%               6. BarHdl: Bar Handle
%               7. PthHdl: Patch Handle

% Font Name
if isempty( varargin{ 1 } )
        fn = 'Time New Roman';
else
        fn = varargin{ 1 };
end
% Font Size
if isempty( varargin{ 2 } )
        fs = 36;
else
        fs = varargin{ 2 };
end

% Colors
if isempty( varargin{ 3 } )
        clr = LoadPlotlyColors( );
else
        clr = varargin{ 3 };
end

% Figure scaling
if isempty( varargin{ 4 } )
        FigScaling = 2.0;
else
        FigScaling = varargin{ 4 };
end

% Figure handle ( cannot be empty )
FigHdl = varargin{ 5 };

SystemDefaultUnits = get( 0, 'Units' );
DefaultSize = [ 24 10 ];
DefaultUnits = 'centimeters';

set( 0, 'Units', 'Pixels' );
SizeInPix = get( 0, 'ScreenSize' );
set( 0, 'Units', DefaultUnits );
ScreenSize = get( 0, 'ScreenSize' );
PPcm = SizeInPix ./ ScreenSize;

% Automatically set position of figure
if ScreenSize( 3:4 ) >= ( FigScaling * DefaultSize )
        WindowSize = FigScaling * DefaultSize;
else
        set( 0, 'Units', SystemDefaultUnits );
        WindowSize = [ 1376 768 ] / PPcm;
        set( 0, 'Units', DefaultUnits );
end
Position = [ ( ( ScreenSize( 3:4 ) - WindowSize ) / 2 ) WindowSize ];
% Position = [ 1, 12, WindowSize ];
% Position = [ 25, 2, WindowSize ];

% Figure properties
FigHdl.Units = DefaultUnits;
FigHdl.Position = Position;
FigHdl.Color = 'w';
% FigHdl.WindowStyle = 'Docked';
% FigHdl.Renderer = 'painters';

% Axis properties
AxHdl = FigHdl.CurrentAxes;
AxHdl.FontName = fn; AxHdl.FontSize = fs;
AxHdl.TitleFontWeight = 'normal';
AxHdl.TitleFontSizeMultiplier = 1.0;
AxHdl.LabelFontSizeMultiplier = 1.0;
AxHdl.Color = clr.my_grey; AxHdl.GridColor = 'w';
AxHdl.XColor = 'k'; AxHdl.YColor = 'k'; AxHdl.ZColor = 'k';
AxHdl.LineWidth = 0.6; AxHdl.GridAlpha = 1;

if nargin > 5
        BarHdl = varargin{ 6 };
%         BarAx = BarHdl.Parent;
        BarHdl.BarWidth = 0.0;
        BarHdl.FaceColor = clr.SeqPuBuGn7;
        BarHdl.FaceAlpha = 1.0;
        BarHdl.EdgeColor = clr.SeqPuBuGn7;
        BarHdl.LineWidth = 1.2;
end

if nargin > 6
        PthHdl = varargin{ 7 };
        PthHdl.FaceColor = clr.SeqPuBuGn4;
        PthHdl.FaceAlpha = 0.3;
        PthHdl.EdgeColor = 'none';
%         PthHdl.EdgeAlpha = 0.5;
end

set( 0, 'Units', SystemDefaultUnits );