% SETVALINDEX Sets the property 'valIndex'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'valIndex'.
%
% CALL:        obj = obj.setValIndex(idx);
%              obj = setValIndex(obj, idx);
%
% INPUTS:      obj - single paramValue object
%              idx - new index
%
% REMARK:      This method checks if the index is in range of the options
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setValIndex(varargin)

  %%% Check number in inputs
  if nargin ~= 2
    error('### This method accepts only two inputs. The first one must be the object and the second one an integer.');
  end
  
  obj = varargin{1};
  valIdx = varargin{2};
  
  %%% Check the correctness of the inputs
  if ~isa(obj, 'paramValue') || numel(obj) ~= 1
    error('### The first input must be a single paramValue object.');
  end
  if ~isnumeric(valIdx)
    error('### Please specify a integer for the value index.');
  end

  %%% Check if the new index is in range of the options.
  if valIdx > numel(obj.options)
    error('### The value index [%d] must be inside the range of the options [%d..%d]', valIdx, (numel(obj.options)>0), max(numel(obj.options)))
  end
  
  obj = copy(obj, nargout);
  
  obj.valIndex = valIdx;

  %%% Prepare output
  varargout{1} = obj;

end
