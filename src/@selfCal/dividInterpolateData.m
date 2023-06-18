function [dataSeg] = dividInterpolateData(obj, resAngle,deltAngle)
%
% Divide point clouds into nSeg segments in each face of each scan
% nSegHalf segments upper and bottom parts each assuming 360 deg is
% covered, some segments are empty as normally only 180 deg is scanned
    % Check inputs
    if nargin < 2
        resAngle = 3.1253e-04;
    end
    if nargin < 3
        deltAngle =  30/180*pi;
    end

    data_seg = struct( ...
    'seg', scanData());
    dataSeg(2,obj.nSet) =  data_seg();
    
     
    
    nSegRow= pi/deltAngle; nSegCol=2*nSegRow;
    nRow1 = floor(deltAngle/resAngle);
    nCol1 = nRow1;
    [xq,yq] = meshgrid(1:nCol1,1:nRow1);
    
    for iset=1:obj.nSet
       for iface =1:2
            data = obj.data(iface,iset);
            az = data.az;
            el = data.el;
            rng = data.rng;
            intens = data.intens;
            clear data
            if ~isempty(az)
                dataSeg(iface,iset) = data_seg();
                dataSeg(iface,iset).seg(nSegRow,nSegCol) = scanData();
                
                for isegR=1:nSegRow
                    if iface==1
                       elS = pi/2-(isegR-1)*deltAngle; elE = pi/2-isegR*deltAngle; % min(el1(1:index0));  elS = max(el1(1:index0));
                    else
                       if isegR<nSegRow/2+1
                          elS = pi/2+(isegR-1)*deltAngle;           elE =  pi/2+isegR*deltAngle;
                       else
                          elS = -pi +(isegR-nSegRow/2-1)*deltAngle; elE = -pi+(isegR-nSegRow/2)*deltAngle; 
                       end
                    end
                
                    for isegC=1:nSegCol
                        %0 -> 180/-180  ->0
                        if isegC<nSegCol/2+1
                          azS = 0+(isegC-1)*deltAngle;              azE =  0+isegC*deltAngle;
                        else
                          azS = -pi +(isegC-nSegCol/2-1)*deltAngle; azE = -pi+(isegC-nSegCol/2)*deltAngle; 
                        end
                        if iface==1
                           index = find(az>(azS-0.01)&az<(azE+0.01)&el<elS+0.01&el>elE-0.01);
                        else
                           index = find(az>(azS-0.01)&az<(azE+0.01)&el>elS-0.01&el<elE+0.01);
                        end
                        
                        if length(index)>500
                            xc = (az(index)-azS)/(azE-azS)*(nCol1-1)+1;
                            yc = (el(index)-elS)/(elE-elS)*(nRow1-1)+1;
                            dataSeg(iface,iset).seg(isegR,isegC).intens = griddata(xc,yc,intens(index),xq,yq,'linear'); 
                            dataSeg(iface,iset).seg(isegR,isegC).rng    = griddata(xc,yc,rng(index),   xq,yq,'linear'); 
                            dataSeg(iface,iset).seg(isegR,isegC).az     = (xq-1)*(azE-azS)/(nCol1-1)+azS;
                            dataSeg(iface,iset).seg(isegR,isegC).el     = (yq-1)*(elE-elS)/(nRow1-1)+elS;
                            dataSeg(iface,iset).seg(isegR,isegC).face   = ones(nRow1,nCol1).*iface;
                        end
                    end
                end
              
            end
       end
    end

















