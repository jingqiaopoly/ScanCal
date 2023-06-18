function raw = NIST_bwd( cor, scannerInfo,instr_type )
%ASM_bwd    Scanner backward model polar-to-polar ASM (various)
%
%   R = NIST3_bwd(C, scn) converts the polar coordinates C with respect to 
%   the scanner's own coordinate system (SOCS) into raw encoder/LiDAR unit
%   readings R using the scanner model defined in scn.
%
%   C is a 3xn matrix of polar coordinates (one column per point,  n.GE.1 
%   points; first row = distance from scanner's origin in m; second
%   row = horizontal angle in rad (rotation angle about SOCS z-axis); third
%   row = elevation angle in rad. The horizontal and vertical angles are
%   elements of (-pi, pi]. The hz angle is positive clockwise and hz=0
%   corresponds to the y-axis of the right handed xyz-system with z-axis
%   approx equal to the secondary rotation axis. The el angle is 0 or pi
%   in the horizon, the positive z-axis corresponds approximately to 
%   el = pi/2, the negative one to -pi/2.
%   
%   R is a 3xn matrix of raw scanner readings (one column per point, same 
%   sequence of points as C; first row containing distance (LiDAR unit 
%   output) in m; second row hz-encoder reading in rad (rotation angle 
%   about secondary rotation axis); third row containing el-encoder 
%   reading in rad (rotation angle about primary rotation axis). The 
%   face of the output data is the same as the face of the input data. 
%   The definition of the angles is like above.
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
%   See also ASM_fwd, NIST2_bwd, NIST2_fwd, NIST2_create. 

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% CREATED: aw, 1.4.2019
% MODIFIED:
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% (1) check input arguments
if nargin < 2                           % no default inputs, all 2 needed
    error 'Too few input arguments';
end
hh = size(cor);                         % check type and dimension of cor
if ~isnumeric(cor) || length(hh) ~= 2 || hh(1) ~= 3 
    error 'First input argument must be 3xn numeric matrix';
end
% instrument type
if nargin < 3
  instr_type = 'NIST2'; %by default
end

% assumed serial numbers of reference and test instrument
instr_serno = 9999;
% the scanner structure and dispatch according to the scanner type
switch instr_type
    case 'NIST2'
        scn = struct( ...
            'type', instr_type, ...
            'serno', instr_serno, ...
            'par', NISTModel.NIST2_create(scannerInfo) ...
            );
        raw = NISTModel.NIST2_bwd_s(cor,scn.par);
    case 'NIST3'
        % the scanner structure
        scn = struct( ...
            'type', instr_type, ...
            'serno', instr_serno, ...
            'par', NISTModel.NIST3_create(scannerInfo) ...
            );
        raw = NISTModel.NIST3_bwd_s(cor,scn.par);
    case 'NIST8'
        % the scanner structure
        scn = struct( ...
            'type', instr_type, ...
            'serno', instr_serno, ...
            'par', NISTModel.NIST8_create(scannerInfo) ...
            );
        raw = NISTModel.NIST8_bwd_s(cor,scn.par, ProjectSettings.instance.selfCal.y_axis);
    otherwise
        error('Not yet implemented for scanner of type ''%s''.', instr_type);
end

end
