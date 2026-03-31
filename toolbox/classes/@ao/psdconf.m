% PSDCONF Calculates confidence levels and variance for psd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PSDCONF Input a spectrum estimated with psd or lpsd (Welch's
% Overlapped Segment Averaging Method) and calculates confidence levels and
% variance for the spectrum.
%
% CALL:         [lcl,ucl] = psdconf(a,pl)
%               [lcl,ucl,var] = psdconf(a,pl)
%
% INPUTS:
%               a  -  input analysis objects containing power spectral
%                     densities calculated with psd or lpsd.
%               pl  - input parameter list
%
% OUTPUTS:                
%               lcl - lower confidence level
%               ucl - upper confidence level
%               var - expected spectrum variance
%
%
%              If the last input argument is a parameter list (plist).
%              The following parameters are recognised.
%
% 
% NOTE1: PSDCONF checks the navs field to distinguish between psd and lpsd
% power spectra. If a.data.navs is NaN then it assumes to dealing with lpsd
% power spectrum at input.
%
% NOTE2: Copied directly from MATLAB chi2conf function (Signal Processing
% Toolbox) and extended to do degrees of fredom calculation, variance
% calculation, to input AOs and to input plist.
%   Copyright 2007 The MathWorks, Inc.
%   Revision: 1.6.4.4   Date: 2008/05/31 23:27:28 
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'psdconf')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = psdconf(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  %%% Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  %%% Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  %%% avoid multiple AO at input
  if numel(as)>1
    error('!!! Too many input AOs, PSDCONF can process only one AO per time !!!')
  end
  
  %%% check that fsdata is input
  if ~isa(as.data, 'fsdata')
    error('!!! Non-fsdata input, PSDCONF can process only fsdata !!!')
  end
  
  %%% avoid input modification
  if nargout == 0
    error('!!! PSDCONF cannot be used as a modifier. Please give an output variable !!!');
  end
  
  %%% Parse plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  %%% Find parameters
  conf    = find_core(pl, 'conf');
  conf = conf/100; % go from percentage to fractional
  
  %%% getting metho
  if  isnan(as.data.navs)
    mtd = 'lpsd';
  else
    mtd = 'psd';
  end
  
  %%% switching over methods
  switch mtd
    case 'psd'
      %%% confidence levels for spectra calculated with psd
      % get number of averages
      navs = as.data.navs;
      % get window object
      w = as.hist.plistUsed.find_core('WIN');
      % percentage of overlap
      olap = as.hist.plistUsed.find_core('OLAP')./100;
      % number of bins in each fft
      nfft = as.hist.plistUsed.find_core('NFFT');
      
      % Normalize window data in order to be square integrable to 1
      win = w.win ./ sqrt(w.ws2);
      
      % Calculates total number of data in the original time-series
      Ntot = ceil(navs*(nfft-olap*nfft)+olap*nfft);
      
      % defining the shift factor
      n = floor((Ntot-nfft)./(navs-1));
      
      % Calculating correction factor
      sm = 0;
      % Padding to zero the window
      % willing to work with columns
      [ii,kk] = size(win);
      if ii<kk
        win = win.';
      end
      win = [win; zeros(navs*n,1)];
      for mm = 1:navs-1
        pc = 0;
        for tt = 1:nfft
          pc = pc + win(tt)*win(tt + mm*n);
        end
        sm = sm + (1 - mm/navs)*(abs(pc)^2);
      end
      % Calculating degrees of freedom
      dof = (2*navs)/(1+2*sm);
      dof = round(dof);
      
      % Calculating Confidence Levels factors
      alfa = 1 - conf;
      c = chi2inv([1-alfa/2 alfa/2],dof);
      c = dof./c;
      
      % calculating variance
      expvar = ((as.data.y).^2).*2./dof;
      
      % calculating confidence levels
      lwb = as.data.y.*c(1);
      upb = as.data.y.*c(2);
      
    case 'lpsd'
      %%% confidence levels for spectra calculated with lpsd
      % get window used
      uwin = as.hist.plistUsed.find_core('WIN');
      
      % extract number of frequencies bins
      nf = length(as.x);
      
      % dft length for each bin
      if ~isempty(as.procinfo)
        L = as.procinfo.find_core('L');
      else
        error('### The AO doesn''t have any procinfo with the key ''L''');
      end
      
      % set original data length as the length of the first window
      nx = L(1);
      
      % windows overlap
      olap = as.hist.plistUsed.find_core('OLAP');
      
      dofs = ones(nf,1);
      cl = ones(nf,2);
      for jj=1:nf
        l = L(jj);
        % compute window
        switch uwin.type
          case 'Kaiser'
            w = specwin(uwin.type, l, uwin.psll);
          otherwise
            w = specwin(uwin.type, l);
        end
        % Normalize window data in order to be square integrable to 1
        owin = w.win ./ sqrt(w.ws2);
        
        % Compute the number of averages we want here
        segLen = l;
        nData  = nx;
        ovfact = 1 / (1 - olap);
        davg   = (((nData - segLen)) * ovfact) / segLen + 1;
        navg   = round(davg);
        
        % Compute steps between segments
        if navg == 1
          shift = 1;
        else
          shift = (nData - segLen) / (navg - 1);
        end
        if shift < 1 || isnan(shift)
          shift = 1;
        end
        n = floor(shift);
        
        % Calculating correction factor
        sm = 0;
        % Padding to zero the window
        % willing to work with columns
        [ii,kk] = size(owin);
        if ii<kk
          owin = owin.';
        end
        win = [owin; zeros(navg*n,1)];
        for mm = 1:navg-1
          pc = 0;
          for tt = 1:segLen
            pc = pc + win(tt)*win(tt + mm*n);
          end
          sm = sm + (1 - mm/navg)*(abs(pc)^2);
        end
        % Calculating degrees of freedom
        dof = (2*navg)/(1+2*sm);
        dof = round(dof);

        % Calculating Confidence Levels factors
        alfa = 1 - conf;
        c = chi2inv([1-alfa/2 alfa/2],dof);
        c = dof./c;
        
        % storing c and dof
        dofs(jj) = dof;
        cl(jj,1) = c(1);
        cl(jj,2) = c(2);
      end % for jj=1:nf
      
      % willing to work with columns
      dy = as.data.y;
      [ii,kk] = size(dy);
      if ii<kk
        dy = dy.';
        rsp = true;
      else
        rsp = false;
      end
      % calculating variance
      expvar = ((dy).^2).*2./dofs;
      
      % calculating confidence levels
      lwb = dy.*cl(:,1);
      upb = dy.*cl(:,2);
      
      % reshaping if necessary
      if rsp
        expvar = expvar.';
        lwb = lwb.';
        upb = upb.';
      end
      
  end %switch mtd
  
  % Output data
  
  % defining units
  inputunit = get(as.data,'yunits');
  varunit = unit(inputunit.^2);
  varunit.simplify;
  levunit = inputunit;
  levunit.simplify;
  
  
  % variance
  dvar = fsdata();
  dvar.setFs(as.data.fs);
  dvar.setT0(as.data.t0);
  dvar.setEnbw(as.data.enbw);
  dvar.setNavs(as.data.navs);
  dvar.setXunits(copy(as.data.xunits,1));
  dvar.setYunits(varunit);
  dvar.setX(as.data.x);
  dvar.setY(expvar);
  ovar = ao(dvar);
  % Set output AO name
  ovar.name = sprintf('var(%s)', ao_invars{:});
  % Add history
  ovar.addHistory(getInfo('None'), pl, [ao_invars(:)], [as.hist]);
  
  % lower confidence level
  dlwb = fsdata();
  dlwb.setFs(as.data.fs);
  dlwb.setT0(as.data.t0);
  dlwb.setEnbw(as.data.enbw);
  dlwb.setNavs(as.data.navs);
  dlwb.setXunits(copy(as.data.xunits,1));
  dlwb.setYunits(levunit);
  dlwb.setX(as.data.x);
  dlwb.setY(lwb);
  olwb = ao(dlwb);
  % Set output AO name
  clev = [num2str(conf*100) '%'];
  olwb.name = sprintf('%s_low_conf_level(%s)', clev, ao_invars{:});
  % Add history
  olwb.addHistory(getInfo('None'), pl, [ao_invars(:)], [as.hist]);
  
  % upper confidence level
  dupb = fsdata();
  dupb.setFs(as.data.fs);
  dupb.setT0(as.data.t0);
  dupb.setEnbw(as.data.enbw);
  dupb.setNavs(as.data.navs);
  dupb.setXunits(copy(as.data.xunits,1));
  dupb.setYunits(levunit);
  dupb.setX(as.data.x);
  dupb.setY(upb);
  oupb = ao(dupb);
  % Set output AO name
  oupb.name = sprintf('%s_up_conf_level(%s)', clev, ao_invars{:});
  % Add history
  oupb.addHistory(getInfo('None'), pl, [ao_invars(:)], [as.hist]);
  
  % output
  if nargout == 2
    varargout{1} = olwb; % lower conf level
    varargout{2} = oupb; % upper conf level
  elseif nargout == 3
    varargout{1} = olwb; % lower conf level
    varargout{2} = oupb; % upper conf level
    varargout{3} = ovar; % expected variance
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----- Matlab Functions ---------------------------------------------------

%--------------------------------------------------------------------------
function x = chi2inv(p,v)
  %CHI2INV Inverse of the chi-square cumulative distribution function (cdf).
  %   X = CHI2INV(P,V)  returns the inverse of the chi-square cdf with V
  %   degrees of freedom at the values in P. The chi-square cdf with V
  %   degrees of freedom, is the gamma cdf with parameters V/2 and 2.
  %
  %   The size of X is the common size of P and V. A scalar input
  %   functions as a constant matrix of the same size as the other input.
  
  %   References:
  %      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
  %      Functions", Government Printing Office, 1964, 26.4.
  %      [2] E. Kreyszig, "Introductory Mathematical Statistics",
  %      John Wiley, 1970, section 10.2 (page 144)
  
  
  if nargin < 2,
    error(generatemsgid('Nargchk'),'Requires two input arguments.');
  end
  
  [errorcode p v] = distchck(2,p,v);
  
  if errorcode > 0
    error(generatemsgid('InvalidDimensions'),'Requires non-scalar arguments to match in size.');
  end
  
  % Call the gamma inverse function.
  x = gaminv(p,v/2,2);
  
  % Return NaN if the degrees of freedom is not a positive integer.
  k = find(v < 0  |  round(v) ~= v);
  if any(k)
    tmp  = NaN;
    x(k) = tmp(ones(size(k)));
  end
  
end

%--------------------------------------------------------------------------

function x = gaminv(p,a,b)
  %GAMINV Inverse of the gamma cumulative distribution function (cdf).
  %   X = GAMINV(P,A,B)  returns the inverse of the gamma cdf with
  %   parameters A and B, at the probabilities in P.
  %
  %   The size of X is the common size of the input arguments. A scalar input
  %   functions as a constant matrix of the same size as the other inputs.
  %
  %   GAMINV uses Newton's method to converge to the solution.
  
  %   References:
  %      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
  %      Functions", Government Printing Office, 1964, 6.5.
  
  %   B.A. Jones 1-12-93
  %   Was: Revision: 1.2, Date: 1996/07/25 16:23:36
  
  if nargin<3,
    b=1;
  end
  
  [errorcode p a b] = distchck(3,p,a,b);
  
  if errorcode > 0
    error(generatemsgid('InvalidDimensions'),'The arguments must be the same size or be scalars.');
  end
  
  %   Initialize X to zero.
  x = zeros(size(p));
  
  k = find(p<0 | p>1 | a <= 0 | b <= 0);
  if any(k),
    tmp = NaN;
    x(k) = tmp(ones(size(k)));
  end
  
  % The inverse cdf of 0 is 0, and the inverse cdf of 1 is 1.
  k0 = find(p == 0 & a > 0 & b > 0);
  if any(k0),
    x(k0) = zeros(size(k0));
  end
  
  k1 = find(p == 1 & a > 0 & b > 0);
  if any(k1),
    tmp = Inf;
    x(k1) = tmp(ones(size(k1)));
  end
  
  % Newton's Method
  % Permit no more than count_limit iterations.
  count_limit = 100;
  count = 0;
  
  k = find(p > 0  &  p < 1 & a > 0 & b > 0);
  pk = p(k);
  
  % Supply a starting guess for the iteration.
  %   Use a method of moments fit to the lognormal distribution.
  mn = a(k) .* b(k);
  v = mn .* b(k);
  temp = log(v + mn .^ 2);
  mu = 2 * log(mn) - 0.5 * temp;
  sigma = -2 * log(mn) + temp;
  xk = exp(norminv(pk,mu,sigma));
  
  h = ones(size(pk));
  
  % Break out of the iteration loop for three reasons:
  %  1) the last update is very small (compared to x)
  %  2) the last update is very small (compared to sqrt(eps))
  %  3) There are more than 100 iterations. This should NEVER happen.
  
  while(any(abs(h) > sqrt(eps)*abs(xk))  &  max(abs(h)) > sqrt(eps)    ...
      & count < count_limit),
    
    count = count + 1;
    h = (gamcdf(xk,a(k),b(k)) - pk) ./ gampdf(xk,a(k),b(k));
    xnew = xk - h;
    % Make sure that the current guess stays greater than zero.
    % When Newton's Method suggests steps that lead to negative guesses
    % take a step 9/10ths of the way to zero:
    ksmall = find(xnew < 0);
    if any(ksmall),
      xnew(ksmall) = xk(ksmall) / 10;
      h = xk-xnew;
    end
    xk = xnew;
  end
  
  
  % Store the converged value in the correct place
  x(k) = xk;
  
  if count == count_limit,
    fprintf('\nWarning: GAMINV did not converge.\n');
    str = 'The last step was:  ';
    outstr = sprintf([str,'%13.8f'],h);
    fprintf(outstr);
  end
