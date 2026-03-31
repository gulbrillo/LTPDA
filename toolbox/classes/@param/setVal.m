% SETVAL Set the property 'val'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'val'.
%
% CALL:        obj = obj.setVal('new val');
%              obj.setVal('new val');
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setVal(varargin)
  
  %%% decide whether we modify the first plist, or create a new one.
  if nargout
    p = copy(varargin{1}, 1);
  else
    p = varargin{1};
  end
  
  p.val = varargin{2};
  varargout{1} = p;
  
end

