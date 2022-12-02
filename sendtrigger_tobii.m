function sendtrigger_tobii( Cfg, Tobii, val, ets )
% Trigger device function for Tobii Glasses 2
% Copyright (c) 2022 Andreas Widmann, University of Leipzig
% Author: Andreas Widmann, widmann@uni-leipzig.de

if isfield( Cfg, 'initioport' ) && Cfg.initioport
    Tobii = tobiiGlassesAPI( Tobii, 'evtport', 'porthandle', Cfg.porthandle );
end
Tobii = tobiiGlassesAPI( Tobii, 'evtapi', 'type', num2str( val ), 'ets', ets );

end

