function [vce_var] = VCE_analysis(obj,VCE_type,obsType,QvvP,V,Q_diag,std_h_v,high_separate,ht)
% Input: 
%    VCE_type: how to calculate VCE
%    obsType : type of observations
%      QvvP  : diangnal of redundancy matrix
%      V     : observation residuals
%      Q     : Cofactor matrix of observatons
%    std_h_v : a string indicating whether azimuth and elevation angles are considered together
%high_separate: whether the observations at different height ranges are considered separately
%   ht       : struct with different height range info
% $Author: Jing Qiao$   
% $Date: 2021/08/21 $ 
% Acknowldgement: the codes for VCE_analysis are partially taken from Dr. Medic Tomislav 


    if strcmp(high_separate,'no')
        % VCE - Variance component analysis
        % ---------------------------------
        if strcmp(obsType,'normDisAng')
            % Robust redundancies for distance and angle (considering observation weights)
            Rdis = sum(QvvP(1:2:end));
            Rang = sum(QvvP(2:2:end));
            % Normalized residuals
            V_norm = V./sqrt(Q_diag);
            if strcmp(VCE_type,'RMSE')
            % A: variances from RMSE of normalized residuals (less robust)
                var_Vdis_norm = sum( V_norm(1:2:end) .* V_norm(1:2:end)) / length(V_norm(1:2:end));
                var_Vang_norm = sum( V_norm(2:2:end) .* V_norm(2:2:end)) / length(V_norm(2:2:end));
            elseif strcmp(VCE_type,'MAD')
            % B: variances from median of absolute normalized residuals (robust)
                var_Vdis_norm = (1.4826 * median(abs(V_norm(1:2:end)))).^2;
                var_Vang_norm = (1.4826 * median(abs(V_norm(2:2:end)))).^2;
            else
                disp('Wrong VCE_type_entry')
            end
            % Final variance factors:
            vce_var.dis2 = (length(V_norm(1:2:end)) / Rdis) * var_Vdis_norm;
            vce_var.ang2 = (length(V_norm(2:2:end)) / Rang) * var_Vang_norm;

            % Test-values for Chi-square & F-test
            vvp = V .* V ./Q_diag;
            
            vce_var.Chi_test = [ sum(vvp(1:2:end)),  sum(vvp(2:2:end)) ];
            vce_var.Chi_low  = [chi2inv(0.05,Rdis),  chi2inv(0.05,Rang)];
            vce_var.Chi_high = [chi2inv(0.95,Rdis),  chi2inv(0.95,Rang)];
            vce_var.F_low    = [finv(0.05,Rdis,Inf) finv(0.05,Rang,Inf)];
            vce_var.F_high   = [finv(0.95,Rdis,Inf) finv(0.95,Rang,Inf)];

            vce_var.s02_all = [vce_var.dis2 vce_var.ang2];
            
        elseif strcmp(obsType,'normDis')
            Rdis = sum(QvvP);
            % Normalized residuals
            V_norm = V./sqrt(Q_diag);
            if strcmp(VCE_type,'RMSE')
            % A: variances from RMSE of normalized residuals (less robust)
                var_Vdis_norm = sum( V_norm .* V_norm) / length(V_norm);
            elseif strcmp(VCE_type,'MAD')
            % B: variances from median of absolute normalized residuals (robust)
                var_Vdis_norm = (1.4826 * median(abs(V_norm))).^2;
            else
                disp('Wrong VCE_type_entry')
            end
            % Final variance factors:
            vce_var.dis2 = (length(V_norm) / Rdis) * var_Vdis_norm;

            % Test-values for Chi-square & F-test
            vvp = V .* V ./Q_diag;
            
            vce_var.Chi_test = [ sum(vvp)];
            vce_var.Chi_low  = [chi2inv(0.05,Rdis)];
            vce_var.Chi_high = [chi2inv(0.95,Rdis)];
            vce_var.F_low    = [finv(0.05,Rdis,Inf)];
            vce_var.F_high   = [finv(0.95,Rdis,Inf) ];

            vce_var.s02_all = [vce_var.dis2 ];

        elseif strcmp(obsType,'Feature')
            % Robust redundancies for r,h,v (considering observation weights)
            Rr = sum(QvvP(1:3:end));
            Rh = sum(QvvP(2:3:end));
            Rv = sum(QvvP(3:3:end));

            % Normalized residuals
            V_norm = V./sqrt(Q_diag);

            % OLD IMPLEMENTATION:
            % by Reshetyuk PhD p. 86 (Eq. 4.90, 4.91)
            % 3 (4) measurement groups: r,h,v, (compensator)

            %         % Group variance factors from VCE for r, h, v, & (compensator)
            %         vce_var.r2 = sum( V(1:3:end) .* diag(Q(1:3:end,1:3:end)).^-1 .* V(1:3:end)) / Rr;
            %         vce_var.h2 = sum( V(2:3:end) .* diag(Q(2:3:end,2:3:end)).^-1 .* V(2:3:end)) / Rh;
            %         vce_var.v2 = sum( V(3:3:end) .* diag(Q(3:3:end,3:3:end)).^-1 .* V(3:3:end)) / Rv;

            % NEW IMPLEMENTATION:
            % by Förstner - Photogrammetric Computer Vision (p. 145-146)

            if strcmp(VCE_type,'RMSE')
            % A: variances from RMSE of normalized residuals (less robust)
                var_Vr_norm = sum( V_norm(1:3:end) .* V_norm(1:3:end)) / length(V_norm(1:3:end));
                var_Vh_norm = sum( V_norm(2:3:end) .* V_norm(2:3:end)) / length(V_norm(2:3:end));
                var_Vv_norm = sum( V_norm(3:3:end) .* V_norm(3:3:end)) / length(V_norm(3:3:end));

            elseif strcmp(VCE_type,'MAD')
            % B: variances from median of absolute normalized residuals (robust)
                var_Vr_norm = (1.4826 * median(abs(V_norm(1:3:end)))).^2;
                var_Vh_norm = (1.4826 * median(abs(V_norm(2:3:end)))).^2;
                var_Vv_norm = (1.4826 * median(abs(V_norm(3:3:end)))).^2;      

            else
                disp('Wrong VCE_type_entry')
            end

            % Final variance factors:
            vce_var.r2 = (length(V_norm)/3 / Rr) * var_Vr_norm;
            vce_var.h2 = (length(V_norm)/3 / Rh) * var_Vh_norm;
            vce_var.v2 = (length(V_norm)/3 / Rv) * var_Vv_norm;

            % Test-values for Chi-square & F-test
            vvp = V .* V ./Q_diag;

            vce_var.Chi_test = [ sum(vvp(1:3:end)), sum(vvp(2:3:end)), sum(vvp(3:3:end))];
            vce_var.Chi_low = [chi2inv(0.05,Rr), chi2inv(0.05,Rh), chi2inv(0.05,Rv)];
            vce_var.Chi_high = [chi2inv(0.95,Rr), chi2inv(0.95,Rh), chi2inv(0.95,Rv)];
            vce_var.F_low = [finv(0.05,Rr,Inf) finv(0.05,Rh,Inf) finv(0.05,Rv,Inf)];
            vce_var.F_high = [finv(0.95,Rr,Inf) finv(0.95,Rh,Inf) finv(0.95,Rv,Inf)];

            if strcmp(std_h_v,'combined')
                vce_var.h2 = (vce_var.h2 + vce_var.v2)/2;
                vce_var.v2 = vce_var.h2;
            end

            vce_var.s02_all = [vce_var.r2 vce_var.h2 vce_var.v2];

        elseif strcmp(obsType,'camFeature')
              % Robust redundancies for r,h,v, xc, yc (considering observation weights)
            Rr = sum(QvvP(1:5:end));
            Rh = sum(QvvP(2:5:end));
            Rv = sum(QvvP(3:5:end));
            Rx = sum(QvvP(4:5:end));
            Ry = sum(QvvP(5:5:end));

            % Normalized residuals
            V_norm = V./sqrt(Q_diag);
            % NEW IMPLEMENTATION:
            % by Förstner - Photogrammetric Computer Vision (p. 145-146)

            if strcmp(VCE_type,'RMSE')
            % A: variances from RMSE of normalized residuals (less robust)
                var_Vr_norm = sum( V_norm(1:5:end) .* V_norm(1:5:end)) / length(V_norm(1:5:end));
                var_Vh_norm = sum( V_norm(2:5:end) .* V_norm(2:5:end)) / length(V_norm(2:5:end));
                var_Vv_norm = sum( V_norm(3:5:end) .* V_norm(3:5:end)) / length(V_norm(3:5:end));
                var_Vx_norm = sum( V_norm(4:5:end) .* V_norm(4:5:end)) / length(V_norm(4:5:end));
                var_Vy_norm = sum( V_norm(5:5:end) .* V_norm(5:5:end)) / length(V_norm(5:5:end));

            elseif strcmp(VCE_type,'MAD')
            % B: variances from median of absolute normalized residuals (robust)
                var_Vr_norm = (1.4826 * median(abs(V_norm(1:5:end)))).^2;
                var_Vh_norm = (1.4826 * median(abs(V_norm(2:5:end)))).^2;
                var_Vv_norm = (1.4826 * median(abs(V_norm(3:5:end)))).^2; 
                var_Vx_norm = (1.4826 * median(abs(V_norm(4:5:end)))).^2;
                var_Vy_norm = (1.4826 * median(abs(V_norm(5:5:end)))).^2; 
            else
                disp('Wrong VCE_type_entry')
            end

            % Final variance factors:
            vce_var.r2 = (length(V_norm)/5 / Rr) * var_Vr_norm;
            vce_var.h2 = (length(V_norm)/5 / Rh) * var_Vh_norm;
            vce_var.v2 = (length(V_norm)/5 / Rv) * var_Vv_norm;
            vce_var.x2 = (length(V_norm)/5 / Rx) * var_Vx_norm;
            vce_var.y2 = (length(V_norm)/5 / Ry) * var_Vy_norm;

            % Test-values for Chi-square & F-test
            vvp = V .* V ./Q_diag;

            vce_var.Chi_test = [ sum(vvp(1:5:end)), sum(vvp(2:5:end)), sum(vvp(3:5:end)),sum(vvp(4:5:end)), sum(vvp(5:5:end))];
            vce_var.Chi_low = [chi2inv(0.05,Rr), chi2inv(0.05,Rh), chi2inv(0.05,Rv), chi2inv(0.05,Rx), chi2inv(0.05,Ry)];
            vce_var.Chi_high = [chi2inv(0.95,Rr), chi2inv(0.95,Rh), chi2inv(0.95,Rv), chi2inv(0.95,Rx), chi2inv(0.95,Ry)];
            vce_var.F_low = [finv(0.05,Rr,Inf) finv(0.05,Rh,Inf) finv(0.05,Rv,Inf) finv(0.05,Rx,Inf) finv(0.05,Ry,Inf)];
            vce_var.F_high = [finv(0.95,Rr,Inf) finv(0.95,Rh,Inf) finv(0.95,Rv,Inf) finv(0.95,Rx,Inf) finv(0.95,Ry,Inf)];

            if strcmp(std_h_v,'combined')
                vce_var.h2 = (vce_var.h2 + vce_var.v2)/2;
                vce_var.v2 = vce_var.h2;
            end

            vce_var.s02_all = [vce_var.r2 vce_var.h2 vce_var.v2 vce_var.x2 vce_var.y2];


        end
        

    else
     
        if strcmp(obsType,'normDis')
            
        elseif strcmp(obsType,'Feature')
             % Normalized residuals
             V_norm = V./sqrt(Q_diag);
             % Test-value for Chi-square test
             vvp = V .* V ./Q_diag;

             vce_var.Chi_test = zeros(5,1);
             vce_var.Chi_low = zeros(5,1);
             vce_var.Chi_high = zeros(5,1);

             vce_var.F_low = zeros(5,1);
             vce_var.F_high = zeros(5,1);

             vce_var.s02_all = zeros(5,1);

             for i = 1:5

                 Ri = sum(QvvP(ht == i));
                 if Ri>1
                     if strcmp(VCE_type,'RMSE')
                        var_V_norm_i = sum( V_norm(ht == i) .* V_norm(ht == i)) / length( V_norm(ht == i));
                     elseif strcmp(VCE_type,'MAD')
                        var_V_norm_i = (1.4826 * median(abs(V_norm(ht == i)))).^2;     
                     end

                     vce_var.s02_all(i) = (length( V_norm(ht == i)) / Ri) * var_V_norm_i;
                     vce_var.Chi_test(i) = sum(vvp(ht==i));
                     vce_var.Chi_low(i) = chi2inv(0.05,Ri);
                     vce_var.Chi_high(i) = chi2inv(0.95,Ri);
                     vce_var.F_low(i) = finv(0.05,Ri,Inf);
                     vce_var.F_high(i) = finv(0.95,Ri,Inf);
                 else
                     vce_var.s02_all(i) = 1;
                     vce_var.Chi_test(i) = 1;
                     vce_var.Chi_low(i) = 0.9;
                     vce_var.Chi_high(i) = 1.1;
                     vce_var.F_low(i) = 0.9;
                     vce_var.F_high(i) = 1.1;
                 end

             end

        elseif strcmp(obsType,'camFeature')

        end
    end

end

