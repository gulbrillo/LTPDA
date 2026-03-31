% ADDCHILDREN Add children to this minfo.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Add a child info object
%
% CALL:              obj.addChildren(mi1, mi2);
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = addChildren(varargin)

  obj = varargin{1};
  infos = [varargin{2:end}];

  obj.children = [obj.children infos];

  varargout{1} = obj;
end

