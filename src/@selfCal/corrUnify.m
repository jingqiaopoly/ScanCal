function [X] = corrUnify(obj, p_kap, p_pos,   rng, az, el,iSet,nSet,refSet,scanPos,  params)
  %% Correct all the observations with scanner calibration model and then transform the coordinates to the reference system 
  % Input:
  %   p_kap         Array with the scanner parameters
  %   params        extra parameters related to calibration:
  %     .sigma_threshold   defining the sigma threshold value to neglect
  %                        the corepoints.
  %     .wup_state         current warm-up state (value between 0 and 1)
  %     .system_temp       current system temperature (KAZA) [�C]
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
  
%    system_temp = params.system_temp;
%    wup_state = params.wup_state;
%    instr_type = params.instr_type;
   
% % Initialize Parameters
%   hpar = params.hpar.copy();
%   hpar.m_cal_temp = params.hpar.m_cal_temp;
%   hpar.m_kin_ang = params.hpar.m_kin_ang;
%   hpar.m_kin_off = params.hpar.m_kin_off;
%   hpar.m_kin_ang.m_mu(1)     = p_kap(1);
%   hpar.m_kin_ang.m_eps(1)    = p_kap(2);
%   hpar.m_kin_ang.m_del_el(1) = p_kap(3);   
%   hpar.m_kin_off.m_L_S2(1)   = p_kap(4);
%   hpar.m_kin_off.m_L_S3(1)   = p_kap(5);
%   hpar.m_kin_off.m_s_oy(1)   = p_kap(7);
%   hpar.m_kin_ang.m_lam1(1)   = p_kap(8);
%   hpar.m_kin_ang.m_lam2(1)   = p_kap(9);
%   
%   if instr_type == cmn.enumerators.enm_instr_type.KZR
%       hpar.m_wup_par = params.hpar.m_wup_par;
%       hpar.m_kin_off.m_V_M1(1)   = p_kap(6);
%   else
%       hpar.m_kin_off.m_m_ox(1)   = p_kap(6);
%   end
%   
% % If no wup_state is available (=0) set it to 100% to ignore it
%   if wup_state == 0
%       wup_state = 1;
%   end
  
% % Create new Kinematic Object
%   if instr_type == cmn.enumerators.enm_instr_type.KZR
%       kin = kzr.scanner.cls_hds_kin_kzr(instr_type);
%       kin.set_param(hpar, system_temp, 'WUP', wup_state);
%       [~,~,~,~,del_el_temp_corrected] = hpar.get_kin_ang_par_temp_corr(system_temp,wup_state);
%   else
%       kin = colibri.calibration.cls_colibri_kin(instr_type);
%       kin.set_param(hpar, system_temp);
%       [~,~,~,~,del_el_temp_corrected] = hpar.get_kin_ang_par_temp_corr(system_temp);
%   end
  
      num_pt=size(rng,1);
      raw = zeros(3, num_pt);
      raw(1,:) = rng'./1000;
      raw(2,:) = az';
      raw(3,:) = el';

%   % Add delta-el value, as it is not applied in kin.fwd_pnt
%   raw(3,:) = raw(3,:) + del_el_temp_corrected;
  
     % Perform forward point projection to correct the observations
      cor = NISTModel.NIST_fwd(raw,p_kap,obj.model);
      
      % Transform the corrected observations into the reference system
      X = polar2cart(cor(2,:), cor(3,:), cor(1,:),ProjectSettings.instance.selfCal.y_axis);
      X = X*1000;
  
      for iset1=1: nSet
          if iset1~=refSet
             if(iset1<refSet)
                k=1;
             else
                k=2;
             end
            %Roattion matrix
            tmp = p_pos(6*iset1-6*k+1:6*iset1-6*k+3); %The roation angles may later from IMU 
            eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
            R = eul2rotm(eul','ZYX');
            %Translation matrix
            T = p_pos(6*iset1+4-6*k:6*iset1+6-6*k);
          else
            %Roattion matrix
            tmp = scanPos(refSet,1:3); %The roation angles may later from IMU 
            eul=tmp;eul(1)=tmp(3);eul(3)=tmp(1);
            R = eul2rotm(eul,'ZYX');
            %Translation matrix
            T =scanPos(refSet,4:6)';
          end
          index = find(iSet==iset1);  
          X(:,index) = R*X(:,index)+repmat(T,1,size(index,1));
      end
  
end