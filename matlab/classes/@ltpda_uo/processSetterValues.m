% PROCESSSETTERVALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PROCESSSETTERVALUES.
%                1. Checks if the value is in the plist
%                2. Checks if there are more than one value that the number
%                   of values are the same as the number of objects.
%                3. Replicate the values to the number of objects.
%
% CALL:        [objs, values] = processSetterValues(objs, pls, rest, pName)
%
% IMPUTS:      objs:  Array of objects
%              pls:   Array of PLISTs or empty array
%              rest:  Cell-array with possible values
%              pName: Property name of objs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [objs, values] = processSetterValues(objs, pls, rest, pName, defValue)
  
  % Check inputs
  if nargin < 5
    defValue = [];
  end
  
  % If pls contains only one plist with the single key of the property
  % name then use the value from the PLIST.
  if length(pls) == 1 && isa(pls, 'plist') && isparam_core(pls, pName)
    values{1} = find_core(pls, pName);
  else
    values = rest;
  end
  
  % Distinguish if the property accepts CELLS or not
  if iscell(defValue)
    % Check if the user have used a cell-array for the different cell-array values
    if numel(values)==1 && iscell(values{1}) && ~isempty(values{1}) && iscell(values{1}{1})
      values = values{1};
    end
  else
    % Check if the user have used a cell-array for the different values
    if numel(values)==1 && iscell(values{1})
      values = values{1};
    end
  end
  
  % Check the number of value
  if numel(values) > 1 && numel(values) ~= numel(objs)
    error('### Please specify one %s [n=%d] for each %s [n=%d], either in a plist or direct.', pName, numel(values), upper(class(objs)), numel(objs));
  end
  
  % Replicate the values in 'values' to the number of AOs
  if numel(values) == 1 && numel(objs) ~= 1
    value  = values{1};
    values = cell(size(objs));
    
    if isa(value, 'ltpda_obj')
      % Replicate a LTPDA object
      values = cellfun(@(x){copy(value, 1)}, values);
      
    elseif iscell(value)
      % Replicate a cell-array. It may happen that the cell-array contain a
      % LTPDA object.
      for rr=1:numel(values)
        newVal = cell(size(value));
        for nn=1:numel(value)
          if isa(value{nn}, 'ltpda_obj')
            newVal{nn} = copy(value{nn}, 1);
          else
            newVal{nn} = value{nn};
          end
        end
        values{rr} = newVal;
      end
      
    else
      
      values(:) = {value};
    end
  end
  
end

