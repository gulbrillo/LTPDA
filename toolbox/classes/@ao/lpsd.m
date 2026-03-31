% LPSD implements the LPSD algorithm for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LPSD implements the LPSD algorithm for analysis objects.
%
% CALL:        bs = lpsd(a1,a2,a3,...,pl)
%              bs = lpsd(as,pl)
%              bs = as.lpsd(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'lpsd')">Parameters Description</a>
%
% References:  "Improved spectrum estimation from digitized time series
%               on a logarithmic frequency axis", Michael Troebs, Gerhard Heinzel,
%               Measurement 39 (2006) 120-129.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lpsd(varargin)

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
  [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, pl);
  
  inhists = [];
  
  % Loop over input AOs
  for jj = 1 : numel(bs)
    % gather the input history objects
    inhists = [inhists bs(jj).hist];
    
    % check this is a time-series object
    if ~isa(bs(jj).data, 'tsdata')
      warning('!!! lpsd requires tsdata (time-series) inputs. Skipping AO %s', ao_invars{jj});
    else
      
      % Check the time range.
      time_range = mfind(pl, 'split', 'times');
      if ~isempty(time_range)
        switch class(time_range)
          case 'double'
            bs(jj) = split(bs(jj), plist(...
              'times', time_range));
          case 'timespan'
            bs(jj) = split(bs(jj), plist(...
              'timespan', time_range));
          case 'time'
            bs(jj) = split(bs(jj), plist(...
              'start_time', time_range(1), ...
              'end_time', time_range(2)));
          case 'cell'
            bs(jj) = split(bs(jj), plist(...
              'start_time', time_range{1}, ...
              'end_time', time_range{2}));
          otherwise
        end
      end
      
      % Check the length of the object
      if bs(jj).len <= 0
        error('### The object is empty! Please revise your settings ...');
      end
      
      pl = utils.helper.process_spectral_options(pl, 'log');
      
      % Desired number of averages
      Kdes = find_core(pl, 'Kdes');
      % num desired spectral frequencies
      Jdes = find_core(pl, 'Jdes');
      % Minimum segment length
      Lmin = find_core(pl, 'Lmin');
      % Window function
      Win = find_core(pl, 'Win');
      % Overlap
      Nolap = find_core(pl, 'Olap')/100;
      % Order of detrending
      Order = find_core(pl, 'Order');      

      % Get frequency vector
      [f, r, m, L, K] = ao.ltf_plan(length(bs(jj).data.y), bs(jj).data.fs, Nolap, 1, Lmin, Jdes, Kdes);
      
      % compute LPSD
      try
        if find_core(pl, 'M-FILE ONLY')
          % Using pure m-file version
          [P, Pxx, ENBW] = ao.mlpsd_m(bs(jj).data.y, f, r, m, L, bs(jj).data.fs, Win, Order, Nolap);
        else
          [P, Pxx, dev, devxx, ENBW] = ao.mlpsd_mex(bs(jj).data.y, f, r, m, L, bs(jj).data.fs, Win, Order, Nolap*100, Lmin);
        end
      catch ME
        warning('!!! mex file dft failed. Using m-file version of lpsd.');
        % Using pure m-file version
        [P, Pxx, ENBW] = ao.mlpsd_m(bs(jj).data.y, f, r, m, L, bs(jj).data.fs, Win, Order, Nolap);
      end
      
      % Keep the data shape of the input AO
      if size(bs(jj).data.y,1) == 1
        P   = P.';
        Pxx = Pxx.';
        dev   = dev.';
        devxx = devxx.';
        f   = f.';
      end
      
      % create new output fsdata
      scale = find_core(pl, 'Scale');
      switch lower(scale)
        case 'as'
          fsd = fsdata(f, sqrt(P), bs(jj).data.fs);
          fsd.setYunits(bs(jj).data.yunits);
          std = sqrt(dev);
        case 'asd'
          fsd = fsdata(f, sqrt(Pxx), bs(jj).data.fs);
          fsd.setYunits(bs(jj).data.yunits / unit('Hz^0.5'));
          std = sqrt(devxx);
        case 'ps'
          fsd = fsdata(f, P, bs(jj).data.fs);
          fsd.setYunits(bs(jj).data.yunits.^2);
          std = dev;
        case 'psd'
          fsd = fsdata(f, Pxx, bs(jj).data.fs);
          fsd.setYunits(bs(jj).data.yunits.^2 / unit.Hz);
          std = devxx;
        otherwise
          error(['### Unknown scaling:' scale]);
      end
      fsd.setXunits(unit.Hz);
      fsd.setEnbw(ENBW);
      fsd.setT0(bs(jj).data.t0 + bs(jj).x(1));
      % make output analysis object
      bs(jj).data = fsd;
      % set name
      bs(jj).name = sprintf('L%s(%s)', upper(scale), ao_invars{jj});
      % Add processing info
      bs(jj).procinfo = plist('r', r, 'm', m, 'l', L, 'k', K);
      % Add standard deviation
      bs(jj).data.setDy(std);
      % Add history
      if ~utils.helper.callerIsMethod
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), inhists(jj));
      end
      
    end % End tsdata if/else
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
    pl   = getDefaultPlist();
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
  
  % General plist for Welch-based, log-scale spaced spectral estimators
  pl = copy(plist.LPSD_PLIST, 1);
  
  % Scale
  p = param({'Scale',['The scaling of output. Choose from:<ul>', ...
    '<li>PSD - Power Spectral Density</li>', ...
    '<li>ASD - Amplitude (linear) Spectral Density</li>', ...
    '<li>PS  - Power Spectrum</li>', ...
    '<li>AS  - Amplitude (linear) Spectrum</li></ul>']}, {1, {'PSD', 'ASD', 'PS', 'AS'}, paramValue.SINGLE});
  pl.append(p);
  
end

% PARAMETERS:
%
%     'Kdes'  - desired number of averages to perform  [default: 100]
%     'Jdes'  - number of spectral frequencies to compute [default: 1000]
%     'Lmin'  - minimum segment length   [default: 0]
%     'Win'   - the window to be applied to the data to remove the
%               discontinuities at edges of segments. [default: taken from
%               user prefs]
%               Only the design parameters of the window object are
%               used. Enter either:
%                - a specwin window object OR
%                - a string value containing the window name
%                  e.g., plist('Win', 'Kaiser', 'psll', 200)
%     'Olap'  - segment percent overlap [default: -1, (taken from window function)]
%     'Scale' - scaling of output. Choose from:
%                PSD - Power Spectral Density [default]
%                ASD - Amplitude (linear) Spectral Density
%                PS  - Power Spectrum
%                AS  - Amplitude (linear) Spectrum
%     'Order' - order of segment detrending
%                -1 - no detrending
%                0 - subtract mean [default]
%                1 - subtract linear fit
%                N - subtract fit of polynomial, order N
