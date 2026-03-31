% LTPDA_RUN_METHOD runs an LTPDA method inside a script environment to
% ensure that callerIsMethod returns false and history will always be
% added. This can be useful when objects created deep inside a call-stack
% need to have history added.
% 
% CALL
%         out = ltpda_run_method(fcn, varargin)
% 
% VERSION: $Id$
% 
function varargout = ltpda_run_method(fcn, varargin)
  
  if nargout > 0
    out = feval(fcn, varargin{:}); 
    varargout = utils.helper.setoutputs(nargout, out);
  else
    feval(fcn, varargin{:});
  end
  
end
