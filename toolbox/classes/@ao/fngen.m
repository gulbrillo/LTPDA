% FNGEN creates an arbitrarily long time-series based on the input PSD.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FNGEN creates an arbitrarily long time-series based on the input PSD.
%
% CALL:        b = fngen(axx, pl)
%
% PARAMETERS:
%              'Nsecs'  - The number of seconds to produce
%                         [default: inverse of PSD length]
%              'Win'    - The spectral window to use for blending segments
%                         [default: Kaiser -150dB]
%
% 
% NOTE: this function requires the Statistics Toolbox in order to create
% a chi^2 distributed random variable.
% 
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'fngen')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = fngen(varargin)

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

  if nargout == 0
    error('### fngen cannot be used as a modifier. Please give an output variable.');
  end

  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);

  % Extract necessary parameters
  Nsecs = find_core(pl, 'Nsecs');
  swin  = find_core(pl, 'win');
  
  % Use window name instead of specwin object
  if isa(swin, 'spwcwin')
    swin = swin.type;
  end

  % Loop over input AOs
  bs = [];
  for j=1:numel(as)
    if ~isa(as(j).data, 'fsdata')
      warning('!!! %s expects ao/fsdata objects. Skipping AO %s', mfilename, as(j).name);
    else
      % Properties of the input PSD
      N     = 2*(length(as(j).data.y)-1);
      fs    = as(j).data.x(end)*2;
      % Extract Fourier components
      Ak = sqrt(N*as(j).data.getY*fs);
      Ak = [Ak; Ak(end-1:-1:2)]; % make two-sided
      % redesign input window for this length
      switch lower(swin)
        case 'kaiser'
          swin = specwin('Kaiser', N, pl.find_core('psll'));
        otherwise
          swin = specwin(swin, N);
      end
      % Compute time-series segments
      Olap   = 1-swin.rov/100;
      win    = [swin.win].';
      segLen = N/fs;
      if segLen > Nsecs
        cNsecs = 2*segLen;
      else
        cNsecs = Nsecs;
      end
      Nsegs  = 1+floor(cNsecs/segLen/Olap);

      % Prepare for generation
      rphi = zeros(N,1);                   % Empty vector for random phases
      xs   = zeros(fs*(cNsecs+segLen), 1);  % Large empty vector for new time-series
      e1   = 1; e2 = segLen*fs;            % Indices into large vector
      step = round(segLen*fs*Olap);        % step size between each new segment
      lxs  = length(xs);

      % Loop over segments
      for s=1:Nsegs
        % Generate random phase vector
        rphi(2:N/2) = pi*rand(1,N/2-1);  % First half
        rphi(N/2+1) = pi*round(rand);    % mid point
        rphi(N/2+2:N) = -rphi(N/2:-1:2); % reflected half
        %---- Compute Fourier amplitudes
        % Use chi^2 distribution to randomize amplitudes.
        % - from Percival and Walden: S_est = S.*chi2rnd(2)/2
        %   so A_est = A.*sqrt(chi2rnd(2)/2)
        % Here we take the measured input data to be a good estimate of
        % the underlying power spectrum
        X = (Ak.*sqrt(chi2rnd(2)/2)) .*exp(1i.*rphi);
        % Inverse FFT
        x  = ifft(X, 'symmetric');
        % overlap the segments
        xs(e1:e2) = xs(e1:e2) + win.*x;
        % increase step
        e1 = e1 + step;
        e2 = e2 + step;
        if e2>lxs
          break
        end
      end
      % Make ao from the segment of data we want
      e1 = fs*segLen/2;
      e2 = fs*(Nsecs+segLen/2)-1;
      b  = ao(tsdata(xs(e1:e2).', fs));
      b.name = sprintf('fngen(%s)', ao_invars{j});
      b.data.setXunits(unit.seconds);
      % Add history
      b.addHistory(getInfo('None'), pl, ao_invars(j), as(j).hist);
      % Add to outputs
      bs = [bs b];
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
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
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
  
  % Win
  p = param({'Win', 'The spectral window to use for blending data segments.'}, paramValue.WINDOW);
  pl.append(p);

  % psll
  p = param({'psll', 'Necessary for the ''Kaiser'' window.'}, paramValue.DOUBLE_VALUE(0));
  pl.append(p);

  % Nsecs
  p = param({'Nsecs', 'The number of seconds of data to produce.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
end

