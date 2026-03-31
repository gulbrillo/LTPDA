function varargout = isobject(varargin)
% ISOBJECT checks that the input objects are one of the LTPDA object types.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISOBJECT checks that the input objects are one of the LTPDA object
%              types.
% 
% CALL:        result  = ltpda_isobject(a1)
%              classes = ltpda_isobject()
% 
% INPUTS:      objects
% 
% OUTPUTS:     result == 1 if all input objects are LTPDA objects
%              result == 0 otherwise
%              classes - a list of recognised LTPDA object types
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j=1:nargin
  if ~isa(varargin{j}, 'ltpda_obj')
    varargout{1} = 0;
    return;
  end
end

% Then we were succesful
varargout{1} = 1;

% END