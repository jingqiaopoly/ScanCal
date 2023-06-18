function par = NIST3_create( varargin )
%NIST2_create   Create the TLS parameter structure as of simplified NIST
%
%   par=NIST3_create() creates a TLS calibration parameter strcuture
%   according to the  NIST3 model (doi: 10.3390/rs11131519 ) with all
%   deviations set to 0 (representing a perfectly manufactured scanner).
%
%   par=NIST3_create('xx',value, 'xx', ...) creates the structure with all
%   parameters set to zero, except the ones where the parameter
%   name and value pairs are passed as arguments. 'xx' needs to be replaced
%   by the correct names (see below), and the value needs to be given in
%   the corresponding units (see below).
%
%   par=NIST3_create(p) creates the strcuture with the parameters set
%   to the numeric values given in the nx1 vector p where all parameters of
%   the model are contained, and the sequence corresponds to the sequence 
%   in the table below.
%
%   The output structure has fields with the names of the parameters as
%   of the above publication.
%
%   Parameter units description
%   --------- ----- -------------------
%  01 x1n   mm    beam offset along n  
%  02 x1z   mm    beam offset along z
%  03 x2    mm    transit offset (horizontal)
%  04 x3    mm    mirror offset
%  05 x4    rad   vertical index offset
%  06 x5n   rad   Horizontal beam tilt 
%  07 x5z   rad   Vertical beam tilt
%  08 x6    rad   mirror tilt
%  09 x5z7  rad   combination of beam tilt along z and transit tilt
%  10 x10   mm    constant error in range  
%  11 x1n2  mm    Horizontal Beam and Horizontal Axis Offsets  
%
%   See also NIST3_get, NIST3_set, NIST3_fwd, NIST3_bwd


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


% initialize return structure
par = struct( ...
    'x1n',0,...
    'x1z',0,...
    'x2',0,...
    'x3',0,...
    'x4',0,...
    'x5n',0,...
    'x5z',0,...
    'x6',0,...
    'x5z7',0,...
    'x10',0,...
    'x1n2',0);

% if there are no input arguments, return the all-zero strcuture
if ~nargin
    return;
end

if nargin == 1
    h = varargin{1};
    hh = size(h);
    if ~isnumeric(h) || length(hh)~=2 || min(hh) ~= 1 || max(hh) ~= 11
        error 'Input vector needs to be 11x1 for NIST3 model, or input needs to be sequence of names and values.';
    end
    
    % seems to be ok, so assign the values
    h = h(:);
    par.x1n   = h(1);
    par.x1z   = h(2);
    par.x2    = h(3);
    par.x3    = h(4);
    par.x4    = h(5);
    par.x5n = h(6);
    par.x5z = h(7);
    par.x6    = h(8);
    par.x5z7   = h(9);
    par.x10   = h(10);
    par.x1n2  = h(11);
    
    return;
end
    
if mod(nargin,2)
    error 'Number of input arguments must be even for parameter/value pairs'
end

hh = zeros(11,1);           % flag: value already modified?

for i=1:2:nargin
    
    hs = varargin{i};       % this should be the parameter name
    hv = varargin{i+1};     % this should be the parameter value
    
    if ~ischar(hs) || ~isnumeric(hv) || length(hv)~=1
        error('%i-th and %i-th parameter are not a name/value pair', i, i+1);
    end
    
    switch hs
        case 'x1n'
            par.x1n   = hv;
            if hh(1)
                warning('Previously assigned value of x1n replaced (multiple assignment in same call to NIST3_create');
            end
            hh(1) = 1;
            
        case 'x1z'
            par.x1z   = hv;
            if hh(2)
                warning('Previously assigned value of x1z replaced (multiple assignment in same call to NIST3_create');
            end
            hh(2) = 1;
            
        case 'x2'
            par.x2    = hv;
            if hh(3)
                warning('Previously assigned value of x2 replaced (multiple assignment in same call to NIST3_create');
            end
            hh(3) = 1;
            
        case 'x3'
            par.x3    = hv;
            if hh(4)
                warning('Previously assigned value of x3 replaced (multiple assignment in same call to NIST3_create');
            end
            hh(4) = 1;
            
        case 'x4'
            par.x4    = hv;
            if hh(5)
                warning('Previously assigned value of x4 replaced (multiple assignment in same call to NIST3_create');
            end
            hh(5) = 1;
            
        case 'x5n'
            par.x5n = hv;
            if hh(6)
                warning('Previously assigned value of x5n9n replaced (multiple assignment in same call to NIST3_create');
            end
            hh(6) = 1;
            
        case 'x5z'
            par.x5z  = hv;
            if hh(7)
                warning('Previously assigned value of x5z7 replaced (multiple assignment in same call to NIST3_create');
            end
            hh(7) = 1;
            
        case 'x6'
            par.x6 = hv;
            if hh(8)
                warning('Previously assigned value of x5z9z replaced (multiple assignment in same call to NIST3_create');
            end
            hh(8) = 1;
            
        case 'x5z7'
            par.x5z7    = hv;
            if hh(9)
                warning('Previously assigned value of x6 replaced (multiple assignment in same call to NIST3_create');
            end
            hh(9) = 1;
            
        case 'x10'
            par.x10   = hv;
            if hh(10)
                warning('Previously assigned value of x8x replaced (multiple assignment in same call to NIST3_create');
            end
            hh(10) = 1;
            
        case 'x1n2'
            par.x1n2   = hv;
            if hh(11)
                warning('Previously assigned value of x1n2 replaced (multiple assignment in same call to NIST3_create');
            end
            hh(11) = 1;
    
        otherwise
            error('Parameter ''%s'' not defined for NIST3 model (%i-th input argument)', hs, i);
    
    end
    
end

 