% TIMEAVERAGE Averages time series intervals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Averages time series intervals and return a reduced time
% series where each point represents the average of a stretch of data.
% Despite the name this method can perform some different operations on the
% data stretches or apply a user supplied function. Different functions can
% be applied to X and Y data.
%
% CALL:        BS = timeaverage(A1, A2, A3, ..., PL)
%
% INPUTS:      AN   - time series AOs
%              PL   - parameters list
%
% OUTPUTS:     BS   - array of AOs
% 
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'timeaverage')">Parameters Description</a>
%
% EXAMPLES:
% 
% >> times_list = [ 0 100 200 300 400 500 ]
% >> m = timeaverage(a, plist('times', times_list))
% >> timeaverage(a, plist('start time', 0, 'duration', 100, 'decay', 10, 'repetitions', 3))
% >> timeaverage(a, plist('times', times_list, 'function', 'center'))
% >> m = timeaverage(a, plist('times', times_list, 'function', @mean))
% >> m = timeaverage(a, plist('times', times_list, 'xfunction', @min, 'yfunction', @mean))
%
% NOTES: The intervals are defined as ti <= x < te where ti is the start
% time and te is the end time of each interval. If not specified the TIMES
% vector is constructed from other parameters using the following schema
% repeated accordingly a number of times specified with the REPETITIONS
% parameter.
%
%       settling      duration      decay     settling      duration
%    |------------|##############|---------|------------|##############|---
%  START
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = timeaverage(varargin)
  
  % check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % decide on a deep copy or a modify
  bs = copy(as, nargout);
    
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  % accept spaces dashes or underscores
  pl = fixpnames(pl);

  % splitting by time takes the precedence
  times = find_core(pl, 'times');
  
  % otherwise construct a times vector based on other parameters
  if isempty(times)
    start    = find(pl, 'start', find_core(pl, 'start time'));
    repeat   = find(pl, 'repetitions');
    duration = find(pl, 'duration');
    settling = find(pl, 'settling', find_core(pl, 'settling time'));
    decay    = find(pl, 'decay', find_core(pl, 'decay time'));
    
    times = zeros(repeat*2, 1);
    for kk = 1:repeat
      times(2*kk-1)   = start + settling*kk + duration*(kk-1) + decay*(kk-1);
      times(2*kk) = start + settling*kk + duration*kk + decay*(kk-1);
    end
  end
    
  % select which functions to apply to the data stretches
  method = lower(find_core(pl, 'method'));
  funct  = find_core(pl, 'function');
  if isempty(funct)
    funct = method;
  end
  xfunct = find(pl, 'xfunction', funct);
  yfunct = find(pl, 'yfunction', funct);
  if isempty(xfunct)
    xfunct = funct;
  end
  if isempty(yfunct)
    yfunct = funct;
  end
  
  % loop over input AOs
  for jj = 1:numel(bs)
    
    % check input data
    if ~isa(bs(jj).data, 'tsdata')
      warning('LTPDA:isNotTsdata', '!!! %s is not a tsdata AO and will be ignored', bs(jj).name);
      continue;
    end
    
    % support input via timespan vector
    switch class(times)
      case 'double'
        times_vector = times;
      case {'timespan', 'time'}
        times_vector = times.double - bs(jj).t0.double;
    end
  
    [xmean, ymean, dy] = split_and_apply(bs(jj).x, bs(jj).y, times_vector, xfunct, yfunct);
    
    % assign values
    bs(jj).setDy([]); % clear to avoid warnings when we set the data shape
    bs(jj).setXY(xmean, ymean);
    bs(jj).setDy(dy);
    
    % set name
    bs(jj).name = sprintf('%s(%s)', mfilename, ao_invars{jj});
    % add history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
    
  end % loop over analysis objects
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
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
  % build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  % set the default property of the method as modifier or not
  ii.setModifier(true);
  % set the minumum number of inputs and outputs for the block
  ii.setArgsmin(1);
  ii.setOutmin(1);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist;
  
  % method
  p = param({'method','Reduction method to apply to data stretches.'}, ...
    {1, {'MEAN', 'MEDIAN', 'MAX', 'MIN', 'RMS', 'CENTER'}, paramValue.SINGLE});
  pl.append(p);
  
  % function
  p = param({'function', ['Function to apply to data stretches. It can be' ...
    ' a function name or a function handle to a function that accepts'...
    ' a vector and returns a scalar.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % x function
  p = param({'xfunction', ['Function to apply to X data stretches. It can be' ...
    ' a function name or a function handle to a function that accepts'...
    ' a vector and returns a scalar.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % y function
  p = param({'yfunction', ['Function to apply to Y data stretches. It can be' ...
    ' a function name or a function handle to a function that accepts'...
    ' a vector and returns a scalar.']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % times
  p = param({'times', ['An array of start-stop times to split by.<br>' ...
    'Array of timespan or time objects are also supported.']}, paramValue.DOUBLE_VALUE([]));
  pl.append(p);
  
  % start time
  p = param({'start time', 'Start time of the measurement.'}, paramValue.DOUBLE_VALUE(0));
  pl.append(p);
  
  % duration
  p = param({'duration', 'Duration of each cicle.'}, paramValue.DOUBLE_VALUE(0));
  pl.append(p);
  
  % repetitions
  p = param({'repetitions', 'Number of cycles.'}, paramValue.DOUBLE_VALUE(1));
  pl.append(p);
  
  % settling time
  p = param({'settling time', 'Settling time in each cicle.'}, paramValue.DOUBLE_VALUE(0));
  pl.append(p);            
      
  % decay time
  p = param({'decay time', 'Decay time in each cicle.'}, paramValue.DOUBLE_VALUE(0));
  pl.append(p);            
  
end


function pl = fixpnames(pl)
  % replace underscores and dashes in parameters names with spaces
  if isa(pl, 'plist')
    for ii = 1:pl.nparams
      pl.params(ii).setKey(strrep(strrep(pl.params(ii).key, '_', ' '), '-', ' '));
    end
  end
end


function xmean = center(x) %#ok<DEFNU>
  % computes the center of an interval defined by
  % the minimum and maximum values in an array
  xmean = mean([min(x) max(x)]);
end


function [xmean, ymean, dy] = split_and_apply(x, y, times, xfunct, yfunct)
  
  % supporting a call with times defined as:
  % [tstart_1 tend_1;tstart_2 tend_2;tstart_3 tend_3]

  % check that the times vector has the right dimensions
  if mod(numel(times), 2)
    error('### times defines times intervals with an even number of points');
  end

  if size(times, 2) == 2
    times_vec = [];
    for jj = 1:size(times, 1)
      times_vec = [times_vec; times(jj, 1); times(jj, 2)];
    end
    times = times_vec;
  end
  
  % number of intervals
  nint = numel(times) / 2;
  
  xmean = zeros(nint, 1);
  ymean = zeros(nint, 1);
  
  % for the mean we are able to compute uncertainty too
  if ischar(yfunct) && strcmp(yfunct, 'mean')
    dy = zeros(nint, 1);
  else
    dy = [];
  end
  
  % loop over the intervals
  for kk = 1:nint
    
    % create index of the interval
    is = times(2*kk-1);
    ie = times(2*kk);
    idx = x >= is & x < ie;
    
    % apply functions to interval
    xmean(kk) = feval(xfunct, x(idx));
    ymean(kk) = feval(yfunct, y(idx));
    
    if ~isempty(dy)
      % compute uncertainty as the standard deviation of the mean
      dy(kk) = std(y(idx)) / sqrt(length(x(idx)));
    end
    
  end  
end
