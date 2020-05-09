function [  ] = PostProcess( varargin )

%       1. Dat
%       2. PlotName
%       3. WhichData
%       4. Tlag - MaxLag for correlation plots
%       5. FigDir
%       6. SaveFigureAs
%       7. SaveSp

        Dat = varargin{ 1 };
        PlotName = varargin{ 2 };
        WhichData = varargin{ 3 };
        Tlag = varargin{ 4 };
        FigDir = varargin{ 5 };
        SaveFigureAs = varargin{ 6 };
        SaveSp = varargin{ 7 };

        fn = 'Times New Roman';
        fs = 36;
        FigScale = 2.0;

        clr = LoadPlotlyColors();

        if strcmpi( PlotName, 'Plot Input-Output' )

                t = Dat.t;
                u = Dat.u;
                y = Dat.y;
                
                FigTitle = [ 'Input - Output data ( ' ...
                        WhichData ' ) ' ];
                
                fh = figure( 'Name', FigTitle );
                
                hold on; box on; grid on;
                stairs( t, u( :, 1 ), ...
                        'Color', clr.brick_red, ...
                        'LineStyle', '-', ...
                        'LineWidth', 0.5 );
                plot( t, y( :, 1 ), ...
                        'Color', clr.muted_blue, ...
                        'LineStyle', '-', ...
                        'LineWidth', 0.5 );
                hold off;
                
                xlabel( 't [s]' );
                ylabel( 'U / Y' );
                title( FigTitle );
                
                legend( 'Input, U', 'Output, Y' );
                set( legend, 'Location', 'South' );
                set( legend, 'Orientation', 'Horizontal');
                
                xlim( [ min( t ) max( t ) ] );
                ylim( [ -2 8 ] );
                
                FigureAesthetics( fn, fs, clr, FigScale, fh );
                
                if ~isempty( SaveFigureAs )
                        NameOfFig = [ SaveFigureAs SaveSp ];
                        FigType = '.png';
                        FigName = [ FigDir NameOfFig FigType ];
                        exportgraphics( fh, ...
                                FigName, ...
                                'Resolution', 96 );
                        
                        FigType = '.eps';
                        FigName = [ FigDir NameOfFig FigType ];
                        exportgraphics( fh, FigName );
                end
        end
        
        if strcmpi( PlotName, 'Plot comparison' )
                
                T = Dat.T;
                Y = Dat.Y;
                Ypred = Dat.Ypred;

                if ~iscolumn(T)
                        T = T.';
                end
                if ~iscolumn(Y)
                        Y = Y.';
                end
                if ~iscolumn(Ypred)
                        Ypred = Ypred.';
                end
                
%                 disp( [ 'T: [ ' size( T ) ' ]' ] );
%                 disp( [ 'Y: ' size( Y ) ' ]' ] );
%                 disp( [ 'Ypred: ' size( Ypred ) ' ]' ] );
                
                FigTitle = [ 'Actual and predicted output ( '...
                        WhichData '  )' ];
                
                fh = figure( 'Name', FigTitle );
                
                hold on; box on; grid on;
                
                T2 = [ T; flip( T ) ];
                Y2 = [ Y; flip( Ypred ) ];
                fill( T2, Y2, clr.SeqGreens2 );
                
                plot( T, Y, 'Color', clr.brick_red, ...
                        'LineStyle', '-', 'LineWidth', 0.8 );
                plot( T, Ypred, 'Color', clr.muted_blue, ...
                        'LineStyle', '-', 'LineWidth', 0.8 );
                
                hold off;
                
%                 xlabel( 't [s]' );
                xlabel( { [  ] } );
                ylabel( 'U / Y' );
                
                xticklabels( [  ] );
                
                title( FigTitle );
                
                legend( 'Error', 'y_{\itact}', 'y_{\itpred}' );
                set( legend, 'Location', 'South' );
                set( legend, 'Orientation', 'Horizontal');
                
                xlim( [ min( T ) max( T ) ] );
                ylim( [ -2 8 ] );
                
                FigureAesthetics( fn, fs, clr, FigScale, fh );
                
                if ~isempty( SaveFigureAs )
                        NameOfFig = [ SaveFigureAs SaveSp ];
                        FigType = '.png';
                        FigName = [ FigDir '' NameOfFig FigType ];
                        exportgraphics( fh, ...
                                FigName, ...
                                'Resolution', 96 );
                        
                        FigType = '.eps';
                        FigName = [ FigDir NameOfFig FigType ];
                        exportgraphics( fh, FigName );
                end
        end
        
        if strcmpi( PlotName, 'Plot correlation analysis' )
                
                N = length( Dat.U );
