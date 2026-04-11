% JCOLOR2MCOLOR converts a java color object to a MATLAB color array.
%
% CALL:
%            mc = utils.prog.jcolor2mcolor(c);
%
function out = jcolor2mcolor(varargin)
  
  c = varargin{1};
  out = [c.getRed() c.getGreen() c.getBlue()]/255.0;
  
end