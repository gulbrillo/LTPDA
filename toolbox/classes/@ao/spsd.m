% SPSD implements the smoothed (binned) PSD algorithm for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SPSD implements the smoothed PSD algorithm for analysis objects.
%
% CALL:        bs = spsd(a1,a2,a3,...,pl)
%              bs = spsd(as,pl)
%              bs = as.spsd(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'spsd')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = spsd(varargin)

  import utils.const.*

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs and plists
  [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(rest(:), 'plist', in_names);

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl, plist(rest(:)));

  inhists = [];

  %% Go through each input AO
  for jj = 1 : numel(bs)
    % gather the input history objects
    inhists = [inhists bs(jj).hist]; %#ok<AGROW>

    % check this is a time-series object
    if ~isa(bs(jj).data, 'tsdata')
      warning('!!! spsd requires tsdata (time-series) inputs. Skipping AO %s', ao_invars{jj}); %#ok<WNTAG>
    else

      % Check the time range.
      time_range = find_core(pl, 'times');
      if ~isempty(time_range)
        bs(jj) = split(bs(jj), plist('method', 'times', 'times', time_range));
      end
      % Check the length of the object
      if bs(jj).len <= 0
        error('### The object is empty! Please revise your settings ...');
      end

      % It is not necessary to combine pl and the default PLIST again.
      % pl = pl.combine(getDefaultPlist());

      % getting data
      y = bs(jj).y;

      % Window function
      Win = find_core(pl, 'Win');
      nfft = length(y);
      Win = ao( combine(plist('win', Win , 'length', nfft), pl) );

      % detrend
      order = find_core(pl,'order');
      if ~(order < 0)
        y = ltpda_polyreg(y,  order).';
      else 
        y = reshape(y, 1, nfft);
      end

      % computing PSD
      window = Win.data.y;
      window = window/norm(window)*sqrt(nfft);
      yASD = real(fft(y.*window, nfft)).^2 + imag(fft(y.*window, nfft)).^2;
      pow = [yASD(1) yASD(2:floor(nfft/2))*2];
      pow = pow /  ( bs(jj).data.fs * nfft);
      Freqs = linspace(0, bs(jj).data.fs/2, nfft/2);

      % smoothing PSD
      if ~isempty(find_core(pl,'frequencies'))
        error('the option "frequencies" is deprecated, frequencies are "removed" by default')
      end
      [Freqs, pow, nFreqs, nDofs] = ltpda_spsd(Freqs, pow, find_core(pl,'linCoef'), find_core(pl,'logCoef') );
      % create new output fsdata
      scale = find_core(pl, 'Scale');
      switch lower(scale)
        case 'asd'
          fsd = fsdata(Freqs, sqrt(pow), bs(jj).data.fs);
          fsd.setYunits(bs(jj).data.yunits / unit('Hz^0.5'));
          %           stdDev = 0.5 * sqrt( pow ./ nDofs ); % linear approximation of the sqrt of a distribution
          % approximation knowing the STD of the PSD
          % STD assuming amplitude samples are independent, Chi^1_2 distibuted
          % (with both variables of powe expectancy pow/2), and of different
          % magnitude
          stdDev = 2 * sqrt(pow./nDofs) .* ( nDofs - 2*exp( 2*(gammaln((nDofs+1)/2)-gammaln(nDofs/2)) ) ); % std of the chi_2N^1 
        case 'psd'
          fsd = fsdata(Freqs, pow, bs(jj).data.fs);
          fsd.setYunits(bs(jj).data.yunits.^2 / unit.Hz);
          % STD assuming power samples are independent, Chi^2_2 distibuted
          % (with both variables of expectancy pow/2), and of different
          % magnitude
          stdDev = sqrt(2) * (pow./nDofs) .* sqrt(2*nDofs);  % std of the chi_2N^2 
        otherwise
          error(['### Unknown scaling:' scale]);
      end

      fsd.setXunits(unit.Hz);
      fsd.setDx(nFreqs*Freqs(2)/2);
      fsd.setEnbw(1);% WARNING HERE!!!
      fsd.setT0(bs(jj).data.t0+bs(jj).x(1));
      % make output analysis object
      bs(jj).data = fsd;
      % set name
      bs(jj).name = ['SPSD(', ao_invars{jj}, ') ' upper(scale)];
      % Add standard deviation
      bs(jj).data.setDy(stdDev);
      % Add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), inhists(jj));

    end % End tsdata if/else
  end % End AO loop

  %% Set output
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
function pl = getDefaultPlist()

  % Plist for Welch-based, log-scale spaced spectral estimators.
  pl = plist;

  % Win
  p = param({'Win',['the window to be applied to the data to remove the ', ...
    'discontinuities at edges of segments. [default: taken from user prefs] <br>', ...
    'Only the design parameters of the window object are used. Enter either: <ul>', ...
    '<li> a specwin window object OR</li>', ...
    '<li> a string value containing the window name</li></ul>', ...
    'e.g., <tt>plist(''Win'', ''Kaiser'', ''psll'', 200)</tt>']}, paramValue.WINDOW);
  pl.append(p);

  % Psll
  p = param({'Psll',['the peak sidelobe level for Kaiser windows.<br>', ...
    'Note: it is ignored for all other windows']}, paramValue.DOUBLE_VALUE(200));
  pl.append(p);

  % Psll
  p = param({'levelOrder','the contracting order for levelledHanning window'}, paramValue.DOUBLE_VALUE(2));
  pl.append(p);

  % Order
  p = param({'Order',['order of segment detrending:<ul>', ...
    '<li>-1 - no detrending</li>', ...
    '<li>0 - subtract mean</li>', ...
    '<li>1 - subtract linear fit</li>', ...
    '<li>N - subtract fit of polynomial, order N</li></ul>']}, paramValue.DETREND_ORDER);
  p.val.setValIndex(2);
  pl.append(p);

  % Times
  p = param({'Times','time range. If not empty, sets the restricted interval to analyze'}, paramValue.DOUBLE_VALUE([]));
  pl.append(p);

  % Scale
  p = param({'Scale',['scaling of output. Choose from:<ul>', ...
    '<li>PSD - Power Spectral Density</li>', ...
    '<li>ASD - Amplitude (linear) Spectral Density</li>'...
    ]}, {1, {'PSD', 'ASD', 'PS', 'AS'}, paramValue.SINGLE});
  pl.append(p);

  p = param( {'lincoef', 'Linear scale smoothing coefficent (freq. bins)'}, 1);
  pl.append(p);

  p = param( {'logcoef', ['Logarithmic scale smoothing coefficent<br>', 'Best compromise for both axes is 2/3']}, 2/3);
  pl.append(p);
end
