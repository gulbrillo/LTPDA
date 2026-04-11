% LN overloads the log operator for analysis objects. Natural logarithm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LN overloads the log operator for analysis objects.
%              Natural logarithm.
%              LN(ao) is the natural logarithm of the elements of ao.data.
%
% CALL:        ao_out = ln(ao_in);
%              ao_out = ln(ao_in, pl);
%              ao_out = ln(ao1, pl1, ao_vector, ao_matrix, pl2);
%
% PARAMETERS:  see help for data2D/applymethod for additional parameters
% 
% NOTE: ao/ln is just a wrapper for ao/log.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'ln')">Parameter Sets</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = ln(varargin)
  
  if nargout > 0
    out = ltpda_run_method('log', varargin{:});
    varargout = utils.helper.setoutputs(nargout, out);
  else
    ltpda_run_method('log', varargin{:});
    varargout{1} = [varargin{:}];
  end
  
end

% END