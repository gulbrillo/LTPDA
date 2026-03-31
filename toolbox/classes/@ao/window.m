% WINDOW applies the specified window to the input time-series objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: WINDOW constructs and applies the specified window to the
%              input time-series.
%
% CALL:        bs = window(a1,a2,a3,...,pl)
%              bs = window(as,pl)
%              bs = as.window(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'window')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% callerIsMethod interface expects the last object to be a plist
% 
%     bs = window(a1, a2, ..., pl)
% 

function varargout = window(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  
  % Collect all AOs and last object as plist
  if callerIsMethod
    if isa(varargin{end}, 'plist')
      as = [varargin{1:end-1}];
      pl = varargin{end};
    else
      as = varargin{:};
      pl = [];
    end
    ao_invars = cell(size(as));
  else
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
    pl                    = utils.helper.collect_objects(rest(:), 'plist', in_names);
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Apply defaults to plist
  usepl = applyDefaults(getDefaultPlist, pl);
  
  if nargout == 0
    isModifier = true;
  else
    isModifier = false;
  end
  
  % construct specwin object
  win  = find(usepl, 'Win');
  psll = find(usepl, 'psll');
  if isempty(win)
    win = 'Rectangular';
    utils.helper.msg(msg.PROC1, 'using no window (Rectangular)');
  end
  if isempty(psll)
    psll = 0;
    utils.helper.msg(msg.PROC1, 'setting psll level to 0');
  end
  if ischar(psll)
    npsll = floor(eval(psll));
    utils.helper.msg(msg.PROC1, 'setting psll to %s = %d', psll, npsll);
    psll = npsll;
  end
  if ischar(win)
    % We always want to work with a specwin
    switch lower(win)
      case 'kaiser'
        win = specwin(win, 0, psll);
      otherwise
        win = specwin(win, 0);
    end
  end
  
  
  % loop over inputs
  for kk=1:numel(bs)
    
    % construct window
    win.len = bs(kk).len;
    winVals = win.win.'; % because we always get a column from ao.y
    utils.helper.msg(msg.PROC1, 'using window %s(%d)', win.type, win.len);
    
    % apply window
    bs(kk).setY(bs(kk).y .* winVals);
    
    % set name
    bs(kk).name = sprintf('%s(%s)', win.type, ao_invars{1});
    
    % set procinfo
    bs(kk).procinfo = plist('win', win);
    
    if ~callerIsMethod
      bs(kk).addHistory(getInfo('None'), usepl, [ao_invars(:)], [bs(kk).hist]);
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
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
  
  pl = copy(plist.WINDOW_PLIST, 1);
  
end

% END
