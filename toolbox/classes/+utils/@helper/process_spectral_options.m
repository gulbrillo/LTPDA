% PROCESS_SPECTRAL_OPTIONS checks the options for the parameters needed by spectral estimators, recalculating  and/or resetting them if needed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PROCESS_SPECTRAL_OPTIONS checks the options for:
%              - olap
%              - order
%              - win
%              - psll
%              - navs (for linear frequency scaled estimators)
%              - nfft (for linear frequency scaled estimators)
%              - kdes (for logarithmic frequency scaled estimators)
%              - jdes (for logarithmic frequency scaled estimators)
%              - lmin (for logarithmic frequency scaled estimators)
%
% CALL:       pl = process_spectral_options(pl, type, varargin)
%
% INPUTS:
%          pl      - the parameter list to scan
%          type    - the type of estimator. Choose between:
%                  'welch' (or 'lin') for linear frequency scaled
%                  'lpsd' (or 'log') for logarithmic frequency scaled
%          Optionals:
%          obj_len - the length of the object (the shortest in case of x-spec)
%          obj_fs  - the sampling frequency of the object (the highest in case of x-spec)
%
%
% OUTPUTS:    pl_out - the revised plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pl_out = process_spectral_options(pl, type, varargin)
  
  % Necessary for debug messages
  import utils.const.*
  
  LIN = 'lin';
  LOG = 'log';
  
  % We need to copy the input plist since we are going to be modify it
  pl_out = copy(pl, true);
  
  switch length(varargin)
    case 0
      if strcmpi(type, LIN)
        error('### please provide the object length!');
      end
    case 1
      obj_len = varargin{1};
    otherwise
      obj_len = varargin{1};
      fs = varargin{2};
  end
  
  % Check the type of estimator
  switch lower(type)
    case {'welch', 'lin', 'linear'}
      type = LIN;
    case {'lpsd', 'log', 'logarithmic'}
      type = LOG;
    otherwise
      error(['### Unsupported estimator type ' type]);
  end
  
  if strcmpi(type, LIN)
    % Check the number of points in FFT. If this is not set (<0) we set it
    % to be the length of the input data.
    Nfft = find(pl_out, 'Nfft');
    if isempty(Nfft)
      Nfft = -1;
    end
    setWindow = 0;
    if ischar(Nfft)
      nNfft = floor(eval(Nfft));
      utils.helper.msg(msg.PROC1, 'setting Nfft to %s = %d', Nfft, nNfft);
      Nfft = nNfft;
    end
    if Nfft <= 0
      Nfft = obj_len;
      utils.helper.msg(msg.PROC1, 'using default Nfft of %g', Nfft);
      setWindow = 1;
    end
    pl_out.pset_core('Nfft', Nfft);
  end
  
  % Check the window function.
  Win = find(pl_out, 'Win');
  psll = find(pl_out, 'psll');
  levelcoeff = find(pl_out, 'level');
  if isempty(Win)
    Win = 'BH92';
    utils.helper.msg(msg.PROC1, 'using Blackman-Harris window');
  end
  if isempty(psll)
    psll = 0;
    utils.helper.msg(msg.PROC1, 'setting psll level to 0');
  end
  if ischar(psll)
    npsll = floor(eval(psll));
    utils.helper.msg(msg.PROC1, 'setting psll to %s = %d', psll, npsll);
    psll = npsll;
  end
  if ischar(Win)
    % We always want to work with a specwin
    switch lower(Win)
      case 'kaiser'
        Win = specwin(Win, 0, psll);
      case 'levelledhanning'
        Win = specwin(Win, 0, levelcoeff);
      otherwise
        Win = specwin(Win, 0);
    end
  end
  if strcmpi(type, LIN)
    % If the length of the window doesn't match NFFT then we resize it.
    if setWindow || Win.len ~= Nfft
      Win.len = Nfft;
      utils.helper.msg(msg.PROC1, 'reset window to %s(%d)', strrep(Win.type, '_', '\_'), Win.len);
    end
  else
    % For log-spaced estimators, let's always reset to a 0-point window
    Win.len = 0;
    utils.helper.msg(msg.PROC1, 'reset window to %s(%d)', strrep(Win.type, '_', '\_'), Win.len);
  end
  pl_out.pset_core('Win', Win);
  pl_out.pset_core('psll', psll);
  
  % Check the overlap. If this is not set, we take the overlap from that
  % recommended by the window function.
  Olap = find(pl_out, 'Olap');
  if isempty(Olap) || Olap < 0
    Olap = Win.rov;
    utils.helper.msg(msg.PROC1, 'using default overlap of %2.1f%%', Olap);
  end
  pl_out.pset_core('Olap', Olap);
  
  if strcmpi(type, LIN)
    % Check if the user is asking for a given number of averages
    % If so, the Nfft and the win values are reset based on the
    % calculated value:
    navs = find(pl_out, 'navs');
    if ~isempty(navs) && navs > 1 && setWindow
      % Compute the number of segments
      M = obj_len;
      overlap = Olap/100;
      L = round(M/(navs*(1-overlap) + overlap));
      utils.helper.msg(msg.PROC1, 'Asked for navs = %d', navs);
      % Checks it will really obtain the correct answer.
      % This is needed to cope with the need to work with integers
      while fix((M-round(L*overlap))/(L-round(L*overlap))) < navs
        L = L - 1;
      end
      navs_actual = fix((M-round(L*overlap))/(L-round(L*overlap)));
      utils.helper.msg(msg.PROC1, 'Expect to get navs_actual = %d', navs_actual);
      if L > 0
        % Reset Nfft
        Nfft = L;
        pl_out.pset_core('Nfft', Nfft);
        % Reset window
        Win.len = Nfft;
        pl_out.pset_core('Win', Win);
        pl_out.pset_core('navs', fix(navs_actual));
        utils.helper.msg(msg.PROC1, 'reset navs to %d', fix(navs_actual));
      end
    end
  end
  
  % desired detrending order
  order = pl_out.find('Order');
  if isempty(order)
    order = 0;
    utils.helper.msg(msg.PROC1, 'using default detrending order 0 (mean)');
  end
  if ischar(order)
    norder = floor(eval(order));
    utils.helper.msg(msg.PROC1, 'setting detrending order to %s = %d', order, norder);
    order = norder;
  end
  pl_out.pset_core('Order', order);
  
  if strcmpi(type, LOG)
    % Desired number of averages
    Kdes = find(pl_out, 'Kdes');
    if isempty(Kdes)
      Kdes = 100;
      utils.helper.msg(msg.PROC1, 'using default Kdes value 100');
    end
    if ischar(Kdes)
      nKdes = floor(eval(Kdes));
      utils.helper.msg(msg.PROC1, 'setting Kdes value to %s = %d', Kdes, nKdes);
      Kdes = nKdes;
    end
    pl_out.pset_core('Kdes', Kdes);
    
    % num desired spectral frequencies
    Jdes = find(pl_out, 'Jdes');
    if isempty(Jdes)
      Jdes = 1000;
      utils.helper.msg(msg.PROC1, 'using default Jdes value 1000');
    end
    if ischar(Jdes)
      nJdes = floor(eval(Jdes));
      utils.helper.msg(msg.PROC1, 'setting Jdes value to %s = %d', Jdes, nJdes);
      Jdes = nJdes;
    end
    pl_out.pset_core('Jdes', Jdes);
    
    % Minimum segment length
    Lmin = find(pl_out, 'Lmin');
    if isempty(Lmin)
      Lmin = 0;
      utils.helper.msg(msg.PROC1, 'using default Lmin value 0');
    end
    if ischar(Lmin)
      nLmin = floor(eval(Lmin));
      utils.helper.msg(msg.PROC1, 'setting Kdes value to %s = %d', Lmin, nLmin);
      Lmin = nLmin;
    end
    pl_out.pset_core('Lmin', Lmin);
  end
end
