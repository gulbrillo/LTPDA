% CTRANSPOSE overloads the ' operator for Analysis Objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CTRANSPOSE overloads the ' operator for Analysis Objects.
%
% CALL:        a = a1'    % only with data = cdata
% 
% This is just a wrapper of ao/transpose with the 'complex' parameter set
% to true.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'ctranspose')">Parameter Sets</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ctranspose(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = ao.getInfo('transpose', varargin{3});
    return
  end
    
  pl = plist('complex', true);
  if nargout > 0
    out = ltpda_run_method('transpose', varargin{:}, pl);
    varargout = utils.helper.setoutputs(nargout, out);
  else
    ltpda_run_method('transpose', varargin{:}, pl);
    varargout{1} = [varargin{:}];
  end

end

% END