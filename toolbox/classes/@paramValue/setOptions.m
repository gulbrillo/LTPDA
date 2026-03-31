% SETOPTIONS Sets the property 'options'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'options'.
%
% CALL:        obj = obj.setOptions(options);
%              obj = setOptions(obj, options);
%
% INPUTS:      obj     - single paramValue object
%              options - new options
%
% REMARK:      This method checks if the options have at lease as much
%              elements as the 'valIndex'.
%              If 'valIndex' is equal to -1 then is it possible to set each
%              cell to options.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setOptions(varargin)

  %%% Check number in inputs
  if nargin ~= 2
    error('### This method accepts only two inputs. The first one must be the object and the second one an integer.');
  end
  
  obj = varargin{1};
  options = varargin{2};
  
  %%% Check the correctness of the inputs
  if ~isa(obj, 'paramValue') || numel(obj) ~= 1
    error('### The first input must be a single paramValue object.');
  end
  if ~iscell(options)
    error('### Please specify a cell for the options.');
  end
  
  %%% Check if the 'options' have enough elements
  if (obj.valIndex >= 1) && (obj.valIndex > numel(options))
    error('### The ''options'' must have at lease as much elements [%d] as the ''valIndex'' [%d]', numel(options), obj.valIndex);
  end
  
  obj = copy(obj, nargout);
  
  obj.options = options;

  %%% Prepare output
  varargout{1} = obj;

end
