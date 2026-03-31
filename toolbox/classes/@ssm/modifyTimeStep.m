% MODIFYTIMESTEP modifies the timestep of a ssm object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MODIFYTIMESTEP modifies the timestep of a ssm object, and updates
%              the A and B matrices supposing there is no aliasing.
%
% CALL: sys = modifyTimeStep(sys,pl)
%
% INPUTS:
%           sys - (array of) ssm objects
%            pl - A plist or numeric value giving new timestep value (param name 'newtimestep')
%
% OUTPUTS:
%           sys - (array of) ssm
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'modifyTimeStep')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = modifyTimeStep(varargin)
  
  %% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %% send starting message
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  %% collecting input
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  [sys, ssm_invars, rest] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  [pl, invars2, rest]  = utils.helper.collect_objects(rest(:), 'plist');
  
  %--- Decide on a deep copy or a modify.
  % If the no output arguments are specified, then we are modifying the
  % input objects. If output arguments are specified (nargout>0) then we
  % make a deep copy of the input objects and return modified versions of
  % those copies.
  sysCopy = copy(sys, nargout);
  
  % determine the set of keys we are using. Depends if control system
  % toolbox is installed
  if license('test','control_toolbox')
    set = 'control_toolbox';
  else
    set = 'internal';
  end
  
  % override with a numeric input value
  if ~isempty(rest)
    % if the user inputs a single numerical value, we use it
    if isnumeric(rest{1}) && numel(rest{1}) == 1
      if ~isa(pl, 'plist') % perhaps we dont' have a plist yet
        pl = plist();
      end
      pl.pset('newtimestep', rest{1}); % set newtimestep
    else
      pl = combine(pl, plist(rest{:}));
    end
  end
  pl = combine(pl, getDefaultPlist(set));
  
  %%% Internal call: Only one object + don't look for a plist
  internal = utils.helper.callerIsMethod();
  
  % dealing with user custom inputs
  
  Nsys     = numel(sysCopy);
  
  
  for ii = 1:Nsys
    
    sys_ii = sysCopy(ii);
    
    if ~sys_ii.isnumerical
      error(['error in modifTimeStep because system "',sys_ii.name, '" should be numerical to be modified' ]);
    end
    
    % process plist
    
    % new timestep
    newtimestep = find(pl,'newtimestep');
    if numel(newtimestep)~=1
      error('parameter "newtimestep" should be of size 1x1')
    end
    if isa(newtimestep,'ao')
      newtimestep = newtimestep.y;
    end
    
    % get old system timestep for checking method compatibility
    oldtimestep = sys_ii.timestep;
    if oldtimestep == 0 && newtimestep ~= 0
      convType = 'c2d';
    elseif oldtimestep ~= 0 && newtimestep == 0
      convType = 'd2c';
    else
      convType = 'd2d';
    end
    
    % find method
    method = lower(pl.find('method'));
    if isempty(method)
      method = 'internal';
    end
    
    switch method
      case 'internal'
        useSSmethods = false;
        outputAntiAlias = find(pl, 'outputAntiAlias');
        timeStepDivider = find(pl, 'timeStepDivider');
      case 'zoh'
        useSSmethods = true;
      case 'bilinear'
        useSSmethods = true;
      case 'matched'
        useSSmethods = true;
        if strcmpi(convType,'d2d')
          error('matched method cannot be used for resampling discrete systems');
        end
      case {'foh','impulse'}
        useSSmethods = true;
        if ~strmpi(convType,'c2d')
          error('%s method can only be used for discritizing continuous systems',method);
        end
      case 'linear'
        useSSmethods = true;
        if ~strmpi(convType,'d2c')
          error('Linear method can only be used for making continuous approximations of discrete systems');
        end
        
      otherwise
        
    end
    
    % find options
    if useSSmethods
      opts = pl.find('options');
      switch convType
        case 'd2c'
          if ~isempty(opts)
            if ~isa(opts,'ltioptions.d2c')
              error('For discritization of continuous systems, options must be of type ltioptions.d2c. See help d2cOptions on creating this options structure');
            end
          end
        case 'c2d'
          if ~isempty(opts)
            if ~isa(opts,'ltioptions.c2d')
              error('For continuous approximations of discrete systems, options must be of type ltioptions.c2d. See help c2dOptions on creating this options structure');
            end
          end
        case 'd2d'
          if ~isempty(opts)
            if ~isa(opts,'ltioptions.d2d')
              error('For resampling of discrete systems, options must be of type ltioptions.d2d. See help d2dOptions on creating this options structure');
            end
          end
        otherwise
      end
    end
    
    % do conversion using internal algorithim
    if strcmpi(method,'internal')
      sys_ii = timeStepConvert(sys_ii,newtimestep,outputAntiAlias,timeStepDivider);
      % do conversion using control toolbox SS methods
    else
      switch convType
        case 'd2c'
          sys_ii.d2c(plist(...
            'method',method,...
            'options',opts));
        case 'c2d'
          sys_ii.c2d(plist(...
            'TS',newtimestep,...
            'method',method,...
            'options',opts));
        case 'd2d'
          sys_ii.d2d(plist(...
            'TS', newtimestep,...
            'method',method,...
            'options',opts));
        otherwise
      end
    end
    
    % add history
    if ~internal
      sys_ii.addHistory(getInfo('None'), pl, ssm_invars(ii), sys_ii.hist );
    end
    
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, sysCopy);
end


