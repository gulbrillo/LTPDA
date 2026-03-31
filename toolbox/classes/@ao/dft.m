% DFT computes the DFT of the input time-series at the requested frequencies.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DFT computes the DFT of the input time-series at the requested
%              frequencies.
%
% CALL:        b = dft(a, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'dft')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = dft(varargin)

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

  % Make copies or handles to inputs
  bs = copy(as, nargout);

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  % Extract necessary parameters
  f = find_core(pl, 'f');
  if isa(f, 'ao') && (isa(f.data, 'fsdata') || isa(f.data, 'xydata'))
    f = f.data.getX;
  end
  
  Nbin = find_core(pl, 'Nbins');
  skip = find_core(pl, 'skip');

  % bins over which to compute the error
  errbins = [-Nbin-skip:-skip skip:skip+Nbin];
  
  % Loop over input AOs
  for jj = 1:numel(bs)
    if ~isa(bs(jj).data, 'tsdata')
      warning('!!! The DFT can only be computed on input time-series. Skipping AO %s', ao_invars{jj});
    else
      % capture input history
      inhist = bs(jj).hist;

      % window data
      bs(jj).window(pl.subset(ao.getInfo('window').plists.getKeys));
      
      % Compute f if necessary
      if f == -1
        f = linspace(0, bs(jj).data.fs/2, length(bs(jj).data.getY)/2+1);
      end

      % Compute DFT
      fs  = bs(jj).data.fs;
      N   = length(bs(jj).data.getY);
      ii   = -2*pi*1i.*[0:N-1]/fs;
      dft = zeros(size(f));
      
      % frequencies to compute error over (ensure they are positive)
      df = fs / N;
      errf = df*errbins;
      errf = errf(errf>0);
      
      % do each frequency now
      for kk = 1:length(f)
        % fprintf('*** DFT @ %g\n', f(kk));
        dft(kk) = exp(f(kk)*ii)*bs(jj).data.getY;
        
        % estimate error around this frequency
        errdft = zeros(size(errf));
        for ee=1:numel(errf)
          % fprintf('    --- err DFT @ %g\n', f(kk)+errf(ee));          
          errdft(ee) = exp((f(kk)+errf(ee))*ii)*bs(jj).data.getY;
        end
        err(kk) = mean(abs(errdft));
      end
            
      % Make output fsdata AO
      yunits = bs(jj).data.yunits;
      % Keep the data shape of the input AO
      if xor(iscolumn(bs(jj).data.y), iscolumn(f))
        f   = f.';
        dft = dft.';
      end
      t0 = bs(jj).t0 + bs(jj).x(1);
      bs(jj).data = fsdata(f, dft, bs(jj).data.fs);
      bs(jj).data.setDy(err);
      bs(jj).data.setXunits(unit.Hz);
      bs(jj).data.setYunits(yunits ./ unit.Hz);
      bs(jj).data.setT0(t0);
      
      % scale the output to be rms
      if pl.find('scale')
        win = bs(jj).procinfo.find('win');
        if isa(win, 'specwin')
          spl = plist('factor', sqrt(2)/sum(win.win), 'yunits', 'Hz');
          bs(jj).scale(spl);
        else
          warning('No window found in object''s procinfo. No scaling will be applied.');
        end
      end
      
      % Set name
      bs(jj).name = sprintf('dft(%s)', ao_invars{jj});
      % Add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), inhist);
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
  
  pl = plist();

  % window
  pl.append(copy(plist.WINDOW_PLIST));
  pl.setDefaultForParam('WIN', 'Rectangular');

  % scale
  p = param({'scale', 'Scale the output according to the applied window resulting in [unit] rms.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % Frequencies
  p = param({'f', ['The vector of frequencies at which to compute the DFT <br>or an AO ' ...
    'where the x-axis is taken for the frequency values.']}, paramValue.DOUBLE_VALUE(-1));
  p.addAlternativeKey('frequencies');
  p.addAlternativeKey('f0');
  pl.append(p);

  % Nbins
  p = param({'nbins', ['The number of bins either side of each frequency from which to compute the mean error.' ...
    'The error will be computed from the bins deltaF*[-Nbins-skip:-skip skip:skip+Nbins] where deltaF = fs/Nsamples is the frequency resolution.']}, paramValue.DOUBLE_VALUE(5));
  pl.append(p);
                  
  p = param({'skip', 'The number of bins either side of each frequency to ignore when computing the mean error.'}, paramValue.DOUBLE_VALUE(3));
  pl.append(p);
                  
                  
end

% END
