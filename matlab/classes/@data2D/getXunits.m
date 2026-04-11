% GETXUNITS Get the property 'xunits' from the x-axis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'xunits' from the x-axis.
%
% CALL:        val = obj.getXunits();
%
% INPUTS:      obj - must be a single data2D (cdata, tsdata, fsdata, xyzdata) object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = getXunits(data)

  % Get x-units from the x-axis
  %
  % The issue is that we have in the ltpda_data two getter methods:
  % - xunits()
  % - getXunits()
  % We need the function xunits() for backwards compatibility and that is
  % the reason why getXunits() is just a wrapper of this function.
  out = data.xunits();

end

