% FACTOR factorises units in to numerator and denominator units.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FACTOR factorises units in to numerator and denominator
%              units.
%
% CALL:        [num, den] = factor(units)
% 
% INPUTS:      'units'  - input unit object
% 
% OUTPUTS:     
%              'num'  - numerator unit object
%              'den'  - denominator unit object
% 
% CALL FOR PARAMETERS:
%
%              obj.factor('INFO') % Retrieve method information
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = factor(varargin)
  
  % Get unit objects
  units = [varargin{:}];
  
  if numel(units) ~= 1
    error('### Please give (only) one input unit object');
  end
  
  if isempty(units)
    num = [];
    den = [];
  else
    % get indices
    numi = units.exps>0;
    deni = units.exps<0;
    % Make input units from denominator
    den = unit();
    if any(deni)
      den.strs = units.strs(deni);
      den.exps = abs(units.exps(deni));
      den.vals = units.vals(deni);
    end
    % Make output units from numerator
    num = unit();
    if any(numi)
      num.strs = units.strs(numi);
      num.exps = units.exps(numi);
      num.vals = units.vals(numi);
    end
  end
  
  if nargout == 2
    varargout{1} = num;
    varargout{2} = den;
  else
    error('### Incorrect outputs');
  end
  
end

