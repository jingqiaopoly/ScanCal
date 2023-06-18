classdef scanData
   properties(SetAccess = public)
      az     %azimuth
      el     %elevation
      rng    %range
      intens %intensity
      pts    %3D cartesian point coordinates
      face   %observation from front-face denoted by 1 or back-face denoted by 2
      status %healthy point or not
   end

   methods
      function obj = scanData()
         obj.az = [];
      end
      
      function pts = get.pts(obj)
          pts = polar2cart(obj.az(:)', obj.el(:)',...
             obj.rng(:)',ProjectSettings.instance.selfCal.y_axis);
      end
      
      [cut_data] = cutScans(obj, iraw,jraw, icol, jcol)
      [obj] = flipudScan(obj)
      [cut_data] = cutScansMult(obj, iraw,jraw, icol, jcol)
   end
   
   methods(Static)
        [scan_data, meta_data] = loadPtx(filepath, read_rgb, sample, twoFace)
        [dataFace1, dataFace2] = divideScanCyclone(scanData)
        [Data, Meta] = mergeScans()
        [pointF] = extractFoerstner(dataSeg, setupNr1)
        [Radius,centroid] = calRadius(pt, points,dAZ,numPtLine)
        scanData2ply(pathScan, isOutputGlobal)
   end
    
end