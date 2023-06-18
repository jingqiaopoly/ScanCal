function [global_test,s0] = globalTest(obj,gl_test_type,VTPV,robust_redundancy,vce_var,global_test)
% Global test (goodnes of fit) for the least squares adjustment
% $Author: Jing Qiao$   
% $Date: 2021/08/21 $ 
% Acknowldgement: the codes for global test are partially taken from Dr. Medic Tomislav 
    
    s0 = sqrt(VTPV/robust_redundancy);
                
    if strcmp(gl_test_type,'Chi')

        % Chi-square test (gobal test / goodnes of fit test)
        chi_low = chi2inv(0.05,robust_redundancy);
        chi_high = chi2inv(0.95,robust_redundancy);

        if VTPV < chi_high && VTPV > chi_low
            global_test = 'passed';
        end

    elseif strcmp(gl_test_type,'Wujanz')

        % Wujanz et. al. 2017 (gobal test / goodnes of fit test)
        if s0 < 1.3 && s0 > 0.7
            global_test = 'passed';
        end
        
    elseif strcmp(gl_test_type,'Chi_separate')

        % Chi-square test - for each observation group separately
        % (r,h,v)
        test = vce_var.Chi_test > vce_var.Chi_low & vce_var.Chi_test < vce_var.Chi_high;
        if sum(test) == length(test)
            global_test = 'passed';
        end

    elseif strcmp(gl_test_type,'Wujanz_separate')

        % Chi-square test - for each observation group separately
        % (r,h,v)
       s0_rhv = sqrt(vce_var.s02_all);
       test = s0_rhv > 0.7 & s0_rhv < 1.3;
        if sum(test) == length(test)
            global_test = 'passed';
        end
        
    elseif strcmp(gl_test_type,'F')
        
        % F-test: Reshetyuk 2009, PhD & Förstner - Photogrammetric C.V., p.90
        F_test = s0^2;
        F_low = finv(0.05,robust_redundancy,Inf);
        F_high = finv(0.95,robust_redundancy,Inf);
        if F_test > F_low && F_test < F_high
            global_test = 'passed';
        end
        
    elseif strcmp(gl_test_type,'F_separate')
        
        % F-test: Reshetyuk 2009, PhD & Förstner - Photogrammetric C.V., p.90
        % each observation group separately
        F_test = vce_var.s02_all;
        test = F_test > vce_var.F_low & F_test < vce_var.F_high;
        if sum(test) == length(test)
            global_test = 'passed';
        end
            
    else
        disp('Wrong global test type entry');
    end
    
    if ~exist('Chi_test','var')
        Chi_test = [];
    end
end

