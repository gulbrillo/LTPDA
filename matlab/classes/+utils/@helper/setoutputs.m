% SETOUTPUTS sets the output cell-array for LTPDA methods.
%
% CALL
%         out = utils.helper.setoutputs(nout, objs)
%
% Given the number of output arguments and the array of output objects,
% this method does:
%
% 1) if nout == 1, returns a single cell array of objects
% 2) if nout == numel(objs), returns a cell-array with one object per cell
% 3) all other cases, it throws an error
%
% This is intended for use in LTPDA methods like this:
%
% varargout = utils.helper.setoutputs(nargout, objs)
%

function out = setoutputs(nout, bs)
  
  if nout == 0
    out = {bs};
  elseif nout == 1
    out = {bs};
  elseif nout == numel(bs)
    out = cell(size(bs));
    for ii = 1:numel(bs)
      out{ii} = bs(ii);
    end
  else
    error('Mismatch between number of ouput objects and output arguments');
  end
  
end
