% SETTOFFSET Set the property 'toffset'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'toffset'.
%
% CALL:              obj.setToffset(1000);
%              obj = obj.setToffset(1000); create copy of the object
%
% INPUTS:      obj - must be a single tsdata object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setToffset(varargin)

  obj = varargin{1};
  val = varargin{2};

  %%% decide whether we modify the tsdata object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'toffset'
  obj.toffset = val;

  varargout{1} = obj;
end


