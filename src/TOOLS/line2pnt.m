function [d, t] = line2pnt(P_B_0, l_B, P_B)
%- Determine the distance between laser beam and 3D point 
%  as well as the distance on the line
%Description: -----------------------------------------------------------------------
%
% beam: a    + t*b         point: p
%       P_B_0+ t*l_B              P_B
%
%     |b x (p - a)|   |l_B x (P_B - P_B_0)|
% d = ------------- = ----------------------
%          |b|                |l_B|
%
%     (b - a) . b     (P_B - P_B_0) . l_B
% t = -----------   = -------------------
%       |b|               |l_B| 
%
% Input:
%     P_B_0 = origin of laser beam
%     l_B   = diection of laser beam, unit vector
%     P_B   = 3D Point
%
% Output:
%     d     = distance between line and 3D Point
%     t     = distance on line 
%

%Determine the distance between laser beam and 3D point.


P_B_0 = repmat(P_B_0, 1, size(P_B, 2));
l_B   = repmat(l_B, 1, size(P_B, 2)); 

d = vnorm(cross(l_B, (P_B - P_B_0)), 1) ./ cmn_norm(l_B);  
t = dot((P_B-P_B_0), l_B) ./ cmn_norm(l_B); 
