function par = Lichti_create( varargin )
%Lichti_create   Create the TLS parameter structure as of Lichti model
% (Error modelling, calibration and analysis of an AM–CW
%  terrestrial laser scanner system)
%
%   par=NIST2_create() creates a TLS calibration parameter strcuture
%   according to the simplified NIST model (Wang et al 2017) with all
%   deviations set to 0 (representing a perfectly manufactured scanner).
%
%   par=NIST_create('xx',value, 'xx', ...) creates the structure with all
%   parameters set to zero, except the ones where the parameter
%   name and value pairs are passed as arguments. 'xx' needs to be replaced
%   by the correct names (see below), and the value needs to be given in
%   the corresponding units (see below).
%
%   par=NIST_create(p) creates the strcuture with the parameters set
%   to the numeric values given in the nx1 vector p where all parameters of
%   the model are contained, and the sequence corresponds to the sequence 
%   in the table below.
%
%   The output structure has fields with the names of the parameters as
%   of the above publication.
%
%   Parameter units description
%   --------- ----- -------------------
% Parameters for range correction
%   a0       mm     1
%   a1       1      2
%   a2       mm     3
%   a3       mm     4
%   a4       mm     5
%   a5       mm     6
%   a6       mm     7
%   a7       mm     8
%   a8       mm     9
% Parameters for az correction
%   b1       rad    10
%   b2       rad    11
%   b3       rad    12
%   b4       rad    13
%   b5       1      14
%   b6       rad    15
%   b7       rad    16
% Parameters for el correction\
%  c0        rad    17
%  c1        1      18
%  c2        rad    19
%  c3        rad    20
%  c4        rad    21
%
%   See also NIST2_get, NIST2_set, NIST2_fwd, NIST2_bwd


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


% initialize return structure
par = struct( ...
    'a0',0,...
    'a1',0,...
    'a2',0,...
    'a3',0,...
    'a4',0,...
    'a5',0,...
    'a6',0,...
    'a7',0,...
    'a8',0,...
    'b1',0,...
    'b2',0,...
    'b3',0,...
    'b4',0,...
    'b5',0,...
    'b6',0,...
    'b7',0,...
    'c0',0,...
    'c1',0,...
    'c2',0,...
    'c3',0,...
    'c4',0);

% if there are no input arguments, return the all-zero strcuture
if ~nargin
    return;
end

if nargin == 1
    h = varargin{1};
    hh = size(h);
    if ~isnumeric(h) || length(hh)~=2 || min(hh) ~= 1 || max(hh) ~= 21
        error 'Input vector needs to be 21x1 for Lichti model, or input needs to be sequence of names and values.';
    end
    
    % seems to be ok, so assign the values
    h = h(:);
    par.a0   = h(1);
    par.a1   = h(2);
    par.a2    = h(3);
    par.a3    = h(4);
    par.a4    = h(5);
    par.a5    = h(6);
    par.a6    = h(7);
    par.a7    = h(8);
    par.a8    = h(9);
    par.b1   = h(10);
    par.b2   = h(11);
    par.b3   = h(12);
    par.b4  = h(13);
    par.b5  = h(14);
    par.b6  = h(15);
    par.b7  = h(16);
    par.c0  = h(17);
    par.c1   = h(18);
    par.c2   = h(19);
    par.c3   = h(20);
    par.c4  = h(21);
    
    return;
end
    
if mod(nargin,2)
    error 'Number of input arguments must be even for parameter/value pairs'
end

hh = zeros(16,1);           % flag: value already modified?

for i=1:2:nargin
    
    hs = varargin{i};       % this should be the parameter name
    hv = varargin{i+1};     % this should be the parameter value
    
    if ~ischar(hs) || ~isnumeric(hv) || length(hv)~=1
        error('%i-th and %i-th parameter are not a name/value pair', i, i+1);
    end
    
    switch hs
        case 'a0'
            par.a0   = hv;
            if hh(1)
                warning('Previously assigned value of a0 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(1) = 1;
            
        case 'a1'
            par.a1   = hv;
            if hh(2)
                warning('Previously assigned value of a1 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(2) = 1;
            
        case 'a2'
            par.a2    = hv;
            if hh(3)
                warning('Previously assigned value of a2 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(3) = 1;
            
        case 'a3'
            par.a3    = hv;
            if hh(4)
                warning('Previously assigned value of a3 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(4) = 1;
            
        case 'a4'
            par.a4    = hv;
            if hh(5)
                warning('Previously assigned value of a4 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(5) = 1;
            
        case 'a5'
            par.a5 = hv;
            if hh(6)
                warning('Previously assigned value of a5 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(6) = 1;
            
        case 'a6'
            par.a6  = hv;
            if hh(7)
                warning('Previously assigned value of a6 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(7) = 1;
            
        case 'a7'
            par.a7 = hv;
            if hh(8)
                warning('Previously assigned value of a7 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(8) = 1;
            
        case 'a8'
            par.a8    = hv;
            if hh(9)
                warning('Previously assigned value of a8 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(9) = 1;
            
        case 'b1'
            par.b1   = hv;
            if hh(10)
                warning('Previously assigned value of b1 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(10) = 1;
            
        case 'b2'
            par.b2   = hv;
            if hh(11)
                warning('Previously assigned value of b2 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(11) = 1;
            
        case 'b3'
            par.b3   = hv;
            if hh(12)
                warning('Previously assigned value of b3 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(12) = 1;
            
        case 'b4'
            par.b4  = hv;
            if hh(13)
                warning('Previously assigned value of b4 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(13) = 1;
            
        case 'b5'
            par.b5  = hv;
            if hh(14)
                warning('Previously assigned value of b5 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(14) = 1;
            
        case 'b6'
            par.b6  = hv;
            if hh(15)
                warning('Previously assigned value of b6 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(15) = 1;
            
        case 'b7'
            par.b7  = hv;
            if hh(16)
                warning('Previously assigned value of b7 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(16) = 1;
        case 'c0'
            par.c0   = hv;
            if hh(17)
                warning('Previously assigned value of c0 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(17) = 1;
            
        case 'c1'
            par.c1   = hv;
            if hh(18)
                warning('Previously assigned value of c1 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(18) = 1;
            
        case 'c2'
            par.c2    = hv;
            if hh(19)
                warning('Previously assigned value of c2 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(19) = 1;
            
        case 'c3'
            par.c3    = hv;
            if hh(20)
                warning('Previously assigned value of c3 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(20) = 1;
            
        case 'c4'
            par.c4    = hv;
            if hh(21)
                warning('Previously assigned value of c4 replaced (multiple assignment in same call to Lichti_create');
            end
            hh(21) = 1;
            
        otherwise
            error('Parameter ''%s'' not defined for Lichti model (%i-th input argument)', hs, i);
    
    end
    
end

 