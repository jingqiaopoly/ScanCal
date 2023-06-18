classdef metaData
   properties
       jobNr
       setupNr
       scanPos
       face12
       fullcycle 
       camInt_data
   end
   methods
      function obj = metaData()
         obj.jobNr = 0;
         obj.setupNr = 0;
         obj.scanPos = [];
         obj.face12 = [];
         obj.fullcycle = 0;
         obj.camInt_data = [];
      end
   end
end