% ASSIGNALIAS assign values to smodel alias
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ASSIGNALIAS assign numerical values or vectors to smodel
% aliases. This is a processing method which should be run before using the
% given smodel inside smodel/fftfilt so to gain evaluation time during the
% evaluation of the model. Be careful to insert the correct values for the
% parameters otherwhise smodel/double will throw an error.
%
% CALL:        mdl = assignalias(mdl)
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'assignalias')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = assignalias(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin
    in_names{ii} = inputname(ii);
  end
  
  % Collect all smodels and plists
  [as, smodel_invars, rest] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  pl        = utils.helper.collect_objects(varargin(:), 'plist');
  
  
  % Copy the object(s), so to inherit parameters etc
  mdls = copy(as, nargout);
  
  % combine plists
  if isempty(pl)
    setvar = 'fftfilt';
  else
    xvals = find_core(pl, 'xvals');
    if isempty(xvals)
      setvar = 'fftfilt';
    else
      setvar = 'UserDefinedXvals';
    end
  end
  
  pl = applyDefaults(getDefaultPlist(setvar), pl);
  
  % get parameters values from plist
  switch lower(setvar)
    case 'fftfilt'
      nsecs = find_core(pl, 'nsecs');
      npad  = find_core(pl, 'npad');
      fs    = find_core(pl, 'fs');
      % get fft frequancies
      nfft = nsecs*fs + npad;
      xvals = utils.math.getfftfreq(nfft,fs,'one');
      xvals = xvals.';
    case 'userdefinedxvals'
      xvals = find_core(pl, 'xvals');
  end
  
  % run over input objects
  for ii=1:numel(mdls)
    % Recover the mapping factor from xvals and xvar
    % get xvar
    xxvar = mdls(ii).xvar;
    % check dimensions
    if numel(xxvar)>1
      error('Multiple xvar are not supported!')
    else
      xxvar = xxvar{:};
    end
    trans = mdls(ii).trans;
    if isempty(trans)
      scale = 1.0;
    else
      if isnumeric(trans)
        scale = trans;
      elseif ischar(trans)
        scale = eval(trans);
      elseif iscell(trans)
        % check dimension
        if numel(trans)>1
          error('Multiple trans are not supported!')
        else
          switch lower(class(trans{:}))
            case 'double'
              scale = trans{:};
            case 'char'
              scale = eval(trans{:});
          end
        end
      else
        error('Unknown format for the transformation!');
      end
    end
    % assign values for the x
    getSingleVariable(xxvar,scale.*xvals);
    % assign alias values
    for jj=1:numel(mdls(ii).aliasNames)
      switch class(mdls(ii).aliasValues{jj})
        case 'char'
          getSingleVariable('calias',eval(mdls(ii).aliasValues{jj}));
          mdls(ii).aliasValues{jj} = calias;
        case 'smodel'
          tmd = mdls(ii).aliasValues{jj};
          tmd.setXvals(xvals);
          getSingleVariable('calias',tmd.double);
          mdls(ii).aliasValues{jj} = calias;
        otherwise
          % do nothing
      end
    end
    mdls(ii).setXvals(xvals);
    % set output history
    mdls(ii).addHistory(getInfo('None'), pl, smodel_invars(ii), mdls(ii).hist);
  end
  
  %%% Set output
  if nargout == numel(mdls)
    % List of outputs
    for ii = 1:numel(mdls)
      varargout{ii} = mdls(ii);
    end
  else
    % Single output
    varargout{1} = mdls;
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% FUNCTION: getCellVariables
% 
% DESCRIPTION: Assign values to variables
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function getSingleVariable(nms,val)
    assignin('caller',nms,val);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
end


%--------------------------------------------------------------------------
% Defintion of Sets
%--------------------------------------------------------------------------

function out = SETS()
  out = {...
    'fftfilt', ...
    'UserDefinedXvals'    ...
    };
end


%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(set)
  persistent pl;  
  persistent lastset;
  if exist('pl', 'var')==0 || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;  
end

function pl = buildplist(set)
  pl = copy(plist.EMPTY_PLIST,1);
  
  switch lower(set)
    case 'fftfilt'
      p = param({'nsecs', 'Number of seconds of the time series will be filtered with fftfilt.'}, paramValue.DOUBLE_VALUE(1));
      pl.append(p);
      
      p = param({'npad', 'Number of sample pad will will be used in fftfilt.'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      p = param({'fs', 'Sampling frequency of the time series will be filtered with fftfilt.'}, paramValue.DOUBLE_VALUE(1));
      pl.append(p);
      

      
    case 'userdefinedxvals'
      
      p = param({'xvals', 'A vector of values for the X variable.'...
        'If the smodel implement a transformation for x values then you should'... 
        'input the value before the transformation. E.g. xvar = s -> trans = 2*pi*i'...
        'you should input f values so you finally get inside the code xvals = 2*pi*i*f'}, paramValue.EMPTY_DOUBLE);
      pl.append(p);
      
      
  end
end
