% CONFINT Calculates confidence levels and variance for psd, lpsd, cohere, lcohere and curvefit parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CONFINT Input psd, mscohere (magnitude square coherence) 
% and return confidence levels and variance for them.
% Spectra are assumed to be calculated with the WOSA method (Welch's
% Overlapped Segment Averaging Method)
%
% CALL:         out = confint(a,pl)
%               
%
% INPUTS:
%               a  -  input analysis objects containing power spectral
%                     densities or magintude squared coherence.
%               pl  - input parameter list
%
% OUTPUTS:         
%               out - a collection object containing:
%                 lcl - lower confidence level
%                 ucl - upper confidence level
%                 var - expected spectrum variance
%
%
%              If the last input argument is a parameter list (plist).
%              The following parameters are recognised.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'confint')">Parameters Description</a>
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = confint(varargin)
  
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
    error('!!! Too many input AOs, CONFINT can process only one AO per time !!!')
  end
  
  %%% avoid input modification
  if nargout == 0
    error('!!! CONFINT cannot be used as a modifier. Please give an output variable !!!');
  end
  
  %%% Parse plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  %%% Find parameters
  mtd  = lower(find_core(pl, 'method'));
  conf = find_core(pl, 'conf');
  dof  = find_core(pl, 'dof');
  conf = conf/100; % go from percentage to fractional
  Ntot = find_core(pl,'DataLength');
  
  %%% check that fsdata is input
  if ~isa(as.data, 'fsdata')
    error('!!! Non-fsdata input, CONFINT can process only fsdata !!!')
  end

  
  % looking to dof
  if isempty(dof)
    calcdof = true;
  else
    if isa(dof, 'ao')
      dof = dof.data.y;
      calcdof = false;
    else
      calcdof = false;
    end
  end
    
  
  %%% switching over methods
  switch mtd
    case 'psd'
      %%% confidence levels for spectra calculated with psd
      
      % calculating dof
      if calcdof
        dofs = getdof(as,plist('method',mtd,'DataLength',Ntot));
        dof = dofs.y;
      end % if calcdof
      dof = round(dof);
      if length(dof)~=1
        error('!!! CONFINT for ao/psd method, dof must be a single number')
      end
      
      % Calculating Confidence Levels factors
      alfa = 1 - conf;
      c = utils.math.Chi2inv([1-alfa/2 alfa/2],dof);
      c = dof./c;
      
      % calculating variance
      expvar = ((as.data.y).^2).*2./dof;
      
      % calculating confidence levels
      lwb = as.data.y.*c(1);
      upb = as.data.y.*c(2);
      
    case 'lpsd'
      %%% confidence levels for spectra calculated with lpsd
      
      % calculating dof
      if calcdof
        dofs = getdof(as,plist('method',mtd,'DataLength',Ntot));
        dofs = dofs.y;

        % extract number of frequencies bins
        nf = length(as.x);
        
        cl = ones(nf,2);
        for jj=1:nf

          % Calculating Confidence Levels factors
          alfa = 1 - conf;
          c = utils.math.Chi2inv([1-alfa/2 alfa/2],dofs(jj));
          c = dofs(jj)./c;

          % storing c
          cl(jj,1) = c(1);
          cl(jj,2) = c(2);
        end % for jj=1:nf
      else % if calcdof
        if length(dof)~=length(as.x)
          error('!!! CONFINT for ao/lpsd method, dof must be a vector of the same length of the frequencies vector')
        end
        dofs = round(dof);
        cl = ones(length(as.x),2);
        for jj = 1:length(as.x)
          % Calculating Confidence Levels factors
          alfa = 1 - conf;
          c = utils.math.Chi2inv([1-alfa/2 alfa/2],dofs(jj));
          c = dofs(jj)./c;

          % storing c
          cl(jj,1) = c(1);
          cl(jj,2) = c(2);
        end
      end % if calcdof
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
      
    case 'mscohere'
      %%% confidence levels for mscohere calculated with ao/cohere
      
      % calculating dof
      if calcdof
        dofs = getdof(as,plist('method',mtd,'DataLength',Ntot));
        dof = dofs.y;
      end % if calcdof
      dof = round(dof);
      if length(dof)~=1
        error('!!! CONFINT for ao/cohere method, dof must be a single number')
      end
      
      % Defining Y variable
      Y = atanh(sqrt(as.data.y));
      
      % Calculating Confidence Levels factor
      alfa = 1 - conf;
      c = -sqrt(2).*erfcinv(2*(1-alfa/2))./sqrt(dof);
      Ylwb = Y - c;
      Yupb = Y + c;
      
      % calculating confidence levels
      lwb = tanh(Ylwb).^2;
      upb = tanh(Yupb).^2;
      
      % calculating variance
      expvar = ((1-(as.data.y).^2).^2).*((as.data.y).^2).*4./dof;
      
    case 'mslcohere'
      %%% confidence levels for spectra calculated with lpsd
      
      % calculating dof
      if calcdof
        dofs = getdof(as,plist('method',mtd,'DataLength',Ntot));
        dofs = dofs.y;

        % extract number of frequencies bins
        nf = length(as.x);
       
        % willing to work with columns
        dy = as.data.y;
        [ii,kk] = size(dy);
        if ii<kk
          dy = dy.';
          rsp = true;
        else
          rsp = false;
        end
  
        % Defining Y variable
        Y = atanh(sqrt(dy));

        cl = ones(nf,2);
        for jj=1:nf

          % Calculating Confidence Levels factors
          alfa = 1 - conf;
          c = -sqrt(2).*erfcinv(2*(1-alfa/2))./sqrt(dofs(jj));

          % storing c and dof
          cl(jj,1) = Y(jj) - c;
          cl(jj,2) = Y(jj) + c;
        end % for jj=1:nf
        
      else % if calcdof
        if length(dof)~=length(as.x)
          error('!!! CONFINT for ao/lcohere method, dof must be a vector of the same length of the frequencies vector')
        end
        dofs = round(dof);
        
        % willing to work with columns
        dy = as.data.y;
        [ii,kk] = size(dy);
        if ii<kk
          dy = dy.';
          rsp = true;
        else
          rsp = false;
        end
        
        % Defining Y variable
        Y = atanh(sqrt(dy));
        
        cl = ones(length(as.x),2);
        for jj = 1:length(as.x)
          % Calculating Confidence Levels factors
          alfa = 1 - conf;
          c = -sqrt(2).*erfcinv(2*(1-alfa/2))./sqrt(dofs(jj));

          % storing c
          cl(jj,1) = Y(jj) - c;
          cl(jj,2) = Y(jj) + c;
        end
      end % if calcdof
      
      % calculating variance
      expvar = ((1-(dy).^2).^2).*((dy).^2).*4./dofs;
      
      % get not well defined coherence estimations
      idd = dofs<=2;
      
      % calculating confidence levels
      lwb = tanh(cl(:,1));
      % remove negative elements
      idx = lwb < 0;
      lwb(idx) = 0;
      % set lower bound to zero in points where coharence is not well defined 
      lwb(idd) = 0;
      upb = tanh(cl(:,2));
      % set upper bound to one in points where coharence is not well
      % defined
      upb(idd) = 1;
      lwb = lwb.^2;
      upb = upb.^2;
      
      % reshaping if necessary
      if rsp
        expvar = expvar.';
        lwb = lwb.';
        upb = upb.';
      end
      
      
      
  end %switch mtd
  
  % Output data
 
    
  % defining units
  inputunit = as.yunits;
  varunit = unit(inputunit.^2);
  varunit.simplify;
  levunit = inputunit;
  levunit.simplify;
  
  
  % variance
  plvar = plist('xvals', as.data.x, 'yvals', expvar, 'type', 'fsdata');
  ovar = ao(plvar);
  
  ovar.setFs(as.data.fs);
  ovar.setT0(as.data.t0);
  ovar.data.setEnbw(as.data.enbw);
  ovar.data.setNavs(as.data.navs);
  ovar.setXunits(as.data.xunits);
  ovar.setYunits(varunit);
  % Set output AO name
  ovar.name = sprintf('var(%s)', ao_invars{:});
  
  % lower confidence level
  pllwb = plist('xvals', as.data.x, 'yvals', lwb, 'type', 'fsdata');
  olwb = ao(pllwb);

  olwb.setFs(as.data.fs);
  olwb.setT0(as.data.t0);
  olwb.data.setEnbw(as.data.enbw);
  olwb.data.setNavs(as.data.navs);
  olwb.setXunits(copy(as.data.xunits,1));
  olwb.setYunits(levunit);
  % Set output AO name
  clev = [num2str(conf*100) '%'];
  olwb.name = sprintf('%s_low_conf_level(%s)', clev, ao_invars{:});
  
  % upper confidence level
  plupb = plist('xvals', as.data.x, 'yvals', upb, 'type', 'fsdata');
  oupb = ao(plupb);

  oupb.setFs(as.data.fs);
  oupb.setT0(as.data.t0);
  oupb.data.setEnbw(as.data.enbw);
  oupb.data.setNavs(as.data.navs);
  oupb.setXunits(copy(as.data.xunits,1));
  oupb.setYunits(levunit);
  % Set output AO name
  oupb.name = sprintf('%s_up_conf_level(%s)', clev, ao_invars{:});
  
  
  outobj = collection(olwb,oupb,ovar);
  outobj.setName(sprintf('%s conf levels for %s', clev, ao_invars{:}));
  outobj.addHistory(getInfo('None'), pl, [ao_invars(:)], [as.hist]);
  
  varargout{1} = outobj;
    
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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

 
  pl = copy(ao.getInfo('getdof', 'Default').plists);
  
  % Conf
  p = param({'Conf', ['Required percentage confidence level.<br>' ...
    'It is a number between 0 and 100.']}, ...
    {1, {95}, paramValue.OPTIONAL});
  pl.pset(p);
  
  % DOF
  p = param({'dof', ['Degrees of freedom of the estimator. If it is<br>'...
    'left empty they are calculated.']}, paramValue.EMPTY_DOUBLE);
  pl.pset(p);
end
% END