%                 Ntot = Dat.N;
%                 M = Ntot - N;   
%                 
%                 DatLen = ( Ntot - 1 ) / 3;
%                 idx2 = [ DatLen 2*DatLen 3*DatLen ];
%                 idx1 = [ M+1 idx2( 1:end-1 )+2 ];
%                 idx = [ idx1; idx2+1 ] - M;
%                 
%                 TrainDataIdx = idx( 1,1 ):idx( 2,1 );
%                 ValDataIdx = idx( 1, 2 ):idx( 2, 2 );
%                 TestDataIdx = idx( 1, 3 ):idx( 2, 3 );
% 
%                 U = Dat.U( TrainDataIdx );
%                 Y = Dat.Y( TrainDataIdx );
%                 Ypred = Dat.Ypred( TrainDataIdx );
                U = Dat.U;
                Y = Dat.Y;
                Ypred = Dat.Ypred;

                E = Y - Ypred;
                dt = Dat.T( 2 ) - Dat.T( 1 );

                Nlag = round( Tlag / dt );
                
                % Autocorrelation of Error
                [ ACF, Alag ] = xcorr( E, E, Nlag, 'unbiased' );
                Re = ACF( Alag == 0 );
                Aci = 2 * Re / sqrt( N );

                % Cross-correlation of Input and Error
                [ CCF, Clag ] = xcorr( U, E, Nlag, 'unbiased' );
                Ru = xcorr( U, U, 0, 'unbiased' );
                Cci = 2 * sqrt( Re ) * sqrt( Ru ) / sqrt( N );
                
                TlagLim = 1.01 * [ -Tlag Tlag ];
                AciLim = [ -Aci -Aci ];
                CciLim = [ -Cci -Cci ];

                % Plot Auto-correlation
                fha = figure( 'Name', 'Autocorrelation of Error' );
                
                hold on; grid on; box on;
                
                bha = bar( Alag*dt, ACF );
                flha = fill( [ TlagLim flip( TlagLim ) ], ...
                        [ AciLim -AciLim ], ...
                        clr.SeqPuBuGn4 );
                
                hold off;
                
                title( 'Autocorrelation of error' );
                xlabel( '\tau [s]' );
                ylabel( 'ACF' );
                
                xlim( TlagLim );
                ylim( 1.1 * [ min( min( [ ACF -Aci ] ) ) ...
                        max( max( [ ACF Aci ] ) ) ] );
                
                FigureAesthetics( fn, fs, clr, FigScale, fha, bha, flha );
                
                if ~isempty( SaveFigureAs )
                        NameOfFig = [ SaveFigureAs '_acf' ];
                        FigType = '.png';
                        FigName = [ FigDir NameOfFig FigType ];
                        exportgraphics( fha, FigName', ...
                                'Resolution', 96 );
                        
                        FigType = '.eps';
                        FigName = [ FigDir NameOfFig FigType ];
                        exportgraphics( fha, FigName );
                end

                % Plot Cross-correlation
                fhc = figure( 'Name', 'Cross-correlation of Input & Error' );
                
                hold on; grid on; box on;
                
                bhc = bar( Clag*dt, CCF );
                
                flhc = fill( [ TlagLim flip( TlagLim ) ], ...
                        [ CciLim -CciLim ], clr.SeqPuBuGn4 );
                
                hold off;
                
                title( 'Cross-correlation of Input & Error' );
                xlabel( '\tau [s]' );
                ylabel( 'CCF' );
                
                xlim( TlagLim );
                ylim( 1.1 * [ min( min( [ CCF -Cci ] ) ) ...
                        max( max( [ CCF Cci ] ) ) ] );
                
                FigureAesthetics( fn, fs, clr, FigScale, fhc, bhc, flhc );
                
                if ~isempty( SaveFigureAs )
                        NameOfFig = [ SaveFigureAs '_ccf' ];
                        FigType = '.png';
                        FigName = [ FigDir NameOfFig FigType ];
                        exportgraphics( fhc, FigName, ...
                                'Resolution', 96 );
                        
                        FigType = '.eps';
                        FigName = [ FigDir NameOfFig FigType ];
                        exportgraphics( fhc, FigName );
                end
        end
        
end