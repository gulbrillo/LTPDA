% COMPUTEICSMATRIX.M
%
% A helper function to compute the inverse cross-spectrum matrix given
% an input of objects with the "measured" noise. The noise objects can be 
%
% a) AO tsdata noise time series. The PSD is computed based on the input
%    plist, and then the inverse cross-spectrum matrix is derived.
%
% b) AO fsdata frequency series. It is assumed that the fsdata are in the
%    correct format, so they are just copied and interpolated to the signal
%    frequencies.
%
% c) SMODEL array. The SMODELs are assumed that they describe smooth models
%    of the PSD of the noise. They are evaluated at the signal frequencies
%    and then the inverse cross-spectrum matrix is computed.
%
%
% <a href="matlab:utils.helper.displayMethodInfo('MCMC', 'MCMC.computeICSMatrix')">Parameters Description</a>
%
% NK 2013
%
function varargout = computeICSMatrix(varargin)
 
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

  % Collect all plists
  pl    = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  n_in  = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  if isempty(n_in)
    n_in = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  end
  
  noise = copy(n_in);
  
  if nargout == 0
    error('### computeICSMatrix cannot be used as a modifier. Please give an output variable.');
  end
  
  % check if input AOs are FSDATA
  if strcmpi(class(noise), 'ao') && isa(noise(1).data, 'fsdata')
    ISTSDATA = false;
    ISSMODEL = false;
  elseif strcmpi(class(noise), 'smodel')
    ISTSDATA = false;
    ISSMODEL = true;
  else
    ISTSDATA = true;
    ISSMODEL = false;
  end
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  Nout      = find(pl, 'Nout');
  freqs     = find(pl, 'freqs');
  BIND      = find(pl, 'bin data');
  ISDIAG    = find(pl, 'isdiag');
  intmethod = find(pl, 'interpolation method');
  POLYFT    = find(pl, 'fit noise model');
  ordrs     = find(pl, 'polynomial order');
  DOPLOT    = find(pl, 'plot fits');
  
  % Plist for PSD/CPSD and LPSD/LCPSD
  if strcmpi(pl.find('Noise scale'), 'psd');
    psdplist = pl.subset(getKeys(remove(ao.getInfo('psd').plists, 'times')));
    psd_fun  = @psd;
    cpsd_fun = @cpsd;
    psdplist.combine(plist.WELCH_PLIST);
  else
    psdplist = pl.subset(getKeys(remove(ao.getInfo('lpsd').plists, 'times')));
    psdplist = pset(psdplist, 'KDES', pl.find('Navs'));
    psd_fun  = @lpsd;
    cpsd_fun = @lcpsd;
    psdplist.combine(remove(plist.WELCH_PLIST, 'nfft', 'navs', 'drop window samples'));
  end
  
  % interpolate plist
  intpl = plist('vertices', freqs, 'method', intmethod);
  
  % initialize
  n  = ao.initObjectWithSize(Nout,Nout);
  S  = ao.initObjectWithSize(Nout,Nout);
  
  scale = 1; % fs/2; This factor is being moved to the fft of the data
  
  % Define the tile string
  titlestring = '(%d,%d) element of the cross-spectrum matrix';
  
  for ii = 1:Nout
    for jj = ii:Nout
      
      % Define information for the title
      title_info = sprintf(titlestring, ii, jj);
      
      % diagonal elements
      if (ii==jj)
        
        if ISTSDATA
        
          n(ii,jj)  = psd_fun(noise(ii), psdplist);

          if BIND; 
            n(ii,jj) = bin_data(n(ii,jj)); 
          end

          if POLYFT; 
            n(ii,jj) = polyfitSpectrum(n(ii,jj), plist('ffit',      [min(freqs) max(freqs)], ...
                                                       'orders',    ordrs, ...
                                                       'plot fits', DOPLOT));
            % set the correct title
            if DOPLOT
              title(title_info);
            end
          end
          
          % scale and interpolate
          S(ii,jj)  = scale*interp(n(ii,jj), intpl);
          
          % Set name
          S(ii,jj).setName(title_info);
          
        elseif ISSMODEL
          noise(ii,jj).setXvals(freqs);
          % get the response
          n(ii,jj) = eval(noise(ii,jj), plist('output x',freqs,'output type','fsdata'));
          S(ii,jj) = scale*n(ii,jj);
        else
          n(ii,jj) = copy(noise(ii));
          % scale and interpolate
          S(ii,jj) = scale*interp(n(ii,jj), intpl);
        end

      % case where non-diagonal elements are zeros  
      elseif (ii~=jj) && ISDIAG
        
        S(ii,jj) = copy(S(ii,jj-1));
        S(ii,jj) = S(ii,jj).setY(zeros(size(double(S(ii,jj)))));
        S(jj,ii) = copy(S(ii,jj));
        
      % case for non-zero non-diagonal elements  
      elseif (ii~=jj)
        
        if ISTSDATA
          
          n(ii,jj) = cpsd_fun(noise(ii),noise(jj), psdplist);

          if BIND; 
            n(ii,jj) = bin_data(n(ii,jj)); 
          end

          if POLYFT; 
            n(ii,jj) = polyfitSpectrum(n(ii,jj), plist('ffit',      [min(freqs) max(freqs)], ...
                                                       'orders',    ordrs, ...
                                                       'plot fits', DOPLOT));
            % set the correct title
            if DOPLOT
              title(sprintf(titlestring, ii, jj));
            end                                         
          end
          % scale and interpolate
          S(ii,jj) = scale*interp(n(ii,jj), intpl);
          
        elseif ISSMODEL
          noise(ii,jj).setXvals(freqs);
          % get the response
          n(ii,jj) = smodel.eval(noise(ii,jj), plist('output x',f,'output type','fsdata'));
          S(ii,jj) = scale*n(ii,jj);  
        else
          n(ii,jj) = copy(noise(ii,jj)); 
          % scale and interpolate
          S(ii,jj) = scale*interp(n(ii,jj), intpl);
        end
        
        % Set name
        S(ii,jj).setName(title_info);
        S(jj,ii) = conj(S(ii,jj));
        S(jj,ii).setName(sprintf(titlestring, jj, ii));
        
      end
      
    end
  end
  
  % do a plot if not already done at a previous step
  if DOPLOT && ~POLYFT
    hfig  = iplotPSD(S, plist('errorbartype', 'area'));
    grid on;
    % Rename figure
    set(hfig, 'Name', 'The cross-spectrum matrix of the noise','NumberTitle','off')
    title('The Cross-spectrum matrix of the noise.');
  end
  
  % Build cross-spectrum matrix object
  Smat = matrix(S, plist('shape',[Nout Nout]));
  
  % Calculate the inverse cross-spectrum matrix object
  if pl.find('inverse') && ISDIAG
    for ii = 1:Nout
      Smat.objs(ii,ii) = 1./Smat.getObjectAtIndex(ii,ii);
    end
    ICSM = copy(Smat);
  elseif pl.find('inverse')
    ICSM = inv(Smat);
  else
    ICSM = copy(Smat);
  end
  
  % add history
  ICSM = addHistory(ICSM, getInfo('None'), pl, [], []);

  % Set output
  varargout{1} = ICSM;
  
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
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl_default = buildplist()
  
  pl_default = plist();
  
  % INPUT
  p = param({'INPUT','The injection signals.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % NOUT
  p = param({'NOUT','The number of outputs.'}, paramValue.EMPTY_STRING);
  pl_default.append(p);
  
  % INVERSE
  p = param({'INVERSE','Set to false to return the spectrum matrix, but not inverted.'}, paramValue.TRUE_FALSE);
  pl_default.append(p);
  
  % ISDIAG
  p = param({'ISDIAG',['For the case of systems where the cross-spectrum matrix is diagonal it can be set to true '...
                       'to skip estimating the non-diagonal elements. Useful for multiple inputs/outputs.']}, paramValue.FALSE_TRUE);
  pl_default.append(p);
  
  % INTERP
  p = param({'INTERPOLATION METHOD','The interpolation method.'}, {1, {'LINEAR','SPLINE', 'PCHIP', 'CUBIC'}, paramValue.SINGLE});
  p.addAlternativeKey('INTERP METHOD');
  pl_default.append(p);
  
  % NAVS
  p = param({'NAVS','The number of averages to use when calculating PSD and CPSD.'}, paramValue.DOUBLE_VALUE(5));
  pl_default.append(p);
  
  % FREQUENCIES
  p = param({'FREQS','Array of frequencies where the analysis is performed.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  % NOISE SCALE
  p = plist({'NOISE SCALE',['Select the way to handle the noise/weight data. '...
             'Can use the PSD/CPSD or the LPSD/CLPSD functions.']}, {1, {'PSD','LPSD'}, paramValue.SINGLE});
  pl_default.append(p);
  
  % WIN
  p = plist({'WIN','The desired window to apply to the PSD of the noise.'}, paramValue.STRING_VALUE('BH92'));
  pl_default.append(p);
  
  % BIN DATA
  p = plist({'BIN DATA','Set to true to re-bin the measured noise data.'}, paramValue.FALSE_TRUE);
  pl_default.append(p);
  
  % OLAP
  p = param({'OLAP', 'The segment percent overlap [-1 == take from window function]'}, -1);
  pl_default.append(p); 
  
  % ORDER
  p = param({'ORDER', 'The order of segment detrending during PSD. For more info type ''doc ao.psd''.'}, 1);
  pl_default.append(p);
  
  % FIT NOISE MODEL
  p = plist({'FIT NOISE MODEL','Set to true to attempt a fit on the noise spectra using the ''polyfitSpectrum'' function.'}, paramValue.FALSE_TRUE);
  pl_default.append(p);
  
  % POLYNOMIAL ORDER
  p = plist({'POLYNOMIAL ORDER','The order of the polynomial to be used in the ''polyfitSpectrum'' function.'}, paramValue.DOUBLE_VALUE(-4:4));
  pl_default.append(p);
  
  % PLOT
  p = param({'PLOT FITS','Set to true to produce plots of the fits in case of ''fit noise model'' is set to true.'}, paramValue.FALSE_TRUE);
  pl_default.append(p);
  
  % combine with LPSD plist
  lpsdpl = ao.getInfo('lpsd').plists;
  
  % combine with PSD plist
  psdpl = ao.getInfo('psd').plists;
  
  pl_default = remove(combine(pl_default, lpsdpl, psdpl), 'times');
  
end

% END
