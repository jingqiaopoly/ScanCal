function [sec] = rad2sec(rad)
%rad2sec     - Transform angle in sec into radiant
%
%  [sec] = rad2sec(rad)
%
%Input: -------------------------------------------------------------------
%rad   angle in radiant
%
%Output: ------------------------------------------------------------------
%sec   angle in sec ["]
%
sec = rad/pi * 180*3600;