end

%--------------------------------------------------------------------------
function x = norminv(p,mu,sigma)
  %NORMINV Inverse of the normal cumulative distribution function (cdf).
  %   X = NORMINV(P,MU,SIGMA) finds the inverse of the normal cdf with
  %   mean, MU, and standard deviation, SIGMA.
  %
  %   The size of X is the common size of the input arguments. A scalar input
  %   functions as a constant matrix of the same size as the other inputs.
  %
  %   Default values for MU and SIGMA are 0 and 1 respectively.
  
  %   References:
  %      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
  %      Functions", Government Printing Office, 1964, 7.1.1 and 26.2.2
  
  %   Was: Revision: 1.2, Date: 1996/07/25 16:23:36
  
  if nargin < 3,
    sigma = 1;
  end
  
  if nargin < 2;
    mu = 0;
  end
  
  [errorcode p mu sigma] = distchck(3,p,mu,sigma);
  
  if errorcode > 0
    error(generatemsgid('InvalidDimensions'),'Requires non-scalar arguments to match in size.');
  end
  
  % Allocate space for x.
  x = zeros(size(p));
  
  % Return NaN if the arguments are outside their respective limits.
  k = find(sigma <= 0 | p < 0 | p > 1);
  if any(k)
    tmp  = NaN;
    x(k) = tmp(ones(size(k)));
  end
  
  % Put in the correct values when P is either 0 or 1.
  k = find(p == 0);
  if any(k)
    tmp  = Inf;
    x(k) = -tmp(ones(size(k)));
  end
  
  k = find(p == 1);
  if any(k)
    tmp  = Inf;
    x(k) = tmp(ones(size(k)));
  end
  
  % Compute the inverse function for the intermediate values.
  k = find(p > 0  &  p < 1 & sigma > 0);
  if any(k),
    x(k) = sqrt(2) * sigma(k) .* erfinv(2 * p(k) - 1) + mu(k);
  end
