% D2D performs actions on ao objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: D2D overloads MATLAB's ss/d2d function for LTPDA SSM objects.
% The function resamples a discrete-time SSM model
%
% CALL:        out = d2d(objs, pl)
%
%
% INPUTS:      pl      - a parameter list
%              obj(s)  - input SSM object(s)
%
% OUTPUTS:     out - output SSM object(s)
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'd2d')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = d2d(varargin)
  
  % Determine if the caller is a method or a user
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Print a run-time message
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Check if control system toolbox is installed
  if ~license('test','control_toolbox')
    utils.helper.err(sprintf('%s/%s requires a license for the Control System Toolbox',mfilename('class'),mfilename))
  end
  
  % Collect input variable names for storing in the history
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all objects of class ssm
  [mods, obj_invars] = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  
  %--- Decide on a deep copy or a modify.
  % If the no output arguments are specified, then we are modifying the
  % input objects. If output arguments are specified (nargout>0) then we
  % make a deep copy of the input objects and return modified versions of
  % those copies.
  modsCopy = copy(mods, nargout);
  
  % determine the set of keys we are using
  set = 'Default';
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist(set), varargin{:});
  
  % get time step
  Ts = lower(pl.find('Ts'));
  if isa(Ts,'ao')
    Ts = Ts.y;
  end
  
  % extract method
  switch(lower(pl.find('method')))
    case 'zoh'
      ssmethod = 'zoh';
    case {'bilinear','tustin'}
      ssmethod = 'tustin';
    otherwise
      error('Unknown method parameter');
  end
  
  % see if options exist and are of the right type
  opts = pl.find('options');
  if ~isempty(opts)
    if ~isa(opts,'ltioptions.d2d')
      error('Options must be of type ltioptions.d2d, which can be created by calling d2dOptions');
    end
  end
  
  
  % loop over models
  for ii = 1:numel(modsCopy)
    
    mod = modsCopy(ii);
    
    % convert to MATLAB ss
    modss = ssm2ss(mod);
    
    % apply MATLAB d2d method
    if isempty(opts)
      modss = d2d(modss,Ts,ssmethod);
    else
      modss = d2d(modss,Ts, opts);
    end
    
    % re-package ABCD matricies into cell arrays
    isizes = mod.inputsizes();
    osizes = mod.outputsizes();
    ssizes = mod.statesizes();
    
    amats = ssm.blockMatRecut(modss.a,ssizes,ssizes);
    bmats = ssm.blockMatRecut(modss.b,ssizes,isizes);
    cmats = ssm.blockMatRecut(modss.c,osizes,ssizes);
    dmats = ssm.blockMatRecut(modss.d,osizes,isizes);
    
    % set ABCD matricies
    mod.setA(amats);
    mod.setB(bmats);
    mod.setC(cmats);
    mod.setD(dmats);
    
    % set Name
    mod.setName(sprintf('d2d[%s]',modsCopy(ii).name))
    
    % set timestep
    mod.timestep = Ts;
    
    % Add history
    if ~callerIsMethod
      mod.addHistory(getInfo('None'), pl, obj_invars(ii), mod.hist);
    end
    
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, modsCopy);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
end


%--------------------------------------------------------------------------
% Defintion of Sets
%--------------------------------------------------------------------------

function out = SETS()
  out = {...
    'Default' ...
    };
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist(varargin)
  persistent pl;
  persistent lastset;
  
  if nargin == 1, set = varargin{1}; else set = 'default'; end
  
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  
  % Create empty plsit
  pl = plist();
  
  % Options
  p = param(...
    {'Ts',['Output timestep (s)']},...
    [0.1]);
  pl.append(p);
  
  % Method
  p = param(...
    {'Method',['Conversion method for discrete-to-continuous.<ul>'...
    '<li>ZOH - Zero-order hold on the inputs</li>'...
    '<li>Bilinear - Bilinear approximation (Tustin method)</li><\ul>'...
    ]},...
    {1, {'ZOH','Bilinear'}, paramValue.SINGLE});
  pl.append(p);
  
  
  % Options
  p = param(...
    {'Options',['Fine-control options to be passed to the ss/d2d method.'...
    'Suitable options can be created with d2dOptions.']},...
    []);
  pl.append(p);
  
  % go through parameter sets
  switch lower(set)
    % Default is Constant value(s)
    case 'default'
      
      % otherwise
    otherwise
      error('Unsuported set [%s]',set);
  end
end
