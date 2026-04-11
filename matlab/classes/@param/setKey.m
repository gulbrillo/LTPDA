% SETKEY Set the property 'key'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'key'.
%
% CALL:        obj.setKey('new key');
%              obj = setKey(obj, 'new key');
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setKey(varargin)
  
  %%% decide whether we modify the first plist, or create a new one.
  varargin{1} = copy(varargin{1}, nargout);
  
  varargin{1}.key = varargin{2};
  varargout{1} = varargin{1};
  
end
