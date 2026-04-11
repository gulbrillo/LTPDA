% GETZUNITS Get the property 'zunits' from the z-axis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the property 'zunits' from the z-axis.
%
% CALL:        val = obj.getZunits();
%
% INPUTS:      obj - must be a single data3D object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = getZunits(data)

  % Get z-units from the z-axis
  %
  % The issue is that we have in the ltpda_data two getter methods:
  % - zunits()
  % - getZunits()
  % We need the function zunits() for backwards compatibility and that is
  % the reason why getZunits() is just a wrapper of this function.
  out = data.zunits();

end

