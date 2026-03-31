% FNGEN creates an arbitrarily long time-series based on the input pzmodel.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FNGEN creates an arbitrarily long time-series based on the
%              input pzmodel.
%
% CALL:        b = fngen(pzm, pl)
%
% PARAMETERS:  'Nsecs'  - The number of seconds to produce
%                         [default: inverse of PSD length]
%              'Win'    - The spectral window to use for blending segments
%                         [default: Kaiser -150dB]
%
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'fngen')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = fngen(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs and plists
  [pzms, pzm_invars] = utils.helper.collect_objects(varargin(:), 'pzmodel', in_names);
  pl                = utils.helper.collect_objects(varargin(:), 'plist', in_names);

  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);

  % Loop over input pzms
  bs(1:numel(pzms)) = ao();
  for j=1:numel(pzms)
    % get sample rate to specify Nyquist
    fs    = find_core(pl, 'fs');
    if isempty(fs)
      fs = round(getupperFreq(pzms(j)) * 10);
    end
    if fs < 1
      fs = 1;
    end

    % Compute the frequency vector
    Nf = 10001;
    f1 = 0;
    f2 = fs/2;
    f  = linspace(f1,f2,Nf);
    N = 2*(Nf-1);
    % Compute model response
    w   = ao(plist('tsfcn', 'sqrt(fs/2).*randn(size(t))', 'fs', fs, 'Nsecs', N));
    wxx = psd(w, plist('Nfft', N, 'win', 'Rectangular'));
    axx = resp(pzms(j), plist('f', f));

    % Compute desired PSD
    wxx.data.setY(wxx.y .* (abs(axx.y).^2));

    % Call ao/fngen
    b = fngen(wxx, pl);
    b.data.setXunits(unit.seconds);
    b.data.setYunits('');

    % Add history
    b.addHistory(getInfo('None'), pl, pzm_invars(j), pzms(j).hist);

    % Add to outputs
    bs(j) = b;
  end

  % Set outputs
  varargout{1} = bs;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist();
  
  % Nsecs
  p = param({'Nsecs', 'The length of the time-series in seconds.'}, paramValue.DOUBLE_VALUE(-1));
  pl.append(p);
  
  % Win
  p = param({'Win', 'The window to use in the blending of consecutive segments.'}, paramValue.WINDOW);
  pl.append(p);
  
end

