function cor = NIST8_fwd_s( raw, par,y_axis )
%NIST8_fwd_s_inuseY    Scanner forward model polar-to-polar NIST simplified
%
%   C = NIST8_fwd_s(R, par) converts the raw encoder/LiDAR unit readings
%   R to corrected polar coordinates C with respect to the scanner's
%   own coordinate system (SOCS) using the NIST8 scanner model par.
%
%   R is a 3xn matrix (one column per point, n points; first row
%   containing distance (LiDAR unit output) in m; second row hz-encoder
%   reading in rad (rotation angle about secondary rotation axis); third
%   row containing el-encoder reading in rad (rotation angle about primary
%   rotation axis). The hz encoder readings are positive clockwise and hz=0
%   corresponds to the y-axis of the right handed xyz-system with z-axis
%   approx equal to the secondary rotation axis. The el-encoder readings
%   are 0 or pi in the horizon, the positive z-axis corresponds
%   approximately to el = pi/2, the negative one to -pi/2. (The conversion
%   to the angles as of the NIST model is carried out internally within
%   this function.)
%
%   C is a corresponding 3xn matrix (one column per point, same sequence of
%   points as R; first row = distance from scanner's origin in m; second
%   row = horizontal angle in rad (rotation angle about SOCS z-axis); third
%   row = elevation angle in rad. The horizontal and vertical angles are
%   elements of (-pi, pi]. The face of the output data is the same as the
%   face of the input data. The definition of the angles is as above.
%
%   par is a structure of NIST8 model parameters as created using NIST8_create
%
%   See also NIST8_create, NIST8_get, NIST8_set, NIST8_bwd


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
if ~isstruct(par) || ~isfield(par,'x1z')    % for speed we only check 1 field
    error 'Second input must be a structure as created using NIST8_create';
end



% -------------------------------------------------------------------------
% (2) convert the readings to polar coordinates according to the NIST
% definition (different from the one chosen for the inputs here) and
% determine auxiliary quantities
                            
Rm     = raw(1,:)*1e3;                % extract slant range and 
                                      % convert to mm
% Jing: leaving hz starting from y axis                                        
% hh     = mod((pi/2-raw(2:3,:))+pi,2*pi)-pi; % extract hz and el angles 
%                                       % replace by pi/2-angle and make
%                                       % sure the results are in (-pi,pi]
hh =  raw(2:3,:);
if y_axis
    % in use
    hh(1,:) = mod(hh(1,:)+2*pi, 2*pi);
    hh(2,:)= mod((pi/2-hh(2,:))+pi,2*pi)-pi; % extract el angles 
    %                                          % replace by pi/2-angle and make
    %                                          % sure the results are in (-pi,pi]
end



% face2_raw = (hh(2,:) < 0);            % which raw points are in face 2?
%                                       % (not checking for EL>pi because
%                                       % of the previous mapping to (-pi,pi]
% iface2 = find(face2_raw);             % indices of face 2 values                                        
%                                       
 HVm = hh;                             % compose Hm, Vm taking into account
% if ~isempty(iface2)                   %   that they are to be equivalent face 1 values
%     HVm(1,iface2) = ...
%         mod(HVm(1,iface2), 2*pi)-pi;  % mod( H+pi,2pi) and then mapped to (-pi,pi]
%     HVm(2,iface2) = ...
%         mod(pi-HVm(2,iface2),2*pi)-pi;  % mad( 2pi - V, 2pi) and then mapped to (-pi,pi]
% end                                      
% 
% sinV = sin(HVm(2,:));              % sin, cos, tan of angles
% cosV = cos(HVm(2,:));
% tanV = sinV./cosV;
% sinH = sin(HVm(1,:));
% cosH = cos(HVm(1,:));
sinV = sin(hh(2,:));              % sin, cos, tan of angles
cosV = cos(hh(2,:));
tanV = sinV./cosV;
sinH = sin(hh(1,:));
cosH = cos(hh(1,:));

% (3) apply forward model according to eqs. (2), (3), (4) from (doi: 10.3390/rs11131519 )

% k = 1 - 2*(face2_raw==1);               % +1 for face 1, -1 for face 2

%  for range
dR = (par.x2*sinV) ;

%  for hz angle
dH =  ( ...
        par.x1z./(Rm.*tanV) + ...
        par.x3./(Rm.*sinV) + ...
        par.x5z7./tanV + ...
        2*par.x6./sinV ) ;
     
     
%  for v angle
dV = ( ...
        par.x1n2*cosV./Rm + ...
        par.x4 + ...
        par.x5n*cosV );
         
% corrected polar coordinates
Rc = Rm + dR;
HVc= HVm + [dH;dV];

% compose output result, converting the angles back to the
% original definition

hh = HVc;
% if ~isempty(iface2)     % bring face 2 points back to face 2 values
%     hh(1,iface2) = mod( hh(1,iface2),2*pi )-pi;
%     hh(2,iface2) = mod( pi-hh(2,iface2), 2*pi) - pi;
% end

% Jing: leaving hz starting from y axis   
% cor = [Rc*1e-3; ...                          % distance, conv back to m
%        mod(pi/2-hh+pi,2*pi)-pi;              % angles: change direction and reference axis
%        ];

% % in use
if y_axis
    cor = [Rc*1e-3; ...                          % distance, conv back to m
           mod(hh(1,:)+pi,2*pi)-pi;
           mod(pi/2-hh(2,:)+pi,2*pi)-pi;              % angles: change direction and reference axis
           ];
else
    cor = [Rc*1e-3; ...                          % distance, conv back to m
       hh;              % angles: change direction and reference axis
       ];
end


