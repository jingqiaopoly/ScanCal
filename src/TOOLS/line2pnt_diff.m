function [d, t] = line2pnt_diff(P_B_0, l_B, P_B)
%cmn.math.line2pnt_diff     - Determine the distance between laser beam and 3D point 
%                             as well as the distance on the line
% 
%
%
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
%       |b| ^2              |l_B|^2 
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
%Remark: ----------------------------------------------------------------------------
%        
%History: ---------------------------------------------------------------------------
%$Author: kelm $   
%$Date: 2013/06/24 $     2010/12/24
%$Change: 385721 $, $Revision: #2 $
%
%------------------------------------------------------------------------------------
%Leica Geosystems AG             Roadrunner                      Dec-2011 / Kelm-4874
%------------------------------------*-----------------------------------------------
%
%See also .

%Determine the distance between laser beam and 3D point.
%

P_B_0 = repmat(P_B_0, 1, size(P_B, 2));
l_B   = repmat(l_B, 1, size(P_B, 2)); 


d           = cmn.math.vnorm(cross(l_B, (P_B - P_B_0)), 1) ./ cmn_norm(l_B);  
t           = dot((P_B-P_B_0), l_B) ./ cmn_norm(l_B).^2; 






