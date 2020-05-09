function [ Net ] = InitNet( )

        InputDelays = 1:8;
        FeedbackDelays = 1:8;
        HiddenSizes =10;
        FeedbackMode = 'open';
        TrainFcn = 'trainlm';
        
        Net = narxnet( InputDelays, ...
                       FeedbackDelays, ...
                       HiddenSizes, ...
                       FeedbackMode, ...
                       TrainFcn );

        % Remove bias from outer layer
%         net.biasConnect( 2, 1 ) = 0;
        
        % Use Nguyen-Widrow function to initialize weights
        Net.layers{ :,1 }.initFcn = 'initnw';

        % Normalize data (mapminmax is default). If required use mapstd
        Net.inputs{ :,1 }.processFcns{1,2} = 'mapstd';
        
        % Modify training parameters
        Net.trainParam.min_grad = 1e-10;
        Net.trainParam.epochs = 10000;
        Net.trainParam.max_fail = 15;
        Net.performFcn = 'mse';
        % Net.performParam.regularization = 1e-12;
        Net.plotFcns{1,3} = 'plotwb';

end