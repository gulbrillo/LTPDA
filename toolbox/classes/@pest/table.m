% TABLE display the parameters from PEST objects in a java table.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   TABLE display the parameters from PEST objects in a java table.
%
% CALL:          table(pest)
%
%                [tableText, colNames] = table(pest)
%                tableText = cell array containing table body text
%                colNames = cell array containing table column names
%
% <a href="matlab:utils.helper.displayMethodInfo('pest', 'table')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = table(varargin)

% Check if this is a call for parameters
if utils.helper.isinfocall(varargin{:})
  varargout{1} = getInfo(varargin{3});
  return
end

import utils.const.*
utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

% Collect input variable names
in_names = cell(size(varargin));
try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

% Collect all PEST objects
[ps, ps_invars] = utils.helper.collect_objects(varargin(:), 'pest', in_names);

% Get PEST names from the object or from the input variable name
pestNames = {ps.name};
emptyIdx = cellfun(@isempty, pestNames);
pestNames(emptyIdx) = ps_invars(emptyIdx);

% Get all parameter names
% The flag 'first' is since R2012b a legacy option. But we still support
% R2011a. That's the reason why we don't use the option 'stable'.
% To get with 'first' the same result as with 'stable' must we sort the
% indices.
allParamNames = [ps.names];
[~, idx] = unique(allParamNames, 'first');
allParamNames = allParamNames(sort(idx));

% Create column names
colNames = cell(1, numel(pestNames));
for ii=1:numel(pestNames)
  colNames{ii*3-2} = sprintf('%s', pestNames{ii});
  colNames{ii*3-1}   = sprintf('%s (error)', pestNames{ii});
  colNames{ii*3}   = sprintf('Units');
end

% Create cell array for the table data
tableData = cell(numel(allParamNames) + 2, numel(colNames) + 1);
tableData(1, 2:end) = colNames;       % Add column names to the table data
tableData(3:end, 1) = allParamNames;  % Add row    names to the table data

% Find the indexes of a subset cell-array in a cell-array
cellfind = @(string) (@(array) find(strcmp(string, array)));

% Fill the table data with the values
for ii=1:numel(ps)
  hasErrors = ~isempty(ps(ii).dy);
  hasUnits  = ~isempty(ps(ii).yunits);
  all    = allParamNames;
  subset = ps(ii).names;
  idx = cellfun(cellfind(all), subset, 'uniformoutput', false);
  idx = sort([idx{:}]);
  
  yStr  = arrayfun(@(x) sprintf('%2.5g', x), reshape(ps(ii).y,  [], 1), 'UniformOutput', false);
  tableData(idx+2, 1 + ii*3-2) = yStr;
  if hasErrors
    dyStr = arrayfun(@(x) sprintf('%2.4g', x), reshape(ps(ii).dy,  [], 1), 'UniformOutput', false);
  else
    dyStr = repmat({''}, size(yStr));
  end
  tableData(idx+2, 1 + ii*3-1)   = dyStr;
  
  if hasUnits
    unitStr = repmat({''}, size(yStr));
    for kk=1:numel(ps(ii).yunits)
      if ~isempty(ps(ii).yunits(kk).strs)
        unitStr{kk} = char(ps(ii).yunits(kk));
      end
    end
  else
    unitStr = repmat({''}, size(yStr));
  end
  tableData(idx+2, 1 + ii*3)   = unitStr;
end

tableData = removeEmptyColumns(tableData);

% Define the lines below the PEST names
colMax = max(cellfun(@length, tableData), [], 1);
fcn = @(x) repmat('_', 1, x);
lines = arrayfun(fcn, colMax(2:end)+2, 'UniformOutput', false);
tableData(2, 2:end) = lines;

% Define the number of pads
matLen = cellfun(@length, tableData);
colMax = max(matLen, [], 1);
pads   = repmat(colMax, size(matLen,1), 1) - matLen + 2;

% Define the left and right spaces
SpaceFcn = @(x) repmat(' ', 1, x);
leftSpace = arrayfun(SpaceFcn, floor(pads/2), 'UniformOutput', false);
rightSpace = arrayfun(SpaceFcn, pads - cellfun(@length, leftSpace), 'UniformOutput', false);

% Concatenate the cell-arrays
out = strcat(leftSpace, tableData, rightSpace);

% Print the cell-array
% return outputs if requested (useful for autoreporter)
if nargout == 2
  varargout{1} = tableData(3:end,:);
  varargout{2} = ['parameter' colNames];
else
  fprintf('<strong>%s</strong>', out{1,:}); fprintf('\n');
  fprintf('<strong>%s</strong>', out{2,:}); fprintf('\n');
  for ii=3:size(out,1)
    fprintf('<strong>%s</strong>', out{ii,1});
    fprintf('%s', out{ii, 2:end});
    fprintf('\n');
  end
end



end

function tableData = removeEmptyColumns(tableData)

sz = size(tableData);

for ii=sz(2):-1:2
  col = tableData(3:end, ii);
  if all(cellfun(@isempty, col))
    tableData(:, ii) = [];
  end
end

end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
if nargin == 1 && strcmpi(varargin{1}, 'None')
  sets = {};
  pl   = [];
else
  sets = {'Default'};
  pl   = getDefaultPlist;
end
% Build info object
ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
ii.setModifier(false);
ii.setOutmin(0);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
persistent pl;
if exist('pl', 'var')==0 || isempty(pl)
  pl = buildplist();
end
plout = pl;
end

function pl = buildplist()
pl = plist();
end


