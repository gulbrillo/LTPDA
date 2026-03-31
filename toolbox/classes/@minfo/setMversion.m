% SETMVERSION Set the property 'mversion'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'mversion'.
%
% CALL:              obj.setMversion([1 2 3]);
%              obj = obj.setMversion([1 2 3]); create copy of the object
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setMversion(varargin)

  obj = varargin{1};
  val = varargin{2};

  %%% decide whether we modify the minfo-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'mversion'
  obj.mversion = val;

  varargout{1} = obj;
end

