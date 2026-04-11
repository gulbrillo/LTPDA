% SETDX Set the property 'dx'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'dx'.
%
% CALL:              obj.setDx([1 2 3]);
%              obj = obj.setDx([1 2 3]); create copy of the object
%
% INPUTS:      obj - must be a single data2D object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setDx(varargin)

  obj = varargin{1};
  val = varargin{2};

  % decide whether we modify the object, or create a new one.
  obj = copy(obj, nargout);
  
  % Check if the x-axis already exist or not.
  if isempty(obj.xaxis)
    createXaxis(obj);
  end
  
%   % set 'dx'
%   if numel(val) == 1 && isempty(obj.x)
%     % For even sampled data expand the error to the size of the y-axis
%     val = val*ones(size(obj.y));
%   end
%   obj.xaxis.setDdata(val);
  % set 'dx'
  obj.xaxisDdataWillChange(val);
  obj.xaxis.setDdata(val);
  obj.xaxisDdataDidChange(val);

  varargout{1} = obj;
end

