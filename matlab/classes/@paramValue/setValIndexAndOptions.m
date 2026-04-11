% SETVALINDEXANDOPTIONS Sets the property 'valIndex' and 'options'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'valIndex' and 'options'.
%
% CALL:        obj = obj.setValIndexAndOptions(idx, options);
%              obj = setValIndexAndOptions(obj, idx, options);
%
% INPUTS:      obj - single paramValue object
%              idx - new index
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setValIndexAndOptions(varargin)

  %%% Check number in inputs
  if nargin ~= 3
    error('### This method accepts only three inputs. The first one must be the object, the second one an integer and the third the options.');
  end
  
  obj = varargin{1};
  valIdx = varargin{2};
  options = varargin{3};
  
  %%% Check the correctness of the inputs
  if ~isa(obj, 'paramValue') || numel(obj) ~= 1
    error('### The first input must be a single paramValue object.');
  end
  if ~isnumeric(valIdx)
    error('### Please specify a integer for the value index.');
  end
  if ~iscell(options)
    error('### Please specify a cell for the options.');
  end

  %%% Check if the new index is in range of the options.
  if valIdx > numel(options)
    error('### The value index [%d] must be inside the range of the options [%d..%d]', valIdx, min(numel(options)), max(numel(options)))
  end
  
  if nargout == 0
    % do nothing
  else
    obj = copy(obj, 1);
  end
  
  obj.valIndex = valIdx;
  obj.options  = options;

  %%% Prepare output
  varargout{1} = obj;

end
