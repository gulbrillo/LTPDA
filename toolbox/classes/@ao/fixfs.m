% FIXFS resamples the input time-series to have a fixed sample rate.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FIXFS resamples the input time-series to have a fixed sample rate.
%
% The new sampling grid is computed from the specified sample rate. If no
% sample rate is specified, the target is taken from a fit to the input tsdata
% object. The new sampling grid starts at the time returned from the fit
% (unless specified) and contains the same number of points or spans the
% same time as specified.
%
% CALL:        bs = fixfs(a1,a2,a3,...,pl)
%              bs = fixfs(as,pl)
%              bs = as.fixfs(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'fixfs')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = fixfs(varargin)

  callerIsMethod = utils.helper.callerIsMethod;
  
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

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});


  % Get fs
  target_fs    = find_core(pl, 'fs');
  method       = find_core(pl, 'method');
  interp       = find_core(pl, 'interpolation');
  alias        = find_core(pl, 'filter');
  
  n_fs = numel(target_fs);
  if n_fs > 0 && n_fs ~= 1 && n_fs ~= numel(as)
    error('### Please specify either a no sample rate, a single sample rate, or one for each input time-series.');
  end

  % Get only tsdata AOs
  for jj = 1:numel(bs)
    if isa(bs(jj).data, 'tsdata')
      % record input hist
      hin = bs(jj).hist;
      utils.helper.msg(msg.PROC1, 'fixing AO: %s', bs(jj).name);
      %------------- Fit sample rate and toffset
      [ffs, toff, unevenly] = tsdata.fitfs(bs(jj).data);
      %---------------- Get target sample rate
      switch numel(target_fs)
        case 0
          utils.helper.msg(msg.PROC1, 'using sample rate from fit: %0.10g', ffs);
          fs = ffs;
        case 1
          fs = target_fs;
        otherwise
          fs = target_fs(jj);
      end
      
      if fs == bs(jj).fs && ~unevenly
        utils.helper.msg(msg.PROC1, 'skipping: object [%s] already has [fs] equal to target: %0.10g', bs(jj).name, fs);
      else
        %-------------- Compute new grid
        switch lower(method)
          case 'samples'
            N = length(bs(jj).data.y);
            t = linspace(toff, toff+(N-1)/fs, N);
          case 'time'
            Nsecs = bs(jj).data.nsecs;
            t = toff + tsdata.createTimeVector(fs, Nsecs);
          otherwise
            error('### Unknown interpolation method. Do you want to preserve data duration or number of samples?');
        end
        %-------------- Antialiasing filter
        switch lower(alias)
          case 'iir'
            utils.helper.msg(msg.PROC1, 'applying iir antialising filter');
            pl = plist('type', 'lowpass',...
              'order', 8,...
              'fs', bs(jj).data.fs,...
              'fc', 0.9*(fs/2));
            f = miir(pl);
            filtfilt(bs(jj),f);
          case 'fir'
            utils.helper.msg(msg.PROC1, 'applying fir antialising filter');
            pl = plist('type', 'lowpass',...
              'order', 64,...
              'fs', bs(jj).data.fs,...
              'fc', 0.9*(fs/2));
            f = mfir(pl);
            filter(bs(jj),f);
          case 'off'
          otherwise
            error('### Unknown filtering  method. Please choose: ''iir'', ''fir'' or ''off'' ');
        end
        %-------------- Interpolate
        bs(jj).interp(plist('vertices', t, 'method', interp));
                
        % ensure we really set the sample rate. There are internal rules
        % which check if the sample rate is significantly diffent, and so
        % it may not get set.
        bs(jj).data.setFs(2*fs);
        bs(jj).data.setFs(fs);
      end
      
      if ~callerIsMethod
        % Set name
        bs(jj).name = sprintf('%s(%s)', mfilename, ao_invars{jj});
        % Add history
        bs(jj).addHistory(getInfo, pl, ao_invars(jj), hin);
      end
    else
      warning('!!! Skipping AO %s - it''s not a time-series AO.', ao_invars{jj});
      bs(jj) = [];
    end
  end

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
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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
  
  % Fs
  p = param({'fs', 'The target sampling frequency.'}, {1, {[]}, paramValue.OPTIONAL});
  p.addAlternativeKey('fsout');
  pl.append(p);
  
  % Method
  p = param({'method','Choose if the new data should span the same time or preserve the number of samples (time/samples)'},...
    {1, {'time', 'samples'}, paramValue.SINGLE});
  pl.append(p);
  
  % Filter
  p = param({'filter','Specify options for the antialiasing filter.'},{3, {'iir', 'fir', 'off'}, paramValue.SINGLE});
  pl.append(p);
  
  % Interpolation
  pli = ao.getInfo('interp').plists;
  p = setKey(pli.params(pli.getIndexForKey('method')), 'interpolation');
  p.setOrigin(mfilename);
  pl.append(p);
  
end
