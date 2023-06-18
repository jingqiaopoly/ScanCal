function [pnt] = polar2cart(az, el, rg, y) 
%% polar2cart     - Converts polar coordinates defined in the geodetic way to artesian coordinates
%                  By default: Azimuth angle is defined against y-axis and positive clock-wise
%                  if y=0: Azimuth angle is defined against x-axis
%                         
%
%  [pnt] = polar2cart(az, el, rg)
%
%Input: -----------------------------------------------------------------------------
%az      Azimuth angle [rad]
%el      Elevation angle [rad]
%rg      Range [mm]
%
%Output: ----------------------------------------------------------------------------
%pnt     Cartesian coordinates of one or multiple points [3 x N]. Unit [mm]
%

if nargin < 4
    y=1;
end

if y==1
    pnt  = (ones(3,1)*rg) .* [cos(el) .* sin(az); ...
                          cos(el) .* cos(az); ...
                          sin(el)];

% % Transformation of Tom
%       pnt  = (ones(3,1)*rg) .* [sin(el) .* sin(az); ...
%                            sin(el) .* cos(az); ...
%                            cos(el)];
else
%     pnt  = (ones(3,1)*rg) .* [cos(el) .* cos(az); ...
%                           cos(el) .* sin(az); ...
%                           sin(el)];

pnt  = (ones(3,1)*rg) .* [sin(el) .* cos(az); ...
                          -sin(el) .* sin(az); ...
                          cos(el)];
end

end