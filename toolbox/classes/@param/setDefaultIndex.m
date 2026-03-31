% SETDEFAULTINDEX Sets the index which points to the default value to the input.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETDEFAULTINDEX Sets the index which points to the default
%              value to the input.
%
% CALL:        obj = obj.setDefaultIndex(index);
%
% INPUTS:      obj   - A single param object
%              index - An index to the default option which should to be set.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function p = setDefaultIndex(p, index)
  
  % Check input
  if numel(p) ~= 1
    error('### This method works only with one input parameter object.');
  end
  if ~isnumeric(index) && numel(index) ~= 1
    error('### This method works only with one input index.');
  end
  
  % Make a copy if the user doesn't use the modifier command
  p = copy(p, nargout);
  
  if isa(p.val, 'paramValue')
    if numel(p.val.options) >= index
      p.val.setValIndex(index);
    else
      error('### The number of param-options [%d] is for the new index [%d] not enough.', numel(p.val.options), index);
    end
  else
    warning('!!! This parameter [%s] has no options', utils.helper.val2str(p.key));
  end
  
end

