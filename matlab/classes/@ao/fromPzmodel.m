% FROMPZMODEL Construct a time-series ao from polynomial coefficients
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromPzmodel
%
% DESCRIPTION: Construct a time-series ao from polynomial coefficients
%
% CALL:        a = fromPzmodel(a, pl)
%
% PARAMETER:   pl: plist containing 'pzmodel', 'Nsecs', 'fs'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = fromPzmodel(a, pli)
  
  % get AO info
  ii = ao.getInfo('ao', 'From Pzmodel');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  pl.getSetRandState();
  
  pzm         = find_core(pl, 'pzmodel');
  nsecs       = find_core(pl, 'Nsecs');
  fs          = find_core(pl, 'fs');
  ndigits     = find_core(pl, 'ndigits');
  
  % Build t vector
  if isempty(nsecs) || nsecs == 0
    error('### Please provide ''Nsecs'' for pzmodel constructor.');
  end
  if  isempty(fs) || fs == 0
    error('### Please provide ''fs'' for pzmodel constructor.');
  end
  
  %   Check if input pzmodel has more zeros than poles
  np = 0;
  for i =1:length(pzm.poles)
    if isnan(pzm.poles(i).q) % simple pole
      np = np + 1;
    elseif pzm.poles(i).q == 0.5 % critical damping
      np = np + 1;
    else % double pole
      np = np + 2;
    end
  end
  nz = 0;
  for i =1:length(pzm.zeros)
    if isnan(pzm.zeros(i).q)
      nz = nz + 1;
    elseif pzm.zeros(i).q == 0.5
      nz = nz + 1;
    else
      nz = nz + 2;
    end
  end
  if np <= nz
    error('### The noise generator needs more poles than zeros.');
  end
  % t = linspace(0, nsecs - 1/fs, nsecs*fs);
  
  % Run noise generator
  % conversion
  disp('  - Filter coefficients are calculated from input pzmodel.');
  [num, den] = ao.ngconv(pzm);
  
  % create matrices
  toolboxinfo = ver('symbolic');
  
  if  isempty(toolboxinfo)
    disp('the time series is calculated without the symbolic math toolbox')
    disp('  - Matrices are calculated from evaluated denominator coefficients.');
    [Tinit, Tprop, E] = ao.ngsetup(den, fs);
  else
    disp('the time series is calculated using the symbolic math toolbox')
    disp('  - Matrices are calculated from evaluated denominator coefficients.');
    if isempty(ndigits)
      ndigits = 32;
      warning('### set number of digits to 32!')
    end
    [Tinit, Tprop, E] = ao.ngsetup_vpa(den, fs, ndigits);
  end
  
  % set state vector
  y = pl.find_core('state');
  if isempty(y)
    disp('  - Since there is no given state vector it will be calculated.');  
    % make initial state vector
    y = ao.nginit(Tinit);
  end
  
  % propagate to make noise vector
  [x, yo] = ao.ngprop(Tprop, E, num, y, fs*nsecs);
  
  % build variables into data object
  t = x*pzm.gain;
  data = tsdata(t,fs);
  
  a.data = data;
  if isempty(pl.find_core('name'))
    pl.pset('name', sprintf('noisegen(%s)', pzm.name));
  end
  if isempty(pl.find_core('description'))
    pl.pset('description', pzm.description);
  end
  
  % Add history
  a.addHistory(ii, pl, [], pzm.hist);
  
  % Set xunits
  a.data.setXunits(pl.find_core('xunits'));
  % Set yunits
  a.data.setYunits(pl.find_core('yunits'));
  % Set T0
  a.data.setT0(pl.find_core('t0'));
  % Set toffset
  a.data.setToffset(pl.find_core('toffset')*1e3);
  
  a.procinfo = plist('state', yo);
  
  % Set object properties from the plist
  a.setObjectProperties(pl, {'xunits', 'yunits', 'toffset', 'fs'});
  
end


