% LOAD Loads LTPDA objects from a file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    load
%
% DESCRIPTION: Load ltpda user objects from a file
%
% CALL:        objs = <classname>.load(filename) will give a vector with all the objects
%              [obj1, obj2, ...] = <classname>.load(filename) will give a list with single objects
%
%              <classname> can be any of the ltpda_uo (ao, smodel, matrix, plist, ...)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = load(varargin)
  
  % Get the filename
  filename = varargin{1};
  
  % Loads the objects. These are always stored inside a 'objs' variable
  load(filename);
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, objs);
  
end
