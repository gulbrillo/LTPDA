% SETSELECTION Sets the property 'selection'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Set the property 'selection'.
%
% CALL:        obj = obj.setSelection(SELECTION);
%              obj = setSelection(obj, SELECTION);
%
% INPUTS:      obj       - single paramValue object
%              SELECTION - one of the following values
%                          paramValue.OPTIONAL
%                          paramValue.SINGLE
%                          paramValue.MULTI
%
% REMARK:      This method checks if the index is in range of the options
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setSelection(varargin)

  %%% Check number in inputs
  if nargin ~= 2
    error('### This method accepts only two inputs. The first one must be the object and the second one an integer.');
  end
  
  obj = varargin{1};
  selection = varargin{2};
  
  %%% Check the correctness of the inputs
  if ~isa(obj, 'paramValue') || numel(obj) ~= 1
    error('### The first input must be a single paramValue object.');
  end
  if ~isnumeric(selection)
    error('### Please specify a integer for the value index.');
  end

  obj = copy(obj, nargout);
  
  obj.selection = selection;

  %%% Prepare output
  varargout{1} = obj;

end
