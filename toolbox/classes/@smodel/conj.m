% CONJ gives the complex conjugate of the input smodels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CONJ gives the complex conjugate of the input smodels
%
% CALL:        mdl = conj(mdl)
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'conj')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = conj(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs and plists
  [mdl, mdl_invars] = utils.helper.collect_objects(varargin(:), 'smodel', in_names);
  pl                = utils.helper.collect_objects(varargin(:), 'plist', in_names);

  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % decide to make a copy or not
  cmdl = copy(mdl, nargout);
  
%   [rw,cl] = size(cmdl);
  
  for jj = 1:numel(cmdl)
    cmdl(jj).expr = msym(['conj(' cmdl(jj).expr.s ')']);
    cmdl(jj).name = ['conj(' cmdl(jj).name ')'];
    cmdl(jj).params = mdl(jj).params;
    cmdl(jj).values = mdl(jj).values;
    cmdl(jj).xvar = mdl(jj).xvar;
    cmdl(jj).xvals = mdl(jj).xvals;
    cmdl(jj).xunits = mdl(jj).xunits;
    cmdl(jj).yunits = mdl(jj).yunits;
  
    % add history
    cmdl(jj).addHistory(getInfo('None'), pl, mdl_invars(jj), mdl(jj).hist);
  end

  % Set outputs
  varargout{1} = cmdl;
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.aop, '', sets, pl);
  ii.setModifier(true);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end

