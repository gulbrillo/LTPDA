% GETCLASSES lists all the LTPDA object types.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETCLASSES lists all the LTPDA object types.
%
% CALL:        classes = getClasses()
%
% INPUTS:
%
% OUTPUTS:     classes - a cell array with a list of recognised LTPDA object types
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function classes = getClasses()
  classes = utils.helper.ltpda_classes();
end