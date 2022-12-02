function [ Tobii ] = tobiiGlassesAPI( Tobii, call, varargin )
% tobiiGlassesAPI - Tobii Glasses 2 REST API functions
% Copyright (c) 2022 Andreas Widmann, University of Leipzig
% Author: Andreas Widmann, widmann@uni-leipzig.de

% TODO:
%   * One line status reports
%   * Documentation

status = [];

if nargin < 1 || ~isfield( Tobii, 'URL' ) || isempty( Tobii.URL )
    Tobii.URL = 'http://192.168.71.50';
end

if ~isfield( Tobii, 'curlOptions' ) || isempty( Tobii.curlOptions )
    Tobii.curlOptions = 'curl -s -H "Content-Type: application/json" ';   
end

if nargin < 2 || isempty( call )
    'No call argument. Returning status.'
    call = 'status';
end

Arg = struct( varargin{ : } );

switch call
    case 'status'
        % Get system status
        [ status, Tobii.statusInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/system/status/' ] );

    case 'project'
        % Create new project
        [ status, Tobii.projInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/projects/' ' -d ""' ] );
        Tobii.projID = regexp( Tobii.projInfo, '(?<="pr_id":").*?(?=")', 'match', 'once' );

        % Update project name
        if isfield( Arg, 'name' ) && ~isempty( Arg.name )
            postData = [ '{"pr_info":{"name":"' Arg.name '"}}' ];
            [ status, Tobii.projInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/projects/' Tobii.projID ' -d ''' postData '''' ] );
        end

    case 'subject'    
        % Create new subject
        if ~isfield( Tobii, 'projID' ) || isempty( Tobii.projID )
            error( 'Tobii projID field required. Create new project first.' )
        end
        postData = [ '{"pa_project":"' Tobii.projID '"}' ];
        [ status, Tobii.subjInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/participants/' ' -d ''' postData '''' ] );
        Tobii.subjID = regexp( Tobii.subjInfo, '(?<="pa_id":").*?(?=")', 'match', 'once' );

        % Update subj name
        if isfield( Arg, 'name' ) && ~isempty( Arg.name )
            postData = [ '{"pa_info":{"name":"' Arg.name '"}}' ];
            [ status, Tobii.subjInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/participants/' Tobii.subjID ' -d ''' postData '''' ] );
        end

    case 'calibration'
        % Calibrate
        if ~isfield( Tobii, 'subjID' ) || isempty( Tobii.subjID )
            error( 'Tobii subjID field required. Create new subject first.' )
        end

        postData = [ '{"ca_participant":"' Tobii.subjID '","ca_type":"default"}' ];
        [ status, Tobii.calInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/calibrations/' ' -d ''' postData '''' ] );
        Tobii.calID = regexp( Tobii.calInfo, '(?<="ca_id":").*?(?=")', 'match', 'once' );
        [ status, Tobii.calInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/calibrations/' Tobii.calID '/start/' ' -d ""' ] );
        Tobii.calState = regexp( Tobii.calInfo, '(?<="ca_state":").*?(?=")', 'match', 'once' );

        fprintf( 'Calibrating ' );
        while strcmp( Tobii.calState, 'calibrating' )
            fprintf( '.' );
            [ status, Tobii.calInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/calibrations/' Tobii.calID '/status/' ] );
            Tobii.calState = regexp( Tobii.calInfo, '(?<="ca_state":").*?(?=")', 'match', 'once' );
            WaitSecs( 'YieldSecs', 0.1 );
        end
        fprintf( ' %s\n', Tobii.calState);

    case 'recording'
        % Create new recording
        if ~isfield( Tobii, 'subjID' ) || isempty( Tobii.subjID )
            error( 'Tobii subjID field required. Create new subject first.' )
        end
        if ~isfield( Arg, 'name' ) || isempty( Arg.name )
            error( 'Name argument required.' )
        end

        postData = [ '{"rec_participant":"' Tobii.subjID '","rec_info":{"name":"' Arg.name '"}}' ];
        [ status, Tobii.recInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/recordings/' ' -d ''' postData '''' ] );
        Tobii.recID = regexp( Tobii.recInfo, '(?<="rec_id":").*?(?=")', 'match', 'once' );
        Tobii.recState = regexp( Tobii.recInfo, '(?<="rec_state":").*?(?=")', 'match', 'once' );

    case 'recstart'
        % Start recording
        if ~isfield( Tobii, 'recID' ) || isempty( Tobii.recID )
            error( 'Tobii recID field required. Create new recording first.' )
        end

        [ status, Tobii.recInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/recordings/' Tobii.recID '/start/' ' -d ""' ] );
        Tobii.recState = regexp( Tobii.recInfo, '(?<="rec_state":").*?(?=")', 'match', 'once' );

    case 'recstop'
        % Stop recording
        if ~isfield( Tobii, 'recID' ) || isempty( Tobii.recID )
            % Update status info
            [ status, Tobii.statusInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/system/status/' ] );
            Tobii.recID = regexp( Tobii.statusInfo, '(?<="rec_id":").*?(?=")', 'match', 'once' );
        end

        [ status, Tobii.recInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/recordings/' Tobii.recID '/stop/' ' -d ""' ] );
        Tobii.recState = regexp( Tobii.recInfo, '(?<="rec_state":").*?(?=")', 'match', 'once' );

    case 'recstatus'
        % Get recording status
        if ~isfield( Tobii, 'recID' ) || isempty( Tobii.recID )
            error( 'Tobii recID field required. Create new recording first.' )
        end

        [ status, Tobii.recInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/recordings/' Tobii.recID '/status/' ] );
        Tobii.recState = regexp( Tobii.recInfo, '(?<="rec_state":").*?(?=")', 'match', 'once' );

    case 'recpause'
        % Pause recording
        if ~isfield( Tobii, 'recID' ) || isempty( Tobii.recID )
            error( 'Tobii recID field required. Create new recording first.' )
        end

        [ status, Tobii.recInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/recordings/' Tobii.recID '/pause/'  ' -d ""' ] );
        Tobii.recState = regexp( Tobii.recInfo, '(?<="rec_state":").*?(?=")', 'match', 'once' );

    case 'evtapi'
        % Send API event
        if ~isfield( Arg, 'type' ) || isempty( Arg.type ) || ~ischar( Arg.type )
            error( 'Type char argument required.' )
        end
        if ~isfield( Arg, 'ets' ) || isempty( Arg.type ) || ~isnumeric( Arg.ets )
            error( 'ets numeric argument required.' )
        end

        postData = [ '{"ets":' num2str( Arg.ets ) ',"type":"' Arg.type '"}' ];
        [ status, Tobii.evtInfo ] = system( [ Tobii.curlOptions Tobii.URL '/api/events/' ' -d ''' postData '''' ] );

    case 'evtport'
        % Send port event
        if ~isfield( Arg, 'porthandle' ) || isempty( Arg.porthandle )
            error( 'Porthandle argument required.' )
        end

        [ nwritten, Tobii.evtportwhen, errmsg ] = IOPort('Write', Arg.porthandle, uint8( 255 ) );

otherwise
        error( 'Unknown function call' )
        
end

if status ~= 0
    error( 'Tobii Glasses not connected.' )
end

end
