% SINEPARAMS estimates parameters of sinusoids
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SINEPARAMS estimates the parameters of the sinusoids in the
%              time series. Number of sinusoids needs to be specified.
%
% CALL:        b = sineParams(a,pl)
%
% INPUTS:      a  - input AOs
%              pl - parameter list (see below)
%
% OUTPUTs:     b  - pest object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'sineParams')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = sineParams(varargin)
  
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
  [aos, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  %%% Decide on a deep copy or a modify
  bs = copy(aos, nargout);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % check (current version with only one AO)
  if numel(aos) >1
    error('### Current version of ''sineParams'' works only with one AO')
  end
  
  % get parameters
  Nsine = find_core(pl, 'N');
  realSine  = find_core(pl, 'real');
  method = find_core(pl,'method');
  nonlin = find_core(pl,'non-linear');
  
  % check number of sinusoids
  if isempty(Nsine)
    error('### You need to set the number of sinusoids ''N'' ')
  end
  
  if realSine
    Nexp = 2*Nsine;
  else
    Nexp = Nsine;
  end
  f =[];A=[];
  %   for i = 1:numel(bs)
  
  switch method
    case 'MUSIC'
      % MUSIC algorithm
      [w,pow,w_mse,pow_mse] = utils.math.rootmusic(bs.y,Nexp,bs.fs);
      
      if realSine
        f = w(1:2:end);
        df = w_mse(1:2:end);
        %         A = pow;
        %         dA = pow_mse;
        A = sqrt(2*pow); % from the expression for power in a sinusoid
        dA = 1/sqrt(2*pow)*pow_mse;
      else
        f = w;
        df = w_mse;
        A = sqrt(2*pow); % from the expression for power in a sinusoid
        dA = A*sqrt(2/pow)*pow_mse;
      end
      
    case 'ESPRIT'
      
      % p = 1; % num. sinusoid
      % N = 50;
      %
      % m = xcov(c.y,N-1);
      %
      % clear cmat
      % for i =1:N
      % cmat(i,:) = m(N-(i-1):end-(i-1));
      % end
      %
      % [U,S,UT] = svd(cmat);
      %
      % D = diag(S);
      %
      % Ls = D(1:2*p);
      % Us = U(:,1:2*p);
      %
      % A1 = Us(1:end-1,:);
      % A2 = Us(2:end,:);
      %
      % M = A1\A2;
      %
      % freq = imag(-log(eig(M))/2/pi*fs)
      % error = real(-log(eig(M))/2/pi*fs)
      
    case 'IFFT'
      
      %   % fft
      %     p = psd(phi(i),plist('win','Hanning','scale','AS','Navs',1));
      %
      %     [m,index] = max(p.y);
      %     ratio between max. and next value
      %     alpha = p.y(index+1)/p.y(index);
      %
      %     xm = (2*alpha-1)/(alpha+1);
      %     frequency
      %     f(i) = (i+xm)/phi(i).nsecs;
      %     amplitude
      %     A(i) = abs(2*pi*xm*(1-xm)/sin(pi*xm)*exp(-pi*1i*xm)*(1*xm)*p.y(i));
      %
      %
      %
      %
  end
  %   end
  
  % create output pest
  mdl = [];
  p = pest();
  for i = 1:Nsine
    Cname = sprintf('C%d',i);
    fname = sprintf('f%d',i);
    Aname = sprintf('A%d',i);
    pname = sprintf('phi%d',i);
    % setY
    p.setYforParameter(Cname,0);
    p.setYforParameter(Aname,A(i));
    p.setYforParameter(fname,f(i));
    p.setYforParameter(pname,0);
    % errors for single sinusoid only, error is the sqrt(mse)
    if Nsine == 1
      p.setDyForParameter(Cname,inf);
      p.setDyForParameter(Aname,sqrt(dA(i)));
      p.setDyForParameter(fname,sqrt(df(i)));
      p.setDyForParameter(pname,inf);
    end
    
    % set yunits for the amplitude and dc offset, if possible
    if ~isempty(bs.yunits)
      p.setYunitsForParameter(Aname, bs.yunits);
      p.setYunitsForParameter(Cname, bs.yunits);
    end
    % set units for frequency
    p.setYunitsForParameter(fname, 'Hz');
    
    % smodel for each sinusoid
    m = smodel(sprintf('%s + %s*sin(2*pi*%s*t+%s)',Cname,Aname,fname,pname));
    m.setXunits(unit.seconds);
    m.setXvar('t');
    m.setXvals(bs.x);
    m.setParams({Cname,Aname,fname,pname},[0 A(i) f(i) 0]);
    % optional non-linear
    if nonlin
      pl = plist('Function',m);
      pnl = xfit(bs,pl);
      p.setY(pnl.y);
      p.setDy(pnl.dy);
      p.setCorr(pnl.corr);
      p.setCov(pnl.cov);
      p.setDof(pnl.dof);
      p.setChi2(pnl.chi2);
      % set values in model as well
      m.setValues(pnl.y);
    end
    mdl = [mdl m];
  end
  % set name
  p.name = sprintf('sineParams(%s)', ao_invars{:});
  % set models
  p.setModels(mdl);
  % Add history
  p.addHistory(getInfo('None'), pl, ao_invars(:), bs(:).hist);
  
  % Set outputs
  if nargout > 0
    varargout{1} = p;
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
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  
  pl = plist();
  
  % number of sinusoids
  p = param({'N', 'Number of sinusoids/complex exp. in the time series'},paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  % number of sinusoids
  p = param({'real', 'Set to true if working with real sinusoids'},paramValue.TRUE_FALSE);
  pl.append(p);
  
  % number of sinusoids
  p = param({'method', ['Choose one of the following methods:<ul>', ...
    '<li>MUSIC  - MUltiple SIgnal Classification algorithm </li>']}, {1, {'MUSIC'}, paramValue.SINGLE});
  pl.append(p);
  
  % non-linear
  p = param({'non-linear','Set to true to perform non-linear fit'},...
    paramValue.FALSE_TRUE);
  pl.append(p);
  
end
% END

