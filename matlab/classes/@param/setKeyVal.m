% SETKEYVAL Set the properties 'key' and 'val'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the properties 'key' and 'val'
%
% CALL:        obj.setKeyVal('new key', 'new val');
%              obj = setKeyVal(obj, 'new key', 'new val');
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setKeyVal(varargin)
  
  %%% decide whether we modify the first plist, or create a new one.
  varargin{1} = copy(varargin{1}, nargout);
  
  varargin{1}.key = varargin{2};
  varargin{1}.val = varargin{3};
  varargout{1} = varargin{1};
  
end