end

%--------------------------------------------------------------------------
function p = gamcdf(x,a,b)
  %GAMCDF Gamma cumulative distribution function.
  %   P = GAMCDF(X,A,B) returns the gamma cumulative distribution
  %   function with parameters A and B at the values in X.
  %
  %   The size of P is the common size of the input arguments. A scalar input
  %   functions as a constant matrix of the same size as the other inputs.
  %
  %   Some references refer to the gamma distribution with a single
  %   parameter. This corresponds to the default of B = 1.
  %
  %   GAMMAINC does computational work.
  
  %   References:
  %      [1]  L. Devroye, "Non-Uniform Random Variate Generation",
  %      Springer-Verlag, 1986. p. 401.
  %      [2]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
  %      Functions", Government Printing Office, 1964, 26.1.32.
  
  %   Was: Revision: 1.2, Date: 1996/07/25 16:23:36
  
  if nargin < 3,
    b = 1;
  end
  
  if nargin < 2,
    error(generatemsgid('Nargchk'),'Requires at least two input arguments.');
  end
  
  [errorcode x a b] = distchck(3,x,a,b);
  
  if errorcode > 0
    error(generatemsgid('InvalidDimensions'),'Requires non-scalar arguments to match in size.');
  end
  
  %   Return NaN if the arguments are outside their respective limits.
  k1 = find(a <= 0 | b <= 0);
  if any(k1)
    tmp   = NaN;
    p(k1) = tmp(ones(size(k1)));
  end
  
  % Initialize P to zero.
  p = zeros(size(x));
  
  k = find(x > 0 & ~(a <= 0 | b <= 0));
  if any(k),
    p(k) = gammainc(x(k) ./ b(k),a(k));
  end
  
  % Make sure that round-off errors never make P greater than 1.
  k = find(p > 1);
  if any(k)
    p(k) = ones(size(k));
  end
end

%--------------------------------------------------------------------------
function y = gampdf(x,a,b)
  %GAMPDF Gamma probability density function.
  %   Y = GAMPDF(X,A,B) returns the gamma probability density function
  %   with parameters A and B, at the values in X.
  %
  %   The size of Y is the common size of the input arguments. A scalar input
  %   functions as a constant matrix of the same size as the other inputs.
  %
  %   Some references refer to the gamma distribution with a single
  %   parameter. This corresponds to the default of B = 1.
  
  %   References:
  %      [1]  L. Devroye, "Non-Uniform Random Variate Generation",
  %      Springer-Verlag, 1986, pages 401-402.
  
  %   Was: Revision: 1.2, Date: 1996/07/25 16:23:36
  
  if nargin < 3,
    b = 1;
  end
  
  if nargin < 2,
    error(generatemsgid('Nargchk'),'Requires at least two input arguments');
  end
  
  [errorcode x a b] = distchck(3,x,a,b);
  
  if errorcode > 0
    error(generatemsgid('InvalidDimensions'),'Requires non-scalar arguments to match in size.');
  end
  
  % Initialize Y to zero.
  y = zeros(size(x));
  
  %   Return NaN if the arguments are outside their respective limits.
  k1 = find(a <= 0 | b <= 0);
  if any(k1)
    tmp = NaN;
    y(k1) = tmp(ones(size(k1)));
  end
  
  k=find(x > 0 & ~(a <= 0 | b <= 0));
  if any(k)
    y(k) = (a(k) - 1) .* log(x(k)) - (x(k) ./ b(k)) - gammaln(a(k)) - a(k) .* log(b(k));
    y(k) = exp(y(k));
  end
  k1 = find(x == 0 & a < 1);
  if any(k1)
    tmp = Inf;
    y(k1) = tmp(ones(size(k1)));
  end
  k2 = find(x == 0 & a == 1);
  if any(k2)
    y(k2) = (1./b(k2));
  end
