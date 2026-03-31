% GETYUNITS Get the property 'yunits' from the y-axis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'yunits' from the y-axis.
%
% CALL:        val = obj.getYunits();
%
% INPUTS:      obj - must be a single ltpda_data (cdata, data2D, data3D) object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = getYunits(data)

  % Get y-units from the y-axis
  %
  % The issue is that we have in the ltpda_data two getter methods:
  % - yunits()
  % - getYunits()
  % We need the function yunits() for backwards compatibility and that is
  % the reason why getYunits() is just a wrapper of this function.
  out = data.yunits();

end