% this function captures the internal conversion algorithims
function sysOut = timeStepConvert(sysIn, newtimestep, outputAntiAlias, timeStepDivider)
  
  sysOut = copy(sysIn,0);
  
  % retrieving input data
  timestep    = sysOut.timestep;
  sssizes     = sysOut.sssizes;
  inputsizes  = sysOut.inputsizes;
  
  amat       = ssm.blockMatFusion(sysOut.amats, sssizes, sssizes);
  bmat       = ssm.blockMatFusion(sysOut.bmats, sssizes, inputsizes);
  if outputAntiAlias
    outputsizes = sysOut.outputsizes;
    cmat        = ssm.blockMatFusion(sysOut.cmats, outputsizes, sssizes);
    dmat        = ssm.blockMatFusion(sysOut.dmats, outputsizes, inputsizes);
  end
  
  % take different actions depending on old and new timestep
  if timestep == newtimestep
    action = 'DoNothing';
  elseif newtimestep == 0
    action = 'MakeContinuous';
    str = 'warning because system is sent back to continuous time';
    utils.helper.msg(utils.const.msg.MNAME, str);
  elseif timestep == 0
    action = 'Discretize';
  elseif floor(newtimestep/timestep) == newtimestep/timestep
    action = 'TakeMultiple';
  elseif newtimestep > timestep
    action = 'MakeLonger';
  else
    action = 'MakeShorter';
    str = 'warning because system is sent back to shorter time step';
    utils.helper.msg(utils.const.msg.MNAME, str);
  end
  
  % proceed with matrix modifications
  
  amat_input = zeros(size(amat));
  if isequal(action,'DoNothing')
    % same timestep : do nothing
    amat_2 = amat;
    bmat_2 = bmat;
  elseif isequal(action,'Discretize')
    % from continuous to discrete
    
    if timeStepDivider
      
      % Check number of k partitions of newtimestep required
      % (Reference: FRANKLIN&POWELL, Digital control of dynamic systems, 3rd 1998, Section 4.3.5)
      nor = max(sum(abs(amat)))*newtimestep;
      k = max(ceil(log2(nor)), 0);
      
      if k~=0; % TimeStep must be reduced to avoid potential divergences in the discretisation
        % Compute phi and psi matrices with k-times shortest timestep
        shortTimeStep = newtimestep/2^k;
        phiShort = expm(amat*shortTimeStep);
        psiShort = psiIter(amat, shortTimeStep);
        
        % "Propagate" psiShort and phiShort matrices (double psi and phi k times) to obtain amat_2 and psi
        amat_2 = phiShort^(2^k);
        psi = psiShort;
        
        ii = k;
        while ii>0
          psi = (eye(size(psiShort)) + amat*(newtimestep/2^(ii+1))*psi)*psi;
          ii = ii-1;
        end
        
        % Obtain bmat_2 from psi
        bmat_2 = real(psi*newtimestep*bmat);
        
      else % TimeStep is small enough
        amat_2 = expm(amat*newtimestep);
        bmat_2 = real(psiIter(amat, newtimestep)*newtimestep*bmat);
      end
      
    else
      amat_2 = expm(amat * newtimestep);
      amat_input = ExpInt(amat, newtimestep);
      bmat_2 = real(amat_input * bmat);
    end
    
    if outputAntiAlias
      cmat_2 = cmat * 0.5*(eye(size(amat_2)) + amat_2);
      dmat_2 = dmat + cmat*0.5*bmat_2;
      sysOut.cmats = ssm.blockMatRecut(real(cmat_2), outputsizes, sssizes);
      sysOut.dmats = ssm.blockMatRecut(real(dmat_2), outputsizes, inputsizes);
    end
    
  elseif isequal(action,'MakeContinuous')
    % for discrete to continuous
    [V, E] = eig(amat);
    amat_2 = real(V * (diag(log(diag(E)))/timestep) * V^(-1));
    amat_input = ExpInt(amat_2, timestep);
    amat_input_inv = (amat_input)^(-1);
    bmat_2 = real(amat_input_inv * bmat);
    if outputAntiAlias
      cmat_2 = cmat * (0.5*(eye(size(amat)) + amat))^-1;
      dmat_2 = dmat - cmat_2*0.5*bmat;
      sysOut.cmats = ssm.blockMatRecut(real(cmat_2), outputsizes, sssizes);
      sysOut.dmats = ssm.blockMatRecut(real(dmat_2), outputsizes, inputsizes);
    end
  elseif isequal(action,'TakeMultiple')
    % discrete to discrete with a multiple
    multiple = newtimestep/timestep;
    amat_2 = amat^multiple;
    for i_step = 1:multiple
      amat_input = amat_input + amat^(i_step-1);
    end
    bmat_2 = real(amat_input * bmat);
    if outputAntiAlias
      cmat_0 = cmat * (0.5*(eye(size(amat)) + amat))^-1;
      cmat_2 = cmat_0 * 0.5*(eye(size(amat_2)) + amat_2);
      dmat_2 = dmat + cmat_0*0.5*bmat_2 - cmat_0*0.5*bmat;
      sysOut.cmats = ssm.blockMatRecut(real(cmat_2), outputsizes, sssizes);
      sysOut.dmats = ssm.blockMatRecut(real(dmat_2), outputsizes, inputsizes);
    end
  elseif isequal(action,'MakeLonger')||isequal(action,'MakeShorter')
    % discrete to discrete with no multiple relationship
    [V, E] = eig(amat);
    amat_c = real(V * (diag(log(diag(E)))/timestep) * V^(-1));
    amat_2 = expm( amat * newtimestep/timestep);
    amat_input_1 = ExpInt(amat_c, timestep);
    amat_input_2 = ExpInt(amat_c, newtimestep);
    bmat_2 = real(amat_input_2 * (amat_input_1)^(-1) * bmat);
    if outputAntiAlias
      cmat_0 = cmat * (0.5*(eye(size(amat)) + amat))^-1;
      cmat_2 = cmat_0 * 0.5*(eye(size(amat_2)) + amat_2);
      dmat_2 = dmat + cmat_0*0.5*bmat_2 - cmat_0*0.5*bmat;
      sysOut.cmats = ssm.blockMatRecut(real(cmat_2), outputsizes, sssizes);
      sysOut.dmats = ssm.blockMatRecut(real(dmat_2), outputsizes, inputsizes);
    end
  end
  amat_2 = real(amat_2);
  bmat_2 = real(bmat_2);
  % Save Matrix modifications
  sysOut.amats = ssm.blockMatRecut(amat_2, sssizes, sssizes);
  sysOut.bmats = ssm.blockMatRecut(bmat_2, sssizes, inputsizes);
  sysOut.timestep = newtimestep;
