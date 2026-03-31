% SETENBW Set the property 'enbw'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'enbw'.
%
% CALL:              obj.setEnbw(val);
%              obj = obj.setEnbw(val); create copy of the object
%
% INPUTS:      obj - must be a single data2D object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setEnbw(varargin)

  obj = varargin{1};
  val = varargin{2};

  %%% decide whether we modify the pz-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'enbw'
  obj.enbw = val;

  varargout{1} = obj;
end

