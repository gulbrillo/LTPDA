% SETDESCRIPTION Set the property 'description'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'description'.
%
% CALL:              obj.setDescription('describe something');
%              obj = obj.setDescription('describe something'); create copy of the object
%
% INPUTS:      obj - must be a single minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setDescription(varargin)

  obj = varargin{1};
  val = varargin{2};

  %%% decide whether we modify the minfo-object, or create a new one.
  obj = copy(obj, nargout);

  %%% set 'description'
  obj.description = val;

  varargout{1} = obj;
end

