% GETUSERCLASSES lists all the LTPDA user object types.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETUSERCLASSES lists all the LTPDA user object types.
%
% CALL:        classes = getUserClasses()
%
% INPUTS:
%
% OUTPUTS:     classes - a cell array with a list of recognised LTPDA user object types
%
% Returns a list of all ltpda classes which are derived from the ltpda_uo
% class.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function classes = getUserClasses()
  classes = utils.helper.ltpda_userclasses();
end