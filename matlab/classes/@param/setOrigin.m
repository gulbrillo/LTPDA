% SETORIGIN Set the property 'origin'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'origin'.
%
% CALL:        obj.setOrigin('origin');
%              obj = setOrigin(obj, 'origin');
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setOrigin(varargin)
  
  %%% decide whether we modify the first plist, or create a new one.
  varargin{1} = copy(varargin{1}, nargout);
  
  varargin{1}.origin = varargin{2};
  varargout{1} = varargin{1};
  
end
