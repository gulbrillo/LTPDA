% SIMPLIFY the units.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIMPLIFY the units.
%
% CALL:        a = a.simplify
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = simplify(v, exceptions)
  
  supported_prefixes = [-24:3:24];
  
  if numel(v.strs) < 2
    return
  end
  
  cache = copy(v, 1);
  v = copy(v, nargout);
  
  if nargin == 1
    exceptions = {};
  elseif nargin == 2
    if ischar(exceptions)
      exceptions = cellstr(exceptions);
    end
  end
  
  udef       = struct('vals', [], 'exps', []);
  ustruct    = struct();
  ex         = struct('strs', {{}}, 'vals', [], 'exps', []);
  remain_val = 0;
  
  % Create a structure with the different units as the fields
  % For example: 'mm um ks^2 s'
  %
  % ustruct.m: vals = [1e-3 1e-6]
  %            exps = [1 1]
  % ustruct.s: vals = [1e3 1]
  %            exps = [2 1]
  %
  % 1.) Initialize structure with empty 'vals' and 'exps' fields
  % 2.) Fill 'vals' and 'exps' fields
  for ii = unique(v.strs)
    if ~utils.helper.ismember(ii, exceptions)
      ustruct.(cell2mat(ii)) = udef;
    end
  end
  for ii = 1:numel(v.strs)
    if ~(utils.helper.ismember(v.strs{ii}, exceptions) || utils.helper.ismember(sprintf('%s%s', unit.val2prefix(v.vals(ii)), v.strs{ii}), exceptions))
      ustruct.(v.strs{ii}).vals = [ustruct.(v.strs{ii}).vals v.vals(ii)];
      ustruct.(v.strs{ii}).exps = [ustruct.(v.strs{ii}).exps v.exps(ii)];
    else
      % Collext all units which are in the exception list
      ex.strs = [ex.strs v.strs(ii)];
      ex.vals = [ex.vals v.vals(ii)];
      ex.exps = [ex.exps v.exps(ii)];
    end
  end
  
  % Simplify all supported units
  fields = fieldnames(ustruct);
  for ii = 1:numel(fields)
    field = fields{ii};
    
    exponent = sum(ustruct.(field).exps);
    if exponent == 0
      % The unit is canceled. Keep prefix
      remain_val = remain_val + sum(double(ustruct.(field).vals) .* ustruct.(field).exps);
      ustruct = rmfield(ustruct, field);
      continue
    end
    
    N = sum(double((ustruct.(field).vals)) .* ustruct.(field).exps ./ exponent);
    
    if ~any(int8(N) == supported_prefixes)
      % The value is not a supported prefix -> Don't simplify
      continue
    end
    
    % Simplify the units
    ustruct.(field).vals = N;
    ustruct.(field).exps = exponent;
  end
  
  % Prepare output unit-object
  % All information of the output object is in 'ustruct'
  v.strs = {};
  v.vals = [];
  v.exps = [];
  fields = fieldnames(ustruct);
  for ii = 1:numel(fields)
    field = fields{ii};
    strs = {};
    strs(1:numel(ustruct.(field).vals)) = {field};
    v.strs = [v.strs strs];
    v.vals = [v.vals ustruct.(field).vals];
    v.exps = [v.exps ustruct.(field).exps];
  end
  
  if remain_val ~= 0 && numel(v.vals) >= 1
    % It might be that the units are canceled out but not the prefixes
    % For example: 'mm m^-1 Hz'
    % Add in this case the prefix to the remaining unit
    % Result: 'mHz'
    [N, D] = rat(remain_val ./ v.exps);
    idx = find(D == 1);
    
    found = false;
    for ii = 1:numel(idx)
      valexp = N(idx(ii));
      if ~any(int8(valexp) == supported_prefixes)
        % It is not possible to add the remaining prefix to one of the other
        % units without having a supported prefix
        continue
      else
        found = true;
        break
      end
    end
    
    if ~found
      % If it is not possible to add the remaining prefix to an other unit
      % then return the input unit
      v.strs = cache.strs;
      v.vals = cache.vals;
      v.exps = cache.exps;
      return
    else
      idx = idx(ii);
    end
    
    v.vals(idx) = v.vals(idx) + N(idx);
    
    % It might be that it is possible to simplify the units again
    v.simplify(exceptions);
    
  elseif remain_val ~= 0 && isempty(v.vals)
    % It might be that the units are canceled out but not the prefixes
    % For example: 'mm m^-1'
    % But it is possible that there is no unit left. Return in this case
    % the input object.
    % Result: 'mm m^-1'
    v.strs = cache.strs;
    v.vals = cache.vals;
    v.exps = cache.exps;
    return
  end
  
  % Add units which are in the exception list
  v.strs = [v.strs ex.strs];
  v.vals = [v.vals ex.vals];
  v.exps = [v.exps ex.exps];
  
end
