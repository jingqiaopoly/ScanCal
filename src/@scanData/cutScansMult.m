function [cut_data] = cutScansMult(obj, iraw,jraw, icol, jcol)
     % Cut out multiple patches of the scan data according to the starting and
     % ending rows/colums
     % Input: obj: original data to be cut
     %        iraw:      starting raw
     %        jraw:      end raw
     %        icol:      starting column
     %        jcol:      end column
     
     cut_data = scanData();
     
     for i=1:length(iraw)
         ir = iraw(i); jr = jraw(i);  ic = icol(i); jc = jcol(i);
         cut_data.az    = [cut_data.az     obj.az(ir:jr, ic:jc)];
         cut_data.el    = [cut_data.el     obj.el(ir:jr, ic:jc)];
         cut_data.rng   = [cut_data.rng    obj.rng(ir:jr, ic:jc)];
         cut_data.intens= [cut_data.intens obj.intens(ir:jr, ic:jc)];
         cut_data.face  = [cut_data.face   obj.face(ir:jr, ic:jc)];
         cut_data.status= [cut_data.status obj.status(ir:jr, ic:jc)];
     end
     
end