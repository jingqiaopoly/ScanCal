function [dataFace1, dataFace2] = divideScanCyclone(scan_data)
% EXTRACTDOUBLESCANUP Splits a double face scan into two separate objects.
% One object for face1 and one for face2 data, the intensity image is not
% upside-down as in extractDoubleScan any more
%
%     [dataFace1, dataFace2] = extractDoubleScanUp(scanData)
%
% Input:
%    scanData     object from type: cmn.data.cls_hds_scan_meas
%                 containing double face scan data.
%
% Output:
%    dataFace1    splitted data, containing only face1 data points
%    dataFace2    splitted data, containing only face2 data points
%                 both datasets are from type cmn.data.cls_hds_scan_meas
% History: ----------------------------------------------------------------
% $Author: Jing $   
% $Date: 2019/12/17 $ 
% $Change: 840248 $, $Revision: #1 $
% -------------------------------------------------------------------------
%--------------------------------------------------------------------------
      
    fc = scan_data.face(1,:);
    if  all(fc == fc(1))
        isCyclone = 0;
    else
        isCyclone = 1;
    end
    
    if isCyclone
        fc = scan_data.face(1,:);
        index1 = find(fc==1);

        % Extract data for face 1
        dataFace1 = scanData();
        dataFace1.az = scan_data.az(:,index1);
        dataFace1.el = scan_data.el(:,index1);
        dataFace1.rng = scan_data.rng(:,index1);
        dataFace1.intens = scan_data.intens(:,index1);
        dataFace1.face = scan_data.face(:,index1);
        dataFace1.status = scan_data.status(:,index1);

        index2 = find(fc==2);
        dataFace2 = scanData();
        dataFace2.az = scan_data.az(:,index2);
        dataFace2.el = scan_data.el(:,index2);
        dataFace2.rng = scan_data.rng(:,index2);
        dataFace2.intens = scan_data.intens(:,index2);
        dataFace2.face = scan_data.face(:,index2);
        dataFace2.status = scan_data.status(:,index2);
    else %from import scan
        fc = scan_data.face(:,1);
        index1 = find(fc==1);
        
         % Extract data for face 1
        dataFace1 = scanData();
        dataFace1.az = flipud(scan_data.az(index1,:));
        dataFace1.el = flipud(scan_data.el(index1,:));
        dataFace1.rng = flipud(scan_data.rng(index1,:));
        dataFace1.intens = flipud(scan_data.intens(index1,:));
        dataFace1.face = flipud(scan_data.face(index1,:));
%         dataFace1.status = flipud(scan_data.status(index1,:));

        index2 = find(fc==2);
        dataFace2 = scanData();
        dataFace2.az = scan_data.az(index2,:);
        dataFace2.el = scan_data.el(index2,:);
        dataFace2.rng = scan_data.rng(index2,:);
        dataFace2.intens = scan_data.intens(index2,:);
        dataFace2.face = scan_data.face(index2,:);
%         dataFace2.status = scan_data.status(index2,:);
        
    end

end
