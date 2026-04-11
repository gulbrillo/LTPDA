% SETNSECS Set the property 'nsecs'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'nsecs'.
%
% CALL:              obj.setNsecs(1000);
%              obj = obj.setNsecs(1000); create copy of the object
%
% INPUTS:      obj - must be a single tsdata object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setNsecs(varargin)

  obj = varargin{1};
  val = varargin{2};

  %%% decide whether we modify the pz-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'nsecs'
  obj.nsecs = val;

  varargout{1} = obj;
end


