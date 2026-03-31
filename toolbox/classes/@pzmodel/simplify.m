% SIMPLIFY simplifies pzmodels by cancelling like poles with like zeros.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SIMPLIFY simplifies pzmodels by cancelling like poles with
%              like zeros.
%
% CALL:        pzm = simplify(pzm);
%
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'simplify')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = simplify(varargin)
  
  import utils.const.*
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  %%% Input objects checks
  if nargin < 1
    error('### incorrect number of inputs.')
  end
  
  % Collect input pzmodels, plists and input variable names
  in_names = cell(size(varargin));
  for ii = 1:nargin
    in_names{end+1} = inputname(ii);
  end
  [pzms, invars, rest] = utils.helper.collect_objects(varargin(:), 'pzmodel', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist');
  
  % Combine with default plist
  pl = applyDefaults(getDefaultPlist('Default'), pl);
  
  % Get tolerance
  tol = find_core(pl,'tol');
  
  % Decide on a deep copy or a modify
  cpzms = copy(pzms, nargout);
  
  % Loop over pzmodels and modify the first
  for pp=1:numel(cpzms)
    
    % process this pzmodel
    pzm = cpzms(pp);
    
    % Loop over the poles and zeros
    cancelPoles = [];
    for jj=1:numel(pzm.poles)
      cancel = false;
      for kk=1:numel(pzm.zeros)
        if (abs(real(pzm.poles(jj).ri(1))-real(pzm.zeros(kk).ri(1)))<tol...
            && abs(imag(pzm.poles(jj).ri(1))-imag(pzm.zeros(kk).ri(1)))<tol)
          utils.helper.msg(msg.PROC1, ...
            'cancelling pole %s and zero %s', ...
            char(pzm.poles(jj)), char(pzm.zeros(kk)));
          cancel = true;
          break;
        end
      end
      if cancel
        cancelPoles = [cancelPoles jj];
        pzm.zeros(kk) = [];
      end
    end
    pzm.poles(cancelPoles) = [];
    
    % Add history
    pzm.addHistory(getInfo('None'), pl, invars, pzm.hist);
    % Set name
    pzm.setName(sprintf('simplify(%s)', pzm.name));
  end
  
  % Outputs
  varargout{1} = cpzms;
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls   = [];
  elseif nargin == 1&& ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pls = getDefaultPlist(sets{1});
  else
    sets = {'Default'};
    pls = [];
    for kk=1:numel(sets)
      pls = [pls getDefaultPlist(sets{kk})];
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  
  pl = plist();
  
  switch lower(set)
    case 'default'
      p = param({'tol', 'The tolerance for deciding if two poles/zeros are the same.'}, paramValue.DOUBLE_VALUE(1e-10));
      pl.append(p);
      
    otherwise
      error('### Unknown set [%s]', set);
  end
end

