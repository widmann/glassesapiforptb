function demo_block( Cfg, Tobii )
% demo_block - Block script for Tobii Glasses 2 API demo experiment
% Copyright (c) 2022 Andreas Widmann
% Author: Andreas Widmann, widmann@uni-leipzig.de

% Init screen, audio device, serial port, etc.
Cfg.porthandle = IOPort( 'OpenSerialPort', '/dev/ttyUSB0', 'FlowControl=None,BaudRate=300' );

% Calibrate eyetracker
Tobii = tobiiGlassesAPI( Tobii, 'calibration' );
while strcmp( Tobii.calState, 'failed' )
    fprintf( '*** Press enter to repeat or ctrl+c to cancel.\n' )
    pause
    Tobii = tobiiGlassesAPI( Tobii, 'calibration' );
end

% Start recording
Tobii = tobiiGlassesAPI( Tobii, 'recording', 'name', Cfg.filenamebase );
fid = fopen( fullfile( 'log', sprintf( '%s_recinfo.txt', Cfg.filenamebase ) ), 'w' );
fprintf( fid, '%s\n', Tobii.recInfo );
fclose( fid );
Tobii = tobiiGlassesAPI( Tobii, 'recstart' );

% Block start trigger
tBlock = GetSecs;
wakeup = tBlock;
sendtrigger_tobii( Cfg, Tobii, 254, round( ( wakeup - tBlock ) * 1e6 ) )

SOA = 1;
trialArray = ( 1:10 )';
nTrials = size( trialArray, 1 );

% Trial loop
for iTrial = 1:nTrials

    % Replace by experiment code, for example
    % VBLTimestamp = Screen( 'Flip', ...
    wakeup = WaitSecs( wakeup + SOA - GetSecs );

    % Send TTL and API trigger to eyetracker
    sendtrigger_tobii( Cfg, Tobii, iTrial, round( ( wakeup - tBlock ) * 1e6 ) )

    % Log
    trialArray( iTrial, 2 ) = wakeup - tBlock;
    fprintf( 'Trial: %3d, Time: %7.3f\n', trialArray( iTrial, : ) )

end

% Block end trigger
WaitSecs( 'YieldSecs', 2 );
sendtrigger_tobii( Cfg, Tobii, 255, round( ( GetSecs - tBlock ) * 1e6 ) )

% Stop recording
Tobii = tobiiGlassesAPI( Tobii, 'recstop' );

% Save data
dlmwrite( fullfile( 'log', [ Cfg.filenamebase '.txt' ] ), trialArray, 'delimiter', '\t', 'precision', '%g' );

% Close screen, audio device, serial port, etc.
IOPort( 'CloseAll' );

end
