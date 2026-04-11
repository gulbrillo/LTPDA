% TYPE converts the input plist to MATLAB functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TYPE converts the input plists to to a command string which will
%              recreate the plist object.
%
% CALL:        type(as)
%
% INPUTS:      as  - array of plist objects
%
% OUTPUTS:     none.
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'type')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = type(varargin)

  varargout = {string(varargin{:})};
  
end