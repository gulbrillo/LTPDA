% LISOVFIT uses LISO to fit a pole/zero model to the input frequency-series.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LISOVFIT uses LISO to fit a pole/zero model to the input
%              frequency-series.
%
% CALL:        >> pzm = lisovfit(a,pl)
%
% INPUTS:      pl   - a parameter list
%              a    - input analysis object
%
% OUTPUTS:
%              pzm  - the fitted pzmodel.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'lisovfit')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lisovfit(varargin)

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
  [bs, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pl, pl_invars] = utils.helper.collect_objects(varargin(:), 'plist', in_names);

  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);

  % Extract parameters
  pzm0  = find_core(pl, 'PZM0');
  pzml  = find_core(pl, 'PZML');
  pzmu  = find_core(pl, 'PZMU');
  delay = find_core(pl, 'delay');
  f1    = find_core(pl, 'f1');
  f2    = find_core(pl, 'f2');
  nf    = find_core(pl, 'nf');
  method = find_core(pl, 'method');
  np1    = find_core(pl, 'np1');
  np2    = find_core(pl, 'np2');

  
  % Check inputs
  if isempty(f1) || isempty(f2) || isempty(nf)
    error('### Specify the full frequency range with f1, f2, and nf');
  end
  if f1 > f2
    error('### The starting frequency should be less than the end frequency');
  end
  if numel(delay) ~= 3
    error('### The delay must be specified as a 3 element numerical vector: [limit start upper]');
  end
  if ~(delay(1) < delay(2))
    error('### The lower limit for the delay must be less than the starting guess.');
  end
  if ~(delay(2) < delay(3))
    error('### The upper limit for the delay must be greater than the starting guess.');
  end
  if numel(pzm0.poles) ~= numel(pzml.poles)
    error('### The starting, lower, and upper models must have the same number of poles');
  end
  if numel(pzm0.poles) ~= numel(pzmu.poles)
    error('### The starting, lower, and upper models must have the same number of poles');
  end
  if numel(pzm0.zeros) ~= numel(pzml.zeros)
    error('### The starting, lower, and upper models must have the same number of zeros');
  end
  if numel(pzm0.zeros) ~= numel(pzmu.zeros)
    error('### The starting, lower, and upper models must have the same number of zeros');
  end

  % Loop over input AOs
  pzms = [];
  pzmls = [];
  pzmus = [];
  for j=1:numel(bs)
    if isa(bs(j).data, 'fsdata')
      % Generate temp file names
      outfile  = [tempname '.fil'];
      datafile = [tempname '.dat'];
      % Write LISO fit file
      switch lower(method)
        case 'fit'
          if isreal(bs(j).data.getY)
            writeLISOfitFile(pzm0, pzml, pzmu, delay, f1, f2, nf, outfile, datafile, false);
          else
            writeLISOfitFile(pzm0, pzml, pzmu, delay, f1, f2, nf, outfile, datafile, true);
          end
        case 'vfit'
          writeLISOvfitFile(np1,np2,outfile, datafile);
        otherwise
          error('### method should be ''vfit'' or ''fit''.');
      end
      % Export AO data file
      export(bs(j), datafile);
      % call fil
      utils.bin.fil(outfile);
      % get fitted model
      pzmfit = pzmodel(outfile);
      % pzmodel returns 3 models, set name for the first one
      pzmfit(1).name = sprintf('fit(%s)', pzm0.name);
      % Set units
      [ounits, iunits] = factor(bs(j).data.yunits);
      pzmfit(1).setIunits(iunits);
      pzmfit(1).setOunits(ounits);
      pzmfit(2).setIunits(iunits);
      pzmfit(2).setOunits(ounits);
      pzmfit(3).setIunits(iunits);
      pzmfit(3).setOunits(ounits);
      % add history
      pzmfit(1).addHistory(getInfo('None'), pl, ao_invars(j), bs(j).hist);
      pzmfit(2).addHistory(getInfo('None'), pl, ao_invars(j), bs(j).hist);
      pzmfit(3).addHistory(getInfo('None'), pl, ao_invars(j), bs(j).hist);
      % add to output
      pzms = [pzms pzmfit(1)];
      pzmls = [pzmls pzmfit(2)];
      pzmus = [pzmus pzmfit(3)];
    else
      error('### unknown data type.');
    end
  end

  % Set outputs
  if nargout == 1
    varargout{1} = pzms;
  elseif nargout == 3
    varargout{1} = pzms;
    varargout{2} = pzmls;
    varargout{3} = pzmus;
  else
    error('### Incorrect number of output arguments.');
  end
end

%----------------------------------------------------------
% Write a liso vector fitting  file
%
function writeLISOvfitFile(np1, np2, outfile, datafile)
  fd = fopen(outfile, 'w+');

  fprintf(fd, '# Temporary LISO fitting file \n');

  % Write fit command
   fprintf(fd, 'vfit %s reim rel %d %d \n', datafile,np1,np2);
   fprintf(fd, '\n');

  % Close file
  fclose(fd);
end

