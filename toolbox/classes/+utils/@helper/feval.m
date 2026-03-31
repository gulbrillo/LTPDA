% FEVAL a wrapper of MATLAB's feval
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FEVAL a wrapper of MATLAB's feval
%
% NOTE: this is particularly useful to run any LTPDA method in such a way
% that 'caller is method' is always false and as such history will be
% added.
% 
% CALL:        out = feval(fhandle, ...)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = feval(fh, varargin)
  
  if ischar(fh)
    fh = str2func(fh);
  end
  
  [varargout{1:nargout}] = feval(fh, varargin{:});
end

