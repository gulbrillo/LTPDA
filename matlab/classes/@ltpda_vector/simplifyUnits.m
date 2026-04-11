% SIMPLIFYUNITS simplify the 'units' property of the object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIMPLIFYUNITS simplify the 'units' property of the object.
%
% CALL:        obj = simplifyUnits(obj, prefixes, exceptions)
%              obj = obj.simplifyUnits(prefixes, exceptions)
%
% INPUTS:      obj        - Must be a single ltpda_vector object.
%              prefixes   - Flag if the method apply the prefixes to the data.
%              exceptions - Cell array with exceptions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function simplifyUnits(varargin)
  
  % Get inputs
  obj        = varargin{1};
  prefixes   = varargin{2};
  exceptions = varargin{3};
  
  if isempty(obj.units)
    return
  end
  
  % Check inputs
  if ~isa(obj, 'ltpda_vector') && numel(obj) ~= 1
    error('### The first input must be a single ltpda_vector object.')
  end
  if ~islogical(prefixes)
    error('### The second input must be a logical');
  end
  if ~iscell(exceptions)
    error('### The third input must be a cell-array.');
  end
  
  % Check outputs
  if nargout ~= 0
    error('### Call this method as a modifier');
  end
  
  % Count the prefix values first before we compute this value to the
  % data because then is the error not so large.
  prfval = 0;
  
  % simplify prefixes first
  if prefixes
    yun = copy(obj.units, true);
    vals = yun.vals;
    exps = yun.exps;
    
    % Get the different unit-string of the axis.
    % Use for this the char-method because this method adds the prefix
    % to the unit.
    yuns = yun.split();
    strs = cell(size(yuns));
    for kk = 1:numel(yuns)
      strs{kk} = char(yuns(kk));
    end
    
    % Run over all y-units parts because it might be that one of the parts is
    % in the exception list.
    for ii = 1:numel(vals)
      str = strs{ii}(2:end-1);
      str = strtok(str, '^');
      if ~(any(ismember(str, exceptions)))
        prfval   = prfval + (double(vals(ii))) .* exps(ii);
        vals(ii) = 0;
      end
    end
    yun.setVals(vals);
    obj.units = yun;
  end
  
  % Multiply the prefix value to the y and dy values
  obj.data  = (obj.data  .* 10.^prfval);
  obj.ddata = (obj.ddata .* 10.^prfval);
  
  % simplify the units
  if ~isempty(obj.units)
    obj.units = simplify(obj.units, exceptions);
  end
  
end
