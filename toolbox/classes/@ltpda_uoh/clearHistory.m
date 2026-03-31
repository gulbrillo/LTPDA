% CLEARHISTORY Clears the history of an object with history.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CLEARHISTORY Clears the history of an object with history.
%              This is a hidden method and use this method carefully. 
%
% CALL:        objs = clearHistory(objs)
%              objs = objs.clearHistory()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = clearHistory(varargin)
  
  for kk=1:nargin
    if isa(varargin{kk}, 'ltpda_uoh')
      varargin{kk}.hist = [];
    end
  end
  
  varargout = varargin;
end
