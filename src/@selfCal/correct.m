function [X] = correct(obj, p_kap,rng, az, el,  params)
  %% Correct all the observations with scanner calibration model and then transform the coordinates to the reference system 
  % Input:
  %   p_kap         Array with the scanner parameters
  %   params        extra parameters related to calibration:
  %     .sigma_threshold   defining the sigma threshold value to neglect
  %                        the corepoints.
  %     .wup_state         current warm-up state (value between 0 and 1)
  %     .system_temp       current system temperature (KAZA) [°C]
  %     .instr_type        definition of used instrument type of class
  %                        
  % 
  % Output:
  %   X        corrected and unified 3D coordinates
  % History: --------------------------------------------------------------
  % $Author: Jing $   
  % $Date: 2019/06/04 $ 
  %------------------------------------------------------------------------
  
  % TODO: add functions related to corrections due to temperature, warm-up,
  % etc
      num_pt=size(rng,1);
      raw = zeros(3, num_pt);
      raw(1,:) = rng'./1000;
      raw(2,:) = az';
      raw(3,:) = el';

%   % Add delta-el value, as it is not applied in kin.fwd_pnt
%   raw(3,:) = raw(3,:) + del_el_temp_corrected;
  
     % Perform forward point projection to correct the observations
      cor = NISTModel.NIST_fwd(raw,p_kap, obj.model);
      
      % Transform the corrected observations into the reference system
      X = polar2cart(cor(2,:), cor(3,:), cor(1,:),ProjectSettings.instance.selfCal.y_axis);
      X = X*1000;
end