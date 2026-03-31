% GETDOF Calculates degrees of freedom for psd, lpsd, cohere and lcohere
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETDOF Input psd or mscohere (magnitude square coherence)
% estimated with the WOSA (Welch's Overlapped Segment Averaging Method) and
% return degrees of freedom of the estimator.
%
% CALL:         dof = getdof(a,pl)
%
% INPUTS:
%               a  -  input analysis objects containing power spectral
%                     densities or magnitude squared coherence.
%               pl  - input parameter list
%
% OUTPUTS:
%               dof - cdata AO with degrees of freedom for the
%                     corresponding estimator. If the estimators are lpsd
%                     or lcohere then dof number of elements is the same of
%                     the spectral estimator
%
%
%              If the last input argument is a parameter list (plist).
%              The following parameters are recognised.
%
% 
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'getdof')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getdof(varargin)
  
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
  if numel(as) > 1
    error('!!! Too many input AOs, GETDOF can process only one AO per time !!!')
  end
  
  %%% check that fsdata is input
  if ~isa(as.data, 'fsdata')
    error('!!! Non-fsdata input, GETDOF can process only fsdata !!!')
  end
  
  %%% avoid input modification
  if nargout == 0
    error('!!! GETDOF cannot be used as a modifier. Please give an output variable !!!');
  end
  
  %%% Parse plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  %%% Find parameters
  mtd  = lower(find_core(pl, 'method'));
  if ~ischar(mtd)
    error('!!! Method must be a string !!!')
  end
  mtd  = lower(mtd);
  
  Ntot = find_core(pl,'DataLength');
  
  %%% switching over methods
  switch mtd
    case 'psd'
      % get hist
      hst = as.hist;
      % get nodes
      [n,a, nodes] = getNodes(hst);
      % get plists from nodes
      pls = [nodes(:).histPl];
      if numel(pls) > 1
        plss = pls(1);
        for ii = 2:numel(pls)-1
          plss = parse(plss, pls(ii));
        end
      end
      % get number of averages
      navs = as.data.navs;
      % number of bins in each fft
      nfft = find_core(plss, 'NFFT');
      % get window object
      w = find_core(plss, 'WIN');
      psll = find_core(plss, 'psll');
      if ischar(w)
        switch lower(w)
          case 'kaiser'
            Win = specwin(w, nfft, psll);
          otherwise
            Win = specwin(w, nfft);
        end
      else
        Win = w;
      end
      % get window overlap
      olap = find_core(plss, 'OLAP');
      if olap>1
        olap = olap/100;
      end
      
      % Calculates total number of data in the original time-series
      if isempty(Ntot)
        Ntot = ceil(navs*(nfft-olap*nfft)+olap*nfft);
      end
      
      if navs == 1
        dofs = round(2*navs);
      else
        R = utils.math.overlapCorr(Win.type,Ntot,navs,olap);
        dof = 2*navs/(R*navs+1);
        dofs = round(dof);
      end
      
    case 'lpsd'
      % get hist
      hst = as.hist;
      % get nodes
      [n,a, nodes] = getNodes(hst);
      % get plists from nodes
      pls = [nodes(:).histPl];
      if numel(pls) > 1
        plss = pls(1);
        for ii = 2:numel(pls)-1
          plss = parse(plss, pls(ii));
        end
      end
      % get window object
      w = find_core(plss, 'WIN');
      psll = find_core(plss, 'psll');
      % get window overlap
      olap = find_core(plss, 'OLAP');
      if olap>1
        olap = olap/100;
      end

      % extract number of frequencies bins
      nf = length(as.x);
      
      % dft length for each bin
      if ~isempty(as.procinfo)
        L = as.procinfo.find_core('L');
      else
        error('### The AO doesn''t have any procinfo with the key ''L''');
      end
      
      % set original data length as the length of the first window
      if isempty(Ntot)
        nx = L(1);
      else
        nx = Ntot;
      end
            
      dofs = ones(nf,1);
      for jj = 1:nf
        l = L(jj);
        % compute window
        if ischar(w)
          switch lower(w)
            case 'kaiser'
              Win = specwin(w, l, psll);
            otherwise
              Win = specwin(w, l);
          end
        else
          Win = w;
        end
        
        % Compute the number of averages we want here
        segLen = l;
        nData  = nx;
        ovfact = 1 / (1 - olap);
        davg   = (((nData - segLen)) * ovfact) / segLen + 1;
        navg   = round(davg);

        if navg == 1
          dof = 2*navg;
        else
          R = utils.math.overlapCorr(Win.type,nx,navg,olap);
          dof = 2*navg/(R*navg+1);
        end
        
        % storing c and dof
        dofs(jj) = dof;
        
      end % for jj=1:nf
      
    case 'mscohere'
      % get hist
      hst = as.hist;
      % get nodes
      [n,a, nodes] = getNodes(hst);
      % get plists from nodes
      pls = [nodes(:).histPl];
      if numel(pls) > 1
        plss = pls(1);
        for ii = 2:numel(pls)-1
          plss = parse(plss, pls(ii));
        end
      end
      % get number of averages
      navs = as.data.navs;
      % number of bins in each fft
      nfft = find_core(plss, 'NFFT');
      % get window object
      w = find_core(plss, 'WIN');
      psll = find_core(plss, 'psll');
      if ischar(w)
        switch lower(w)
          case 'kaiser'
            Win = specwin(w, nfft, psll);
          otherwise
            Win = specwin(w, nfft);
        end
      else
        Win = w;
      end
      
      % get window overlap
      olap = find_core(plss, 'OLAP');
      if olap>1
        olap = olap/100;
      end
      
      % Calculates total number of data in the original time-series
      if isempty(Ntot)
        Ntot = ceil(navs*(nfft-olap*nfft)+olap*nfft);
      end
      
      if navs == 1
        dofs = round(2*navs);
      else
        R = utils.math.overlapCorr(Win.type,Ntot,navs,olap);
        dof = 2*navs/(R*navs+1);
        dofs = round(dof);
      end
      
    case 'mslcohere'
      % get hist
      hst = as.hist;
      % get nodes
      [n,a, nodes] = getNodes(hst);
      % get plists from nodes
      pls = [nodes(:).histPl];
      if numel(pls) > 1
        plss = pls(1);
        for ii = 2:numel(pls)-1
          plss = parse(plss, pls(ii));
        end
      end
      % get window object
      w = find_core(plss, 'WIN');
      psll = find_core(plss, 'psll');
      % get windows overlap
      olap = find_core(plss, 'OLAP');
      if olap>1
        olap = olap/100;
      end
      
      % extract number of frequencies bins
      nf = length(as.x);
      
      % dft length for each bin
      if ~isempty(as.procinfo)
        L = as.procinfo.find_core('L');
      else
        error('### The AO doesn''t have any procinfo with the key ''L''');
      end
      
      % set original data length as the length of the first window
      if isempty(Ntot)
        nx = L(1);
      else
        nx = Ntot;
      end
      
      dofs = ones(nf, 1);
      for jj = 1:nf
        l = L(jj);
        % compute window
        if ischar(w)
          switch lower(w)
            case 'kaiser'
              Win = specwin(w, l, psll);
            otherwise
              Win = specwin(w, l);
          end
        else
          Win = w;
        end
        
        % Compute the number of averages we want here
        segLen = l;
        nData  = nx;
        ovfact = 1 / (1 - olap);
        davg   = (((nData - segLen)) * ovfact) / segLen + 1;
        navg   = round(davg);
        
        if navg == 1
          dof = 2*navg;
        else
          R = utils.math.overlapCorr(Win.type,nx,navg,olap);
          dof = 2*navg/(R*navg+1);
        end
        
        % storing c and dof
        dofs(jj) = dof;
        
      end % for jj=1:nf
      
  end %switch mtd
  
  % Output data
  
  % dof
  ddof = cdata();
  ddof.setY(dofs);
  odof = ao(ddof);
  % Set output AO name
  odof.name = sprintf('dof(%s)', ao_invars{:});
  % Add history
  odof.addHistory(getInfo('None'), pl, [ao_invars(:)], [as.hist]);
  
  % output
  if nargout == 1
    varargout{1} = odof;
  else
    error('!!! getdof can have only one output')
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
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
  ii.setModifier(false);
  ii.setOutmin(1);
  ii.setOutmax(1);
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
  
  p = param({'method', ['Set the desired method. Supported values are<ul>'...
    '<li>''psd'' power spectrum calculated with ao/psd, whatever the scale</li>'...
    '<li>''lpsd'' power spectrum calculated with ao/lpsd, whatever the scale</li>'...
    '<li>''mscohere'' magnitude square coherence spectrum calculated with ao/cohere</li>'...
    '<li>''mslcohere'' magnitude square coherence spectrum calculated with ao/lcohere</li>']}, ...
    {1, {'psd', 'lpsd', 'mscohere', 'mslcohere'}, paramValue.OPTIONAL});
  pl.append(p);
  
  p = param({'DataLength',['Data length of the time series.'...
    'It is better to input for more stable calculation.'...
    'Leave it empty if you do not know its value.']},...
      paramValue.EMPTY_DOUBLE);
  pl.append(p);
                       
                       
end



% END


