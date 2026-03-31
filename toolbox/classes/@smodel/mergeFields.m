% MERGEFIELDS merges properties (name/values) of smodels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MERGEFIELDS merges properties (name/values) of smodels 
%              in preparation of dual operations
%
% CALL:        mergeFields(mdl1, mdl2, mdl, name, value)
%
% PARAMETERS:  op       - MATLAB operation name
%              opname   - Name for displaying
%              opsym    - Operation symbol
%              infoObj  - minfo object
%              pl       - default plist
%              fcnArgIn - Input argument list of the calling fcn.
%              varNames - Variable names of the input
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Merge Fields and Their Values
%--------------------------------------------------------------------------
function varargout = mergeFields(varargin)
  
  mdl1 = varargin{1};
  mdl2 = varargin{2};
  mdl  = varargin{3};
  name  = varargin{4};
  value = varargin{5};
  
  switch lower(name)
    case {'params', 'aliasnames', 'xvar'}
    otherwise
      error('Unknown field %s', name);
  end
  
  % Start appending all the entries: (name)
  mdl.(name) = [mdl1.(name) mdl2.(name)];

  % If dealing with xvar+trans, we need to expand the trans
  % This will be discontinued in future releases
  if strcmpi(value, 'trans') || strcmpi(value, 'xunits')
    n_vals = numel(mdl1.(value));
    n_xvar = numel(mdl1.(name));
    if n_vals == 1 && n_vals ~= n_xvar
      valvec1 = cell(1, n_xvar);
      for  jj = 1:n_xvar
        valvec1(jj) = mdl1.(value);
      end
      mdl1.(value) = valvec1;
    end
    n_vals = numel(mdl2.(value));
    n_xvar = numel(mdl2.(name));
    if n_vals == 1 && n_vals ~= n_xvar
      valvec2 = cell(1, n_xvar);
      for  jj = 1:n_xvar
        valvec2(jj) = mdl2.(value);
      end
      mdl2.(value) = valvec2;
    end
  end
  
  % Start appending all the entries: (values)
  if isempty(mdl1.(value))
    values1 = cell(size(mdl1.(name)));
  else
    values1 = mdl1.(value);
  end
  if isempty(mdl2.(value))
    values2 = cell(size(mdl2.(name)));
  else
    values2 = mdl2.(value);
  end
  mdl.(value) = [values1 values2];

  % Check if the (name) are overlapping
  [c, i1, i2] = intersect(mdl1.(name), mdl2.(name));
  if isempty(c)
    % No overlap: nothing to do
  else
    % Some overlap: check the (value)
    for kk = 1: numel(c)
      % xunits are always a vector
      if strcmpi(value, 'xunits')
        val1 = values1(i1(kk));
        val2 = values2(i2(kk));
      else
        val1 = values1{i1(kk)};
        val2 = values2{i2(kk)};
      end
      prop_name = c(kk);
      if ~isempty(val1)
        % (value) is defined in 1st model        
        if ~isempty(val2)
          % (value) is defined in 2nd model
          if ~isequal(val1, val2)
            % the (value) are different, give error
            error('LTPDA:err:ContentMismatchMismatch', 'The [%s] fields do not match, because ''%s'' are different!', name, prop_name{:});
          else
            % the (value) are equal, nothing to do
          end
        else
          % (value) is not defined in 2nd model, take value from 1st
          % Take the (name) position in the cell-array
          idx = strcmp(mdl.(name), prop_name);
          mdl.(value)(idx) = {val1 val1};
        end
      else
        % (value) is not defined in 1st model
        if ~isempty(val2)
          % (value) is defined in 2nd model, take value from 2nd
          % Take the (name) position in the cell-array
          idx = strcmp(mdl.(name), prop_name);
          mdl.(value)(idx) = {val2 val2};
        else
          % (value) is not defined in 2nd model, nothing to do
        end
      end
    end
    
    % All identical. Go ahead and merge
    [mdl.(name), idx1, idx2] = unique(mdl.(name));
    mdl.(value) = mdl.(value)(idx1);
  end
  
  % Set output
  varargout = {};
end
