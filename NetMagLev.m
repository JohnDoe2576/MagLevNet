function [ NetT, NetC ] = NetMagLev( Sim, Dat, Net )

        Net.SampleTime = Sim.dt;

        DatLen = ( length( Dat.t ) - 1 ) / 3;
        idx2 = [ DatLen 2*DatLen 3*DatLen ];
        idx1 = [ 1 idx2( 1:end-1 )+2 ];
        idx = [ idx1; idx2+1 ];

        Net.divideFcn = 'divideind';
        Net.divideParam.trainInd = idx( 1,1 ):idx( 2,1 );
        Net.divideParam.valInd   = idx( 1, 2 ):idx( 2, 2 );
        Net.divideParam.testInd  = idx( 1, 3 ):idx( 2, 3 );
        disp( idx );
        
%         Net.trainParam.showWindow = false;
%         Net.trainParam.showCommandLine = true;

        % Prepare data
        Useq = con2seq( Dat.u.' );
        Yseq = con2seq( Dat.y( :, 1 ).' );
        [ U, Ui, ~, Y ] = preparets( Net, Useq, {  }, Yseq );
        
        % Configure network
        Net = configure( Net, U, Y );
        
        % Train network
        NetT = train( Net, U, Y, Ui );
        
        % Close feedback loop
        NetC = closeloop( NetT );
        
end