% SETDESC Set the property 'desc'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'desc'.
%
% CALL:        obj.setDesc('new description');
%              obj = setDesc(obj, 'new description');
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setDesc(varargin)

  %%% decide whether we modify the first plist, or create a new one.
  if nargout
    p = copy(varargin{1}, 1);
  else
    p = varargin{1};
  end
  
  p.desc = varargin{2};
  varargout{1} = p;
  
end

