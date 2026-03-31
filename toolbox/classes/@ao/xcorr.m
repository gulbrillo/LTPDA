% XCORR makes cross-correlation estimates of the time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XCORR makes cross-correlation estimates of the time-series
%              objects in the input analysis objects. The cross-correlation is
%              computed using MATLAB's xcorr (>> help xcorr).
%
% CALL:        b = xcorr(a1,a2,pl)
%
% INPUTS:      b     - output analysis objects
%              a1,a2 - input analysis objects (only two)
%              pl    - input parameter list
%
%              The function makes correlation estimates between a1 and a2.
%
%              If only on AO is input, the auto-correlation is computed.
%
%              If the last input argument is a parameter list (plist) it is used.
%              The following parameters are recognised.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'xcorr')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = xcorr(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  if nargout == 0
    error('### xcorr cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  na = numel(as);
  if na > 2
    error('### XCORR accepts only two AOs to cross-correlate.');
  end
  
  %----------------- Keep the history to suppress the history of the
  %----------------- intermediate steps
  inhists = [as(:).hist];
  
  %----------------- Resample all AOs
  copies = zeros(size(as));
 
  fsmax = findFsMax(as);
  fspl  = plist('fsout', fsmax);
  for jj = 1:na
    % check this is a time-series object
    if ~isa(as(jj).data, 'tsdata')
      error('### ltpda_xspec requires tsdata (time-series) inputs.');
    end
    % Check Fs
    if as(jj).fs ~= fsmax
      utils.helper.msg(msg.PROC1, 'resampling AO %s to %f Hz', as(jj).name, fsmax);
      % Make a deep copy so we don't
      % affect the original input data
      as(jj) = copy(as(jj), 1);
      copies(jj) = 1;
      as(jj).resample(fspl);
    end
  end
  
  %----------------- Truncate all vectors
  
  % Get shortest vector
  utils.helper.msg(msg.PROC1, '*** Truncating all vectors...');
  lmin = findShortestVector(as);
  nsecs = lmin / fsmax;
  for jj = 1:na
    if len(as(jj)) ~= lmin
      utils.helper.msg(msg.PROC2, 'truncating AO %s to %d secs', as(jj).name, nsecs);
      % do we already have a copy?
      if ~copies(jj)
        % Make a deep copy so we don't
        % affect the original input data
        as(jj) = copy(as(jj), 1);
        copies(jj) = 1;
      end
      as(jj).select(1:lmin);
    end
  end
  
  %----------------- check input parameters
  
  % Maximum lag for Xcorr
  MaxLag = find_core(pl, 'MaxLag');
  
  % Scale for Xcorr
  scale = find_core(pl, 'Scale');
  
  % Loop over input AOs
  bs = ao;
  
  % -------- Make Xspec estimate
  
  % Compute cross-correlation estimates using XCORR
  if MaxLag == -1
    MaxLag = len(as(1));
  end
  % Use .data.y syntax (rather than .y) to preserve y vector shape
  [c,lags] = xcorr(as(1).data.y, as(2).data.y, MaxLag, scale);
  
  % Keep the data shape of the first input AO
  if size(as(1).y,1) == 1
    c = c.';
  end
  
  % create new output xydata
  xy = xydata(lags./fsmax, c);
  xy.setXunits(unit.seconds);
  switch scale
    case {'none', 'biased', 'unbiased'}      
      xy.setYunits(as(1).yunits *  as(2).yunits);
    case 'coeff'
      xy.setYunits('');
    otherwise
      error(['Unsupported scaling option ' scale]);
  end
  
  
  %----------- create new output history
  
  % make output analysis object
  bs.data = xy;
  % set name
  bs.name = sprintf('xcorr(%s->%s)', invars{1}, invars{2});
  % Propagate 'plotinfo'
  plotinfo = [as(:).plotinfo];
  if ~isempty(plotinfo)
    bs.plotinfo = combine(plotinfo);
  end
  % we need to get the input histories in the same order as the inputs
  % to this function call, not in the order of the input to xcorr;
  % otherwise the resulting matrix on a 'create from history' will be
  % mirrored.
  bs.addHistory(getInfo('None'), pl, [invars(:)], inhists);
  
  % Set output
  varargout{1} = bs;
  %   end
end

%--------------------------------------------------------------------------
% Returns the length of the shortest vector in samples
function lmin = findShortestVector(as)
  lmin = 1e20;
  for jj=1:numel(as)
    if len(as(jj)) < lmin
      lmin = len(as(jj));
    end
  end
end
%--------------------------------------------------------------------------
% Returns the max Fs of a set of AOs
function fs = findFsMax(as)
  fs = 0;
  for jj=1:numel(as)
    a = as(jj);
    if a.fs > fs
      fs = a.fs;
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
  ii.setArgsmin(2);
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
  
  pl = plist();
  
  % MaxLag
  p = param({'MaxLag', 'Compute over a range of lags -MaxLag to MaxLag  [default: M-1]'}, {1, {-1}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Scale
  p = param({'Scale', ['normalisation of the correlation. Choose from:<ul>'...
    '<li>''biased''   - scales the raw cross-correlation by 1/M</li>'...
    '<li>''unbiased'' - scales the raw correlation by 1/(M-abs(lags))</li>'...
    '<li>''coeff''    - normalizes the sequence so that the auto-correlations<br>'...
    'at zero lag are identically 1.0.</li>'...
    '<li>''none''     - no scaling</li></ul>']}, {1, {'none', 'biased', 'unbiased', 'coeff'}, paramValue.SINGLE});
  pl.append(p);
  
end