end

function A_int = ExpInt(A, t)
  niter = 35;
  A1 = A*t;
  A2 = eye(size(A))*t;
  A_int = zeros(size(A));
  for i=1:niter
    A_int = A_int + A2;
    A2 = A1*A2/(i+1);
  end
end

function psi = psiIter(A, t)
  niter = 35;
  A1 =A*t;
  A2 = eye(size(A)); %without t here!
  psi = zeros(size(A));
  for i = 1:niter
    psi = psi + A2;
    A2 = A1*A2/(i+1);
  end
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pl = getDefaultPlist(sets{1});
  else
    sets = SETS();
    % get plists
    pl(size(sets)) = plist;
    for kk = 1:numel(sets)
      pl(kk) =  getDefaultPlist(sets{kk});
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
end
%--------------------------------------------------------------------------
% Defintion of Sets
%--------------------------------------------------------------------------

function out = SETS()
  
  % Check if control system toolbox is installed
  if license('test','control_toolbox')
    % give the option of using the hard-coded version or the control-system
    % toolbox methods
    out = {...
      'internal',...
      'control_toolbox'};
  else
    out = {'internal'};
  end
end


%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(varargin)
  persistent pl;
  persistent lastset;
  
  if nargin == 1, set = varargin{1}; else set = 'internal'; end
  
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  pl = plist();
  
  p = param({'newtimestep', 'Specify the desired new timestep.'}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  switch lower(set)
    case 'internal'
      p = param({'outputAntiAlias', 'Uses a linear averaging method to compute the systems output.'}, paramValue.TRUE_FALSE);
      pl.append(p);
      
      p = param({'timeStepDivider', 'Flag to avoid D matrix divergences by reducing the timeStep during the exponential matrix series computation.'}, paramValue.FALSE_TRUE);
      pl.append(p);
      
    case 'control_toolbox'
      
      % Method
      p = param(...
        {'Method',['Conversion method for discrete-to-continuous.<ul>'...
        '<li>Internal - Use algorithims internal to ssm/modifyTimeStep</li>'...
        '<li>Methods appropriate for discritization of continuous systems (inherited from ssm/c2d)'...
        '<ul>'...
        '<li>ZOH - Zero-order hold on the inputs</li>'...
        '<li>FOH - First-order hold of the inputs</li>'...
        '<li>Impulse - Impulse invariant discretization.</li>'...
        '<li>Bilinear - Bilinear approximation (Tustin method)</li>'...
        '<li>matched - matched pole-zero method (for SISO systems only)</li>'...
        '</ul>'...
        '</li>'...
        '<li>Methods appropriate for making continuous approximation of discrete systems (inherited from ssm/d2c)'...
        '<ul>'...
        '<li>ZOH - Zero-order hold on the inputs</li>'...
        '<li>Linear - Linear interpolation of the inputs</li>'...
        '<li>Bilinear - Bilinear approximation (Tustin method)</li>'...
        '<li>matched - matched pole-zero method (for SISO systems only)</li>'...
        '</ul>'...
        '</li>'...
        '<li>Methods appropriate for resampling discrete systems (inherited from ssm/d2d)'...
        '<ul>'...
        '<li>ZOH - Zero-order hold on the inputs</li>'...
        '<li>Bilinear - Bilinear approximation (Tustin method)</li>'...
        '</ul>'...
        '</li>'...
        '</ul>']},...
        {1, {'Internal','ZOH','Bilinear','matched','FOH','Impulse','Linear'}, paramValue.SINGLE});
      pl.append(p);
      
      
      % Options
      p = param(...
        {'Options',['Fine-control options to be passed to the appropriate ss method.<ul>'...
        '<li> Discrete to continuous: must be of type ltioptions.d2c, can be created with d2cOptions</li>'...
        '<li> Continuous to discrete: must be of type ltioptions.c2d, can be created with c2dOptions</li>'...
        '<li> Discrete to discrete (resampling): must be of type ltioptions.d2d, can be created with d2dOptions</li></ul>'...
        ]},...
        []);
      pl.append(p);
      
      p = param({'outputAntiAlias', 'Uses a linear averaging method to compute the systems output. Used for Internal method only'}, paramValue.TRUE_FALSE);
      pl.append(p);
      
      p = param({'timeStepDivider', 'Flag to avoid D matrix divergences by reducing the timeStep during the exponential matrix series computation. Used for internal method only'}, paramValue.FALSE_TRUE);
      pl.append(p);
      
      
    otherwise
      error('Unsuported set [%s]',set);
  end
  
  
end
