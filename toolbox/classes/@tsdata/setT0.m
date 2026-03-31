% SETT0 Set the property 't0'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 't0'.
%
% CALL:              obj.setT0(time(0));
%              obj = obj.setT0(time(0)); create copy of the object
%
% INPUTS:      obj - must be a single data2D object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setT0(varargin)

  obj = varargin{1};
  val = varargin{2};

  %%% decide whether we modify the time-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 't0'
  obj.t0 = val;

  varargout{1} = obj;
end