%----------------------------------------------------------
% Write a liso fit file
%
function writeLISOfitFile(pzm0, pzml, pzmu, delay, f1, f2, nf, outfile, datafile, complexData)
  fd = fopen(outfile, 'w+');

  fprintf(fd, '# Temporary LISO fitting file from pzmodel: %s\n\n', pzm0.name);

  % first output poles
  Np = numel(pzm0.poles);
  for k=1:Np
    pole = pzm0.poles(k);
    lpole = pzml.poles(k);
    upole = pzmu.poles(k);
    fprintf(fd, '# POLE %d\n', k);
    % write pole start
    if isnan(pole.q)
      if ~isnan(lpole.q) || ~isnan(upole.q)
        error('### Poles in start, lower, and upper models must be of the same for (real, complex)');
      end
      fprintf(fd, 'pole %g\n',  pole.f);
    else
      fprintf(fd, 'pole %g %g\n',  pole.f, pole.q);
    end
    % write param range
    %   param pole2:f 1.0746e-06 0.00010746
    fprintf(fd, 'param pole%d:f %g %g\n', k-1, lpole.f, upole.f);
    if ~isnan(pole.q)
      fprintf(fd, 'param pole%d:q %g %g\n', k-1, lpole.q, upole.q);
    end
    fprintf(fd, '\n');
  end

  % then output zeros
  Nz = numel(pzm0.zeros);
  for k=1:Nz
    zero = pzm0.zeros(k);
    lzero = pzml.zeros(k);
    uzero = pzmu.zeros(k);
    fprintf(fd, '# ZERO %d\n', k);
    % write pole start
    if isnan(zero.q)
      if ~isnan(lzero.q) || ~isnan(uzero.q)
        error('### Zeros in start, lower, and upper models must be of the same for (real, complex)');
      end
      fprintf(fd, 'zero %g\n',  zero.f);
    else
      fprintf(fd, 'zero %g %g\n',  zero.f, zero.q);
    end
    % write param range
    %   param pole2:f 1.0746e-06 0.00010746
    fprintf(fd, 'param zero%d:f %g %g\n', k-1, lzero.f, uzero.f);
    if ~isnan(zero.q)
      fprintf(fd, 'param zero%d:q %g %g\n', k-1, lzero.q, uzero.q);
    end
    fprintf(fd, '\n');
  end

  % Write delay out
  if ~isempty(delay)
    fprintf(fd, 'delay %g\n', delay(2));
    fprintf(fd, 'param delay %g %g\n', delay(1), delay(3));
  end
  fprintf(fd, '\n');

  % Write factor
  fprintf(fd, 'factor %g\n', pzm0.gain);
  fprintf(fd, 'param factor %g %g\n', pzml.gain, pzmu.gain);
  fprintf(fd, '\n');

  % Write frequency command
  fprintf(fd, 'freq lin %g %g %g\n', f1, f2, nf);
  fprintf(fd, '\n');

  % Write fit command
  if complexData
    fprintf(fd, 'fit %s reim semi\n', datafile);
  else
    fprintf(fd, 'fit %s abs rel\n', datafile);
  end
  fprintf(fd, 'rewrite samebetter\n');
  fprintf(fd, '\n');

  % Close file
  fclose(fd);
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
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
  
  % PZM0
  p = param({'PZM0', 'A pzmodel describing the starting guess.'}, {1, {pzmodel}, paramValue.OPTIONAL});
  pl.append(p);
  
  % PZML
  p = param({'PZMU', 'A pzmodel describing the upper-bound.'}, {1, {pzmodel}, paramValue.OPTIONAL});
  pl.append(p);
  
  % PZMU
  p = param({'PZML', 'A pzmodel describing the lower-bound.'}, {1, {pzmodel}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Delay
  p = param({'Delay', 'A 3-element numeric vector describing<br>a time-delay to include in the fit.'}, {1, {[0 1 10]}, paramValue.OPTIONAL});
  pl.append(p);
  
  % F1
  p = param({'F1', 'A start freqeuency to fit over'}, {1, {0}, paramValue.OPTIONAL});
  pl.append(p);
  
  % F2
  p = param({'F2', 'The end freqeuency to fit over'}, {1, {1}, paramValue.OPTIONAL});
  pl.append(p);

  % Nf
  p = param({'NF','The number of frequencies to include in the fit.'}, {1, {100}, paramValue.OPTIONAL});
  pl.append(p);
  
  % method
  p = param({'method', 'The fitting method.'}, {1, {'fit', 'vfit'}, paramValue.SINGLE});
  pl.append(p);
  
  % NP1
  p = param({'NP1', 'The minimum number of poles for vfit.'}, {1, {2}, paramValue.OPTIONAL});
  pl.append(p);
  
  % NP2
  p = param({'NP2', 'The maximum number of poles for vfit.'}, {1, {10}, paramValue.OPTIONAL});
  pl.append(p);
  
  

end

% PARAMETERS:
%              'PZM0'  - a pzmodel describing the starting guess.
%              'PZML'  - a pzmodel describing the lower-bound.
%              'PZMU'  - a pzmodel describing the upper-bound.
%              'DELAY' - a 3-element numeric vector describing a time-delay
%                        to include in the fit: [lower start upper]
%              'f1'    - start freqeuency to fit over [default: taken from input AO]
%              'f2'    - end freqeuency to fit over [default: taken from input AO]
%              'nf'    - number of frequencies to fit [default: taken from input AO]
%              'method'- 'fit' for fitting or 'vfit' for vector fitting [default: fit]
%              'np1'    - lower num. poles for vfit [default: 2]
%              'np2'    - upper num. poles for vfit [default: 10]
