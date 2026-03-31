% TABLE display the an array of timespan objects in a table.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   TABLE display the an array of timespan objects in a table.
%                The table have the format:
%                <start> <stop> <name> <description>
%
% CALL:          table(timespan)
%
% <a href="matlab:utils.helper.displayMethodInfo('timespan', 'table')">Parameters Description</a>
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
  
  % Collect all TIMESPAN objects
  ts = utils.helper.collect_objects(varargin(:), 'timespan', in_names);
  
  tableData = cell(2+numel(ts), 5);
  
  % Define table header
  tableData(1,:) = {'', 'Start Time', 'Stop Time', 'Name', 'Description'};
  
  %
  no     = cellfun(@(x) num2str(x), num2cell(1:numel(ts)), 'UniformOutput', false)';
  tStart = disp([ts.startT]);
  tStop  = disp([ts.endT]);
  names  = {ts.name}';
  desc   = {ts.description}';
  
  tableData(3:end,1) = no;
  tableData(3:end,2) = tStart;
  tableData(3:end,3) = tStop;
  tableData(3:end,4) = names;
  tableData(3:end,5) = desc;
  
  % Define the lines below the PEST names
  colMax = max(cellfun(@length, tableData), [], 1);
  fcn = @(x) repmat('_', 1, x);
  lines = arrayfun(fcn, colMax(2:end)+2, 'UniformOutput', false);
  tableData(2, 2:end) = lines;
  
  % Center columns 2-3
  tableData(:, 2:3) = centerText(tableData(:, 2:3));
  % Align left columns 1, 4 + 5
  tableData(:, 1) = alignLeft(tableData(: ,1));
  tableData(:, 4:5) = alignLeft(tableData(: ,4:5));
  
  % Print the cell-array
  fprintf('<strong>%s</strong>', tableData{1,:}); fprintf('\n');
  fprintf('<strong>%s</strong>', tableData{2,:}); fprintf('\n');
  for ii=3:size(tableData,1)
    fprintf('<strong>%s</strong>', tableData{ii,1});
    fprintf('%s', tableData{ii, 2:end});
    fprintf('\n');
  end
  
end

function out = alignLeft(in)
  
  % Define the number of pads
  matLen = cellfun(@length, in);
  colMax = max(matLen, [], 1);
  pads   = repmat(colMax, size(matLen,1), 1) - matLen + 2;
  
  % Define right spaces
  SpaceFcn = @(x) repmat(' ', 1, x);
  leftSpace = arrayfun(SpaceFcn, min(pads,1), 'UniformOutput', false);
  rightSpace = arrayfun(SpaceFcn, pads - cellfun(@length, leftSpace), 'UniformOutput', false);
  
  % Concatenate the cell-arrays
  out = strcat(leftSpace, in, rightSpace);
  
end

function out = centerText(in)
  
  % Define the number of pads
  matLen = cellfun(@length, in);
  colMax = max(matLen, [], 1);
  pads   = repmat(colMax, size(matLen,1), 1) - matLen + 2;
  
  % Define left and right spaces
  SpaceFcn = @(x) repmat(' ', 1, x);
  leftSpace = arrayfun(SpaceFcn, floor(pads/2), 'UniformOutput', false);
  rightSpace = arrayfun(SpaceFcn, pads - cellfun(@length, leftSpace), 'UniformOutput', false);
  
  % Concatenate the cell-arrays
  out = strcat(leftSpace, in, rightSpace);
  
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


