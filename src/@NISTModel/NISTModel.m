classdef NISTModel
   properties
   end
   methods
      function obj = NISTModel()
      end
      
      
   end
   methods(Static)
      par = NIST2_create( varargin )
      cor = NIST2_fwd_s( raw, par )
      raw = NIST2_bwd_s( cor, par )   %par: structure of NIST2 model parameters, created by NIST2_create
       
      [cor] = NIST2_fwd( raw, scannerInfo ) % scannerInfo: parameter array
      [raw] = NIST2_bwd( cor, scannerInfo )
      
      par = NIST3_create( varargin )
      cor = NIST3_fwd_s( raw, par )
      raw = NIST3_bwd_s( cor, par )
       
      [cor] = NIST3_fwd( raw, scannerInfo )
      [raw] = NIST3_bwd( cor, scannerInfo )
      
      par = NIST8_create( varargin )
      cor = NIST8_fwd_s( raw, par,y_axis )
      raw = NIST8_bwd_s( cor, par,y_axis )

      par = NIST9_create( varargin )
      cor = NIST9_fwd_s( raw, par,y_axis )
      raw = NIST9_bwd_s( cor, par,y_axis )
      
      par = NIST10_create( varargin )
      cor = NIST10_fwd_s( raw, par,y_axis )
      raw = NIST10_bwd_s( cor, par )
      
      cor = NIST_fwd( raw, scannerInfo,instr_type )
      raw = NIST_bwd( cor, scannerInfo,instr_type )
      
      par = Lichti_create( varargin )
      cor = Lichti_fwd_s( raw, par )
%       raw = Lichti_bwd_s( cor, par )
      
   end
end