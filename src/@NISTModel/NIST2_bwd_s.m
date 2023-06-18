function raw = NIST2_bwd_s( cor, par )
%NIST2_bwd    Scanner backward model polar-to-polar NIST simplified
%
%   R = NIST2_bwd(C, par) converts the polar coordinates C with respect 
%   to the scanner's own coordinate system (SOCS) into raw encoder/LiDAR 
%   unit readings R using the NIST2 scanner model par. The function is
%   the inverse of NIST2_fwd such that 
%                   raw = NIST2_bwd(NIST2_fwd(raw,par),par)
%   and
%                   cor = NIST2_fwd(NIST2_bwd(cor,par),par)
%   except for the impact of roundoff errors.
%
%   C is a 3xn matrix of polar coordinates (one column per point,  n 
%   points; first row = distance from scanner's origin in m; second
%   row = horizontal angle in rad (rotation angle about SOCS z-axis); third
%   row = elevation angle in rad. The horizontal and vertical angles are
%   elements of (-pi, pi]. The hz angle is positive clockwise and hz=0
%   corresponds to the y-axis of the right handed xyz-system with z-axis
%   approx equal to the secondary rotation axis. The el angle is 0 or pi
%   in the horizon, the positive z-axis corresponds approximately to 
%   el = pi/2, the negative one to -pi/2. (The conversion
%   to the angles as of the NIST model is carried out internally within
%   this function.)
%   
%   R is a 3xn matrix of raw scanner readings (one column per point, same 
%   sequence of points as C; first row containing distance (LiDAR unit 
%   output) in m; second row hz-encoder reading in rad (rotation angle 
%   about secondary rotation axis); third row containing el-encoder 
%   reading in rad (rotation angle about primary rotation axis). The 
%   face of the output data is the same as the face of the input data. 
%   The definition of the angles is like above.
%
%   par is a structure of NIST2 model parameters as created by
%   NIST2_create.
%
%   See also NIST2_create, NIST2_fwd


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% CREATED: aw, 2.4.2019
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
hh = size(cor);                         % check type and dimension of cor
if ~isnumeric(cor) || length(hh) ~= 2 || hh(1) ~= 3 
    error 'First input argument must be 3xn numeric matrix';
end
if ~isstruct(par) || ~isfield(par,'x1n')    % for speed we only check 1 field
    error 'Second input must be a structure as created using NIST2_create';
end



% -------------------------------------------------------------------------
% (2) convert the polar coordinates to polar coordinates according to the 
% NIST definition (different from the one chosen for the inputs here) and
% determine auxiliary quantities
                            
R      = cor(1,:)*1e3;                % extract slant range and 
                                      % convert to mm
                                        
hh     = mod((pi/2-cor(2:3,:))+pi,2*pi)-pi; % extract hz and el angles 
                                      % replace by pi/2-angle and make
                                      % sure the results are in (-pi,pi]

face2_cor = (hh(2,:) < 0);            % which raw points are in face 2?
                                      % (not checking for >pi because
                                      % of the previous mapping to (-pi,pi]
iface2 = find(face2_cor);             % indices of face 2 values                                        
                                      
HV = hh;                              % compose H, V taking into account
if ~isempty(iface2)                   %   that they are to be equivalent face 1 values
    HV(1,iface2) = ...
        mod(HV(1,iface2), 2*pi)-pi;   % mod( H+pi,2pi) and then mapped to (-pi,pi]
    HV(2,iface2) = ...
        mod(pi-HV(2,iface2),2*pi)-pi; % mod( 2pi - V, 2pi) and then mapped to (-pi,pi]
end                                      

k = 1 - 2*(face2_cor==1);             % indicator: +1 for face 1, -1 for face 2

maxit = 100;                          % maximum number of iterations
npts  = length(R);                    % number of points

dR_trhesh = 1e-6;                     % threshold for range back calculation  
dHV_thresh = 1e-8;                    % threshold for vertical angle back calculation  

% -------------------------------------------------------------------------
% (3) iteratively calculate Rm, HVm such that R = Rm + dRm, HV = HVm + dHVm

Rm = R;                               % initialize with given values  
HVm= HV;

dRm = zeros(1,npts);
dHm = dRm;
dVm = dRm;


iupd = 1:npts;                        % which points still need update?  
                                      % initially: all 
                                      
iok = 0;                              % are we done? 

for iit=1:maxit
    
    % calculate auxiliary quantities sin, cos, tan of angles for the
    % points still to be processed
    Rmu = Rm(iupd);         % extract the coords of the needed points
    HVmu = HVm(:,iupd);
    
    sinVmu = sin(HVmu(2,:));              
    cosVmu = cos(HVmu(2,:));
    tanVmu = sinVmu./cosVmu;
    sinHmu = sin(HVmu(1,:));
    cosHmu = cos(HVmu(1,:));
    

    % apply eqs. (4), (7), (8) from Wang et al 2017, Meas Sci Techn 28
    dRmu = k .* (par.x2 * sinVmu) + par.x10 ;
    
    dHmu = k .* ( par.x1z ./ (Rmu .* tanVmu) ...
                + par.x3  ./ (Rmu .* sinVmu) ...
                + par.x5z7 ./ tanVmu ...
                + 2*par.x6 ./ sinVmu ...
                - par.x8x * sinHmu ...
                + par.x8y * cosHmu ) + ...
               (  par.x1n ./ Rmu ...
                + par.x11a * cos(2*HVmu(1,:)) ...
                + par.x11b * sin(2*HVmu(1,:)));

    dVmu = k .* ( par.x1n * cosVmu ./ Rmu ...
                + par.x2 * cosVmu ./ Rmu  ...
                + par.x4 ...
                + par.x5n9n * cosVmu ) + ...
               (- par.x1z * sinVmu ./ Rmu ...
                - par.x5z9z * sinVmu ...
                + par.x12a * cos(2*HVmu(2,:)) ...
                + par.x12b * sin(2*HVmu(2,:)));
    
    % update Rm, HVm
    Rm(iupd) = R(iupd) - dRmu;
    HVm(1,iupd) = HV(1,iupd) - dHmu;
    HVm(2,iupd) = HV(2,iupd) - dVmu;
    
    % check whether we need to continue and prepare for next iteration
    hi = find( abs(dRm(iupd)-dRmu)>dR_trhesh | ...
        abs(dHm(iupd)-dHmu)>dHV_thresh | ...
        abs(dVm(iupd)-dVmu)>dHV_thresh );
    
    dRm(iupd) = dRmu;
    dHm(iupd) = dHmu;
    dVm(iupd) = dVmu;
    
    if isempty(hi)
        iok = 1;
        % disp(sprintf('%i iterations',iit)); % uncomment only for testing
        break;
    end
    
end

if ~iok
    warning( 'Terminated by reaching maximum iteration count. Results can be inaccurate for %i out of %i points', ...
        length(iupd),npts);
end



% compose output result, converting the angles back to the
% original definition
hh = HVm;
if ~isempty(iface2)     % bring face 2 points back to face 2 values
    hh(1,iface2) = mod( hh(1,iface2),2*pi )-pi;
    hh(2,iface2) = mod( pi-hh(2,iface2), 2*pi) - pi;
end

raw = [Rm*1e-3; ...                          % distance, conv back to m
       mod(pi/2-hh+pi,2*pi)-pi;              % angles: change direction and reference axis
       ];
