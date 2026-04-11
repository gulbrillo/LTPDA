% SETNAVS Set the property 'navs'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'navs'.
%
% CALL:              obj.setNavs(val);
%              obj = obj.setNavs(val); create copy of the object
%
% INPUTS:      obj - must be a single data2D object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setNavs(varargin)

  obj = varargin{1};
  val = varargin{2};

  %%% decide whether we modify the pz-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'navs'
  obj.navs = val;

  varargout{1} = obj;
end

