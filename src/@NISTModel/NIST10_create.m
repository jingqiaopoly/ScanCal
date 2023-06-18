function par = NIST10_create( varargin )
%NIST2_create   Create the TLS parameter structure as of simplified NIST
%
%   par=NIST10_create() creates a TLS calibration parameter strcuture
%   according to the  NIST10 model (doi: 10.3390/rs11131519 ) with all
%   deviations set to 0 (representing a perfectly manufactured scanner).
%
%   par=NIST10_create('xx',value, 'xx', ...) creates the structure with all
%   parameters set to zero, except the ones where the parameter
%   name and value pairs are passed as arguments. 'xx' needs to be replaced
%   by the correct names (see below), and the value needs to be given in
%   the corresponding units (see below).
%
%   par=NIST10_create(p) creates the strcuture with the parameters set
%   to the numeric values given in the nx1 vector p where all parameters of
%   the model are contained, and the sequence corresponds to the sequence 
%   in the table below.
%
%   The output structure has fields with the names of the parameters as
%   of the above publication.
%
%   Parameter units description
%   --------- ----- -------------------
%  01 x10   mm    constant error in range          
%  02 x2    mm    transit offset (horizontal)   
%  03 x1z   mm    beam offset along z
%  04 x3    mm    mirror offset
%  05 x7    rad                                  
%  06 x6    rad   mirror tilt    
%  07 x1n   mm                        
%  08 x4    rad   vertical index offset
%  09 x5n   rad   Horizontal beam tilt          %x5z7  rad   combination of beam tilt along z and transit tilt
%  10 x5z   rad   Vertical beam tilt            % x10   mm    constant error in range   
%
%   See also NIST10_get, NIST10_set, NIST10_fwd, NIST10_bwd


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
    'x10',0,...
    'x2',0,...
    'x1z',0,...
    'x3',0,...
    'x7',0,...
    'x6',0,...
    'x1n',0,...
    'x4',0,...
    'x5n',0,...
    'x5z',0);

% if there are no input arguments, return the all-zero strcuture
if ~nargin
    return;
end

if nargin == 1
    h = varargin{1};
    hh = size(h);
    if ~isnumeric(h) || length(hh)~=2 || min(hh) ~= 1 || max(hh) ~= 10
        error 'Input vector needs to be 10x1 for NIST10 model, or input needs to be sequence of names and values.';
    end
    
    % seems to be ok, so assign the values
    h = h(:);
    par.x10   = h(1);
    par.x2   =  h(2);
    par.x1z    = h(3);
    par.x3    = h(4);
    par.x7    = h(5);
    par.x6 =    h(6);
    par.x1n =   h(7);
    par.x4    = h(8);
    par.x5n   = h(9);
    par.x5z   = h(10);
    
    return;
end
    
if mod(nargin,2)
    error 'Number of input arguments must be even for parameter/value pairs'
end

hh = zeros(10,1);           % flag: value already modified?

for i=1:2:nargin
    
    hs = varargin{i};       % this should be the parameter name
    hv = varargin{i+1};     % this should be the parameter value
    
    if ~ischar(hs) || ~isnumeric(hv) || length(hv)~=1
        error('%i-th and %i-th parameter are not a name/value pair', i, i+1);
    end
    
    switch hs
        case 'x10'
            par.x10   = hv;
            if hh(1)
                warning('Previously assigned value of x10 replaced (multiple assignment in same call to NIST10_create');
            end
            hh(1) = 1;
            
        case 'x2'
            par.x2   = hv;
            if hh(2)
                warning('Previously assigned value of x2 replaced (multiple assignment in same call to NIST10_create');
            end
            hh(2) = 1;
            
        case 'x1z'
            par.x1z    = hv;
            if hh(3)
                warning('Previously assigned value of x1z replaced (multiple assignment in same call to NIST10_create');
            end
            hh(3) = 1;
            
        case 'x3'
            par.x3    = hv;
            if hh(4)
                warning('Previously assigned value of x3 replaced (multiple assignment in same call to NIST10_create');
            end
            hh(4) = 1;
            
        case 'x7'
            par.x7    = hv;
            if hh(5)
                warning('Previously assigned value of x7 replaced (multiple assignment in same call to NIST10_create');
            end
            hh(5) = 1;
            
        case 'x6'
            par.x6 = hv;
            if hh(6)
                warning('Previously assigned value of x6 replaced (multiple assignment in same call to NIST10_create');
            end
            hh(6) = 1;
            
        case 'x1n'
            par.x1n  = hv;
            if hh(7)
                warning('Previously assigned value of x1n replaced (multiple assignment in same call to NIST10_create');
            end
            hh(7) = 1;
            
        case 'x4'
            par.x4 = hv;
            if hh(8)
                warning('Previously assigned value of x4 replaced (multiple assignment in same call to NIST10_create');
            end
            hh(8) = 1;
            
        case 'x5n'
            par.x5n    = hv;
            if hh(9)
                warning('Previously assigned value of x5n replaced (multiple assignment in same call to NIST10_create');
            end
            hh(9) = 1;
            
        case 'x5z'
            par.x10   = hv;
            if hh(10)
                warning('Previously assigned value of x5z replaced (multiple assignment in same call to NIST10_create');
            end
            hh(10) = 1;
    
        otherwise
            error('Parameter ''%s'' not defined for NIST10 model (%i-th input argument)', hs, i);
    
    end
    
end

 