% LE overloads <= operator for ltpda objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LE overloads <= operator for ltpda objects
% 
% CALL:        a = t1 < t2;
%
% INPUTS:      t1 - ltpda_nuo object
%              t2 - ltpda_nuo object or a number
%
% OUTPUTS:     a - logical value from the comparison
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = le(varargin)
  
  op_string = '<=';
  error('The %s operator is not defined for objects of class %s', op_string, class(varargin{1}));
  
end