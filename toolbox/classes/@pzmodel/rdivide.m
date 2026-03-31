% RDIVIDE overloads the division operator for pzmodels.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RDIVIDE overloads the division operator for pzmodels.
%
% CALL:        pzm = rdivide(pzm1, pzm2);
%              pzm = pzm1./pzm2;
%
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'rdivide')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = rdivide(varargin)

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
  args = utils.helper.collect_values(varargin);
  [pzms, invars, rest] = utils.helper.collect_objects(args, 'pzmodel', in_names);
  pl              = utils.helper.collect_objects(args, 'plist');
  
  % Combine with default plist
  pl = applyDefaults(getDefaultPlist('Default'), pl);
  
  % Decide on a deep copy or a modify
  cpzms = copy(pzms, nargout);
  
  % Loop over pzmodels and modify the first
  pzmout = cpzms(1);
  hists  = pzmout.hist;
  name   = pzmout.name;
  for pp=2:numel(cpzms)

    % process this pzmodel
    pzm = cpzms(pp);
    
    % Combine the poles and zeros
    pzmout.poles = [pzmout.poles pzm.zeros];
    pzmout.zeros = [pzmout.zeros pzm.poles];
    pzmout.gain  = pzmout.gain ./ pzm.gain;
    pzmout.delay  = pzmout.delay - pzm.delay;
    
    % Multiply the units
    if ~isempty(pzm.iunits.strs) && ~isempty(pzmout.ounits.strs)
      if ~isequal(pzmout.ounits, pzm.ounits)
        error('### Output units of model %s %s must match the output units of model %s %s', ...
          pzm.name, char(pzm.ounits), pzmout.name, char(pzmout.ounits));
      end
    end
    if ~isempty(pzm.ounits.strs)
      pzmout.ounits = pzm.iunits;
    end  
    if isempty(pzmout.iunits.strs)
      pzmout.iunits = pzm.ounits;
    end
    
    % compute the new name
    name = ['(' name './' pzm.name ')'];

    hists = [hists pzm.hist];
    
  end
  
  % set name
  pzmout.name = name;
  % Add history
  pzmout.addHistory(getInfo('None'), pl, invars, hists);

  % Outputs
  varargout{1} = pzmout;

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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.aop, '', sets, pls);
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

function plo = buildplist(set)
  switch lower(set)
    case 'default'
      plo = plist.EMPTY_PLIST;
    otherwise
      plo = plist.EMPTY_PLIST;
  end
end

