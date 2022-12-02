function demo_exp( subj )
% demo_exp - Wrapper script for Tobii Glasses 2 API demo experiment
% Copyright (c) 2022 Andreas Widmann
% Author: Andreas Widmann, widmann@uni-leipzig.de

if nargin < 1 || isempty( subj )
    % error( 'Not enough input arguments.' )
    subj = 99;
end

% Init Tobii Glasses
Tobii = tobiiGlassesAPI();
Tobii.projID = 'jkge422'; % Do not delete dir from SD card

% Retrieve Tobii participant ID from log file or get new Tobii participant ID
if exist( fullfile( 'log', sprintf( '%02d_subjinfo.txt', subj ) ), 'file' )
    Tobii.subjID = regexp( fileread( fullfile( 'log', sprintf( '%02d_subjinfo.txt', subj ) ) ), '(?<="pa_id":").*?(?=")', 'match', 'once' );
else
    Tobii = tobiiGlassesAPI( Tobii, 'subject', 'name', sprintf( '%02d', subj ) );
    fid = fopen( fullfile( 'log', sprintf( '%02d_subjinfo.txt', subj ) ), 'w' );
    fprintf( fid, '%s\n', Tobii.subjInfo );
    fclose( fid );
end

Cfg.initioport = 1;
Cfg.filenamebase = sprintf( '%02d_demo', subj );
Cfg.subj = subj;

demo_block( Cfg, Tobii )

end
