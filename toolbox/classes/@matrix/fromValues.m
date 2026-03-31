% Construct a matrix object with multiple AOs built from input values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromValues
%
% DESCRIPTION: Construct a matrix object with multiple AOs built from input
%              values.
%
% CALL:        matrix = matrix.fromValues(obj, pli)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = fromValues(obj, pli, callerIsMethod)
  
  import utils.const.*
  utils.helper.msg(msg.PROC2, 'Constructing an matrix object with multiple AOs built from input values.');
  
  % get AO info
  ii = matrix.getInfo('matrix', 'From Values');
  
  pl = applyDefaults(ii.plists, pli);
  values = pl.find_core('values');
  yunits = pl.find_core('yunits');
  names  = pl.find_core('names');
  
  % Some plausibility checks
  if ~isnumeric(values)
    error('### The values must be from the type double');
  end
  nvals = numel(values);
  
  if ischar(yunits)
    yunits = cellstr(yunits);
  end
  if numel(yunits) > 1 && numel(yunits) ~= nvals
    error('### The number of yunits must be the same as the numer of values %d <-> %d', numel(yunits), nvals);
  end
  if numel(yunits) == 1
    % Replicate the single unit for all AOs
    yunits = repmat(yunits, 1, nvals);
  end
  
  if ischar(names)
    names = cellstr(names);
  end
  if numel(names) > 1 && numel(names) ~= nvals
    error('### The number of names must be the same as the numer of values %d <-> %d', numel(names), nvals);
  end
  if numel(names) == 1
    % Replicate the single name for all AOs
    names = repmat(names, 1, nvals);
  end
  
  for nn = 1:numel(values)
    
    % Create the AO
    a = ao(values(nn));
    
    % Set the name
    if ~isempty(names)
      a.setName(names{nn});
    end
  
    % Set the y-units
    if ~isempty(yunits)
      a.setYunits(yunits{nn});
    end
  
    obj.objs = [obj.objs a];
    
  end
  
  % Reshape the inside objects
  obj.objs = reshape(obj.objs, size(values));
  
  % Add history
  if callerIsMethod
    % do nothing
  else
    obj.addHistory(ii, pl, [], []);
  end
  
  % Set object properties provided in the plist
  obj.setObjectProperties(pl);
  
end
