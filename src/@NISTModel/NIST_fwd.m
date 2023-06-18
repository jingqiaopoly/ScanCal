function cor = NIST_fwd( raw, scannerInfo,instr_type )
%ASM_fwd    Scanner forward model polar-to-polar ASM (various)
%
%   C = NIST3_fwd(R, scn) converts the raw encoder/LiDAR unit readings
%   R to corrected polar coordinates C with respect to the scanner's
%   own coordinate system (SOCS) using the scanner model defined in scn.
%
%   R is a 3xn matrix (one column per point, n.ge.1 points; first row
%   containing distance (LiDAR unit output) in m; second row hz-encoder
%   reading in rad (rotation angle about secondary rotation axis); third
%   row containing el-encoder reading in rad (rotation angle about primary
%   rotation axis). The hz encoder readings are positive clockwise and hz=0
%   corresponds to the y-axis of the right handed xyz-system with z-axis
%   approx equal to the secondary rotation axis. The el-encoder readings
%   are 0 or pi in the horizon, the positive z-axis corresponds
%   approximately to el = pi/2, the negative one to -pi/2.
%
%   C is a corresponding 3xn matrix (one column per point, same sequence of
%   points as R; first row = distance from scanner's origin in m; second
%   row = horizontal angle in rad (rotation angle about SOCS z-axis); third
%   row = elevation angle in rad. The horizontal and vertical angles are
%   elements of (-pi, pi]. The face of the output data is the same as the
%   face of the input data. The definition of the angles is like above.
%
%   scn is a structure of scanner definition parameters with the following
%   fields:
%      type    scanner type (characters, defining the calibration model)
%              currently the following are available: 
%              'NIST2' for simplified NIST model (Muralikrishnan) 
%                      according to Wang et al 2017
%      serno   scanner serial number
%      par     scanner calibration parameters (struct depending on
%              the scanner type, and created using nnn_create, where
%              nnn is the scanner type (see those functions for further
%              details)
%
%   See also NIST2_create, NIST2_fwd


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% CREATED: aw, 1.4.2019
% MODIFIED:
% -------------------------------------------------------------------------
% Open questions / issues
%
%  1) tbd.
%                
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% (1) check input arguments
if nargin < 2                           % no default inputs, all 2 needed
    error 'Too few input arguments';
end
hh = size(raw);                         % check type and dimension of raw
if ~isnumeric(raw) || length(hh) ~= 2 || hh(1) ~= 3 
    error 'First input argument must be 3xn numeric matrix';
end

% instrument type
if nargin < 3
  instr_type = 'NIST2'; %by default
end

% assumed serial numbers of reference and test instrument
instr_serno = 9999;



% dispatch according to the scanner type
switch instr_type
    case 'NIST2'
        % the scanner structure
        scn = struct( ...
            'type', instr_type, ...
            'serno', instr_serno, ...
            'par', NISTModel.NIST2_create( scannerInfo) ...
            );
        cor = NISTModel.NIST2_fwd_s(raw,scn.par);
    case 'NIST3'
        % the scanner structure
        scn = struct( ...
            'type', instr_type, ...
            'serno', instr_serno, ...
            'par', NISTModel.NIST3_create( scannerInfo) ...
            );
        cor = NISTModel.NIST3_fwd_s(raw,scn.par);
    case 'NIST8'
        % the scanner structure
        scn = struct( ...
            'type', instr_type, ...
            'serno', instr_serno, ...
            'par', NISTModel.NIST8_create( scannerInfo) ...
            );
        cor = NISTModel.NIST8_fwd_s(raw,scn.par, ProjectSettings.instance.selfCal.y_axis);   
    case 'NIST9'
        % the scanner structure
        scn = struct( ...
            'type', instr_type, ...
            'serno', instr_serno, ...
            'par', NISTModel.NIST9_create( scannerInfo) ...
            );
        cor = NISTModel.NIST9_fwd_s(raw,scn.par, ProjectSettings.instance.selfCal.y_axis);   
    case 'NIST10'
        % the scanner structure
        scn = struct( ...
            'type', instr_type, ...
            'serno', instr_serno, ...
            'par', NISTModel.NIST10_create( scannerInfo) ...
            );
        cor = NISTModel.NIST10_fwd_s(raw,scn.par, ProjectSettings.instance.selfCal.y_axis); 
    case 'Lichti'
        % the scanner structure
        scn = struct( ...
            'type', instr_type, ...
            'serno', instr_serno, ...
            'par', NISTModel.Lichti_create( scannerInfo) ...
            );
        cor = NISTModel.Lichti_fwd_s(raw,scn.par); 
        
        
    otherwise
        error('Not yet implemented for scanner of type ''%s''.', scn.type);
        
end
