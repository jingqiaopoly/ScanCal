
function [scanData0] = downSampleScandata(scan_data, sub_samp)
    
   numSet =  size(scan_data,2);
   scanData0(numSet)= scanData();
   
   for iset=1:numSet
       scanData0(iset).az = scan_data(1, iset).az(1:sub_samp:end, 1:sub_samp:end);
       scanData0(iset).el = scan_data(1, iset).el(1:sub_samp:end, 1:sub_samp:end);
       scanData0(iset).rng = scan_data(1, iset).rng(1:sub_samp:end, 1:sub_samp:end);
       scanData0(iset).intens = scan_data(1, iset).intens(1:sub_samp:end, 1:sub_samp:end);
       
       scanData0(iset).face = scan_data(1, iset).face(1:sub_samp:end, 1:sub_samp:end);
       scanData0(iset).status = scan_data(1, iset).status(1:sub_samp:end, 1:sub_samp:end);
       
      
   end
end