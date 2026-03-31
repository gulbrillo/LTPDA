% WHITEN1D whitens the input time-series.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: WHITEN1D whitens the input time-series. The filter is built
%              by fitting to the model provided. If no model is provided, a
%              fit is made to a spectral-density estimate of the
%              time-series (made using psd+bin_data or lpsd).
%              Note: The function assumes that the input model corresponds
%              to the one-sided psd of the data to be whitened.
%
% ALGORITHM:
%            1) If no model provided, make psd+bin_data or lpsd
%               of time-series and take it as a model
%               for the data power spectral density
%            2) Fit a set of partial fraction z-domain filters using
%               utils.math.psd2wf. The fit is automatically stopped when
%               the accuracy tolerance is reached.
%            3) Convert to array of MIIR filters
%            4) Assemble into a parallel filterbank object
%            5) Filter time-series in parallel
%
%
% CALL:         b = whiten1D(a, pl)
%               [b1,b2,...,bn] = whiten1D(a1,a2,...,an, pl);
%
% INPUT:
%               - as are time-series analysis objects or a vector of
%               analysis objects
%               - pl is a plist with the input parameters
%
% OUTPUT:
%               - bs "whitened" time-series AOs. The whitening filters used
%               are stored in the objects procinfo field under the
%               parameter 'Filter'.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'whiten1D')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = whiten1D(varargin)
  
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
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  inhists = [as.hist];
  
  % combine plists
  if isempty(pl)
    model = 'psd';
  else
    model = find_core(pl, 'model');
    if isempty(model)
      model = 'psd';
    end
  end
  
  if ischar(model)
    pl = applyDefaults(getDefaultPlist(model), pl);
  else
    pl = applyDefaults(getDefaultPlist('Default'), pl);
  end
  pl.getSetRandState();
  
  scale = find_core(pl, 'scaleOut');
  flim = find_core(pl, 'flim');
  
  
  % Loop over input AOs
  for jj = 1:numel(as)
    if ~isa(as(jj).data, 'tsdata')
      utils.helper.msg(msg.IMPORTANT, '%s expects ao/tsdata objects. Skipping AO %s', mfilename, ao_invars{jj});
    else
      
      %-------------- Whiten this AO
      
      % 1) Build whitening filterbank
      switch class(model)
        case 'char'
          % Model is to be evaluated from data
          in = as(jj);
          pl.pset('model', model);
        case 'ao'
          % Model was provided as fsdata
          in = model;
          pl.pset('model', []);
      end
      wf = buildWhitener1D(in, pl);
      
      % 1.5) Scale the date if demanded
      if (scale)
        spsd = lpsd(as(jj));
        freqs = spsd.x;
        if isempty(flim)
          error('Please specify a flim field, to know the analysis band.');
        elseif (flim(2) < flim(1))
          error('flim should go from the smaller frequency to the bigger frequency. Please reverse them!')
        else
          index = find((freqs > flim(1)) & (freqs < flim(2)));
        end
        
        v1 = spsd.y(index(1):index(end-1));
        v2 = spsd.y(index(2):index(end));
        m = (v1 + v2) /2;
        p = sum(m.* diff(freqs(index(1):index(end))));
      end
      
      % 2) Filter data and scale it if necessary
      bs(jj).filter(wf);
      if (scale)
        bs(jj) = bs(jj) * sqrt(p);
      end
      
      
      % 3) Output data
      % name for this object
      bs(jj).name = sprintf('whiten1D(%s)', ao_invars{jj});
      % Collect the filters into procinfo
      bs(jj).procinfo = combine(plist('Filter', wf.filters), as(jj).procinfo);
      if(scale)
        bs(jj).procinfo = combine(plist('ScaleFactor', p, 'Filter', wf.filters), as(jj).procinfo);
      end
      % Make sure that the output yunits are empty
      if ~isequal(bs(jj).yunits, unit(''))
        utils.helper.msg(msg.PROC1, 'Resetting output yunits to empty');
        bs(jj).setYunits(unit(''));
      end
      % add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), inhists(jj));
      % clear errors
      bs(jj).clearErrors;
      
      
    end
  end
  
  
  
  % Set output
  if nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  else
    % Single output
    varargout{1} = bs;
  end
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pl = getDefaultPlist(sets{1});
  else
    sets = SETS();
    % get plists
    pl(size(sets)) = plist;
    for kk = 1:numel(sets)
      pl(kk) =  getDefaultPlist(sets{kk});
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end


%--------------------------------------------------------------------------
% Defintion of Sets
%--------------------------------------------------------------------------

function out = SETS()
  out = ao.getInfo('buildWhitener1D').sets;
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;
  persistent lastset;
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  
  pl = plist();
  
  % Append sets of parameters according to the chosen spectral estimator
  if ~utils.helper.ismember(lower(SETS), lower(set))
    error('### Unknown set [%s]', set);
  else
    pl = copy(ao.getInfo('buildWhitener1D', lower(set)).plists);
  end
  
  switch lower(set)
    case 'default'
      % Model
      p = param({'model', ['A frequency-series AO describing the model<br>'...
        'response to build the filter from. <br>' ...
        'As an alternative, the user '...
        'can choose a model estimation technique:<br>'...
        '<li>PSD - using <tt>psd</tt> + <tt>bin_data</tt></li>'...
        '<li>LPSD - using <tt>lpsd</tt></li>']}, paramValue.EMPTY_DOUBLE);
      pl = combine(plist(p), pl);
    otherwise
  end
  
  p = param({'scaleOut', ['Scale your output by the inband power']},paramValue.FALSE_TRUE);
  pl = combine(plist(p), pl);
  
  p = param({'flim', ['Band to calculate the scaling power']},[1e-3 30e-3]);
  pl = combine(plist(p), pl);
  
end

