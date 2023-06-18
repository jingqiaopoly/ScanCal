function cor = Lichti_fwd_s( raw, par )
%Lichti_fwd_s    Scanner forward model 
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% CREATED: jing, 11.6.2021
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
if ~isstruct(par) || ~isfield(par,'a0')    % for speed we only check 1 field
    error 'Second input must be a structure as created using Lichti_create';
end

U1 = 1.2*1000;
U2 = 9.6*1000;
% -------------------------------------------------------------------------
% (2) convert the readings to polar coordinates according to the NIST
% definition (different from the one chosen for the inputs here) and
% determine auxiliary quantities
                            
Rm     = raw(1,:)*1e3;                % extract slant range and 
                                      % convert to mm

                                                                             
                                      
% hh     = mod((pi/2-raw(2:3,:))+pi,2*pi)-pi; % extract hz and el angles 
   hh =  raw(2:3,:);                 % replace by pi/2-angle and make
                                      % sure the results are in (-pi,pi]
 
%  face2_raw = (hh(2,:) < 0);            % which raw points are in face 2?
%                                        % (not checking for EL>pi because
%                                        % of the previous mapping to (-pi,pi]
%  iface2 = find(face2_raw);             % indices of face 2 values                                        
                                       
 HVm = hh;                             % compose Hm, Vm taking into account
 % Transform the Faro el to that defined by Lichti
 face1_raw = find(hh(2,:)< pi);
 face2_raw = find(hh(2,:)> pi); 
 HVm(2,face1_raw) = pi/2 - HVm(2,face1_raw);
 HVm(2,face2_raw) = pi*2 - HVm(2,face2_raw)+ pi/2;
 
 
 
% if ~isempty(iface2)                   %   that they are to be equivalent face 1 values
%     HVm(1,iface2) = ...
%         mod(HVm(1,iface2), 2*pi)-pi;  % mod( H+pi,2pi) and then mapped to (-pi,pi]
%     HVm(2,iface2) = ...
%         mod(pi-HVm(2,iface2),2*pi)-pi;  % mad( 2pi - V, 2pi) and then mapped to (-pi,pi]
% end                                      

sinV = sin(HVm(2,:));              % sin, cos, tan of angles
cosV = cos(HVm(2,:));
tanV = sinV./cosV;
% sin2V = sin(2*HVm(2,:));
% cos2V = cos(2*HVm(2,:));
cos3V = cos(3*HVm(2,:));
sin4V = sin(4*HVm(2,:));
tan4V = tan(4*HVm(2,:));


% sinH = sin(HVm(1,:));
% cosH = cos(HVm(1,:));
sin2H = sin(2*HVm(1,:));
cos2H = cos(2*HVm(1,:));
sin4H = sin(4*HVm(1,:));
cos4H = cos(4*HVm(1,:));
sin3H = sin(3*HVm(1,:));
cos3H = cos(3*HVm(1,:));






% (3) apply forward model according to eqs. (2), (3), (4) from (doi: 10.3390/rs11131519 )

% k = 1 - 2*(face2_raw==1);               % +1 for face 1, -1 for face 2

%  for range
dR =  par.a0 + par.a1*Rm + par.a2*sinV+ par.a3*sin(4*pi/U1.*Rm)...
    + par.a4*cos(4*pi/U1.*Rm) + par.a5*sin(4*pi/U2.*Rm)...
    + par.a6*cos(4*pi/U2.*Rm) + par.a7*sin4H+ par.a8*cos4H;

%  for hz angle
dH =  par.b1.*sec(HVm(2,:)) + par.b2.*tanV + par.b3.*sin2H ...
     +par.b4.*cos2H + par.b5.*HVm(1,:)+ par.b6.*cos3V + par.b7.*sin4V;
     
%  for v angle
dV =  par.c0 + par.c1.*HVm(2,:)+ par.c2.*sinV + par.c3.*sin3H + par.c4.*cos3H;




% corrected polar coordinates
Rc = Rm + dR;
HVc= HVm + [dH;dV];

% compose output result, converting the angles back to the
% original definition

HVc(2,face1_raw) = pi/2 - HVc(2,face1_raw);
HVc(2,face2_raw) = pi*2 - HVc(2,face2_raw)+ pi/2;
 
hh = HVc;
% if ~isempty(iface2)     % bring face 2 points back to face 2 values
%     hh(1,iface2) = mod( hh(1,iface2),2*pi )-pi;
%     hh(2,iface2) = mod( pi-hh(2,iface2), 2*pi) - pi;
% end

% cor = [Rc*1e-3; ...                          % distance, conv back to m
%        mod(pi/2-hh+pi,2*pi)-pi;              % angles: change direction and reference axis
%        ];
cor = [Rc*1e-3; ...                          % distance, conv back to m
       hh;              % angles: change direction and reference axis
       ];
