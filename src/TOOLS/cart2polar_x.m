function [az, el, rg] = cart2polar_x(pnt, face)
%cart2polar     - Converts cartesian coordinates to polar coordinates defined
%                         in the geodetic way. Azimuth angle is defined against
%                         x-axis and positive clock-wise 
%
%  [az, el, rg] = cart2polar(pnt, face)
%
%Input: -----------------------------------------------------------------------------
%pnt     Cartesian coordinates of one or multiple points [3 x N]. Unit [mm]
%face    Face definition in that we would like to get the polar angles.
%
%Output: ----------------------------------------------------------------------------
%az      Azimuth angle [rad]
%el      Elevation angle [rad]
%rg      Range [mm]
%
%Remark: ----------------------------------------------------------------------------
%
%
%History: ---------------------------------------------------------------------------
%$Author: Jing $
%$Date: 2019/8/30$
%====================================================================================

if(size(pnt,2)~=size(face))
   error('The number of points and face defination is not consistent') 
end
%====================================================================================
%Start
%====================================================================================
%------------------------------------------------------------------------------------
%Extract the range and convert to unit vectors
rg       = cmn_norm(pnt);
unit_vec	= pnt ./ (ones(3,1) * rg);

%Calculate angles for face 1
az  = atan2(unit_vec(1, :), unit_vec(2, :));
el  = asin(unit_vec(3, :));

iface2 = face == 2;

%We have to change face to face II
az(iface2) = ang_bound(az(iface2) + pi);
el(iface2) = ang_bound(pi - el(iface2));

end
