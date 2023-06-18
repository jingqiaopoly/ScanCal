function scanData2ply(pathScan, isOutputGlobal)
   
       
     load(pathScan);
     pts = scan_data.pts;
     
     if isOutputGlobal==1
         [ R, T, pts]= posePara2Matrix(meta_data.scanPos,pts);
     end
     pts=pts.*0.001;
     ptCloud = pointCloud(pts');
     clear scan_data meta_data pts
     pcwrite(ptCloud,[pathScan(1:end-4) '.ply']);
     
 
end