end

function [errorcode,out1,out2,out3,out4] = distchck(nparms,arg1,arg2,arg3,arg4)
  %DISTCHCK Checks the argument list for the probability functions.
  
  %   B.A. Jones  1-22-93
  %   Was: Revision: 1.2, Date: 1996/07/25 16:23:36
  
  errorcode = 0;
  
  if nparms == 1
    out1 = arg1;
    return;
  end
  
  if nparms == 2
    [r1 c1] = size(arg1);
    [r2 c2] = size(arg2);
    scalararg1 = (prod(size(arg1)) == 1);
    scalararg2 = (prod(size(arg2)) == 1);
    if ~scalararg1 & ~scalararg2
      if r1 ~= r2 | c1 ~= c2
        errorcode = 1;
        return;
      end
    end
    if scalararg1
      out1 = arg1(ones(r2,1),ones(c2,1));
    else
      out1 = arg1;
    end
    if scalararg2
      out2 = arg2(ones(r1,1),ones(c1,1));
    else
      out2 = arg2;
    end
  end
  
  if nparms == 3
    [r1 c1] = size(arg1);
    [r2 c2] = size(arg2);
    [r3 c3] = size(arg3);
    scalararg1 = (prod(size(arg1)) == 1);
    scalararg2 = (prod(size(arg2)) == 1);
    scalararg3 = (prod(size(arg3)) == 1);
    
    if ~scalararg1 & ~scalararg2
      if r1 ~= r2 | c1 ~= c2
        errorcode = 1;
        return;
      end
    end
    
    if ~scalararg1 & ~scalararg3
      if r1 ~= r3 | c1 ~= c3
        errorcode = 1;
        return;
      end
    end
    
    if ~scalararg3 & ~scalararg2
      if r3 ~= r2 | c3 ~= c2
        errorcode = 1;
        return;
      end
    end
    
    if ~scalararg1
      out1 = arg1;
    end
    if ~scalararg2
      out2 = arg2;
    end
    if ~scalararg3
      out3 = arg3;
    end
    rows = max([r1 r2 r3]);
    columns = max([c1 c2 c3]);
    
    if scalararg1
      out1 = arg1(ones(rows,1),ones(columns,1));
    end
    if scalararg2
      out2 = arg2(ones(rows,1),ones(columns,1));
    end
    if scalararg3
      out3 = arg3(ones(rows,1),ones(columns,1));
    end
    out4 =[];
    
  end
  
  if nparms == 4
    [r1 c1] = size(arg1);
    [r2 c2] = size(arg2);
    [r3 c3] = size(arg3);
    [r4 c4] = size(arg4);
    scalararg1 = (prod(size(arg1)) == 1);
    scalararg2 = (prod(size(arg2)) == 1);
    scalararg3 = (prod(size(arg3)) == 1);
    scalararg4 = (prod(size(arg4)) == 1);
    
    if ~scalararg1 & ~scalararg2
      if r1 ~= r2 | c1 ~= c2
        errorcode = 1;
        return;
      end
    end
    
    if ~scalararg1 & ~scalararg3
      if r1 ~= r3 | c1 ~= c3
        errorcode = 1;
        return;
      end
    end
    
    if ~scalararg1 & ~scalararg4
      if r1 ~= r4 | c1 ~= c4
        errorcode = 1;
        return;
      end
    end
    
    if ~scalararg3 & ~scalararg2
      if r3 ~= r2 | c3 ~= c2
        errorcode = 1;
        return;
      end
    end
    
    if ~scalararg4 & ~scalararg2
      if r4 ~= r2 | c4 ~= c2
        errorcode = 1;
        return;
      end
    end
    
    if ~scalararg3 & ~scalararg4
      if r3 ~= r4 | c3 ~= c4
        errorcode = 1;
        return;
      end
    end
    
    
    if ~scalararg1
      out1 = arg1;
    end
    if ~scalararg2
      out2 = arg2;
    end
    if ~scalararg3
      out3 = arg3;
    end
    if ~scalararg4
      out4 = arg4;
    end
    
    rows = max([r1 r2 r3 r4]);
    columns = max([c1 c2 c3 c4]);
    if scalararg1
      out1 = arg1(ones(rows,1),ones(columns,1));
    end
    if scalararg2
      out2 = arg2(ones(rows,1),ones(columns,1));
    end
    if scalararg3
      out3 = arg3(ones(rows,1),ones(columns,1));
    end
    if scalararg4
      out4 = arg4(ones(rows,1),ones(columns,1));
    end
  end
end

%----- LTPDA FUNCTIONS ----------------------------------------------------
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
  ii.setOutmin(2);
  ii.setOutmax(3);
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
  pl = plist({'conf', 'Required percentage confidence level. [0-100]'}, paramValue.DOUBLE_VALUE(95));
end
% END

% PARAMETERS: 
%             'conf'  - Required percentage confidence level. It is a
%                       number between 0 and 100 [Default: 95,
%                       corresponding to 95% confidence].
