% SETSHOWSERRORS sets the 'showErrors' property of a the object's plotinfo.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETSHOWSERRORS sets the 'showErrors' property of a the
%              object's plotinfo.
%
% If the object currently has no plotinfo object defined, a default one is
% created.
%
%
% CALL:            objs.setShowsErrors(flag);
%            out = objs.setShowsErrors(flag);
%
% INPUTS:
%                  objs - Any shape of ltpda_uoh objects
%                  flag - true or false
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'setShowsErrors')">Parameter Sets</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setShowsErrors(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Process inputs
  [objs, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ltpda_uoh', in_names);
  [pl,   pl_invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  if numel(pl) == 0 && numel(rest) == 0
    error('Specify true or false for the value.');
  end
  
  % Apply defaults.
  pl = applyDefaults(getDefaultPlist, pl);
  
  if ~isempty(rest) && (islogical(rest{1}) || isnumeric(rest{1}))
    val = rest{1};
    pl.pset('state', val);
  else
    val = pl.find_core('state');
  end
  
  if isempty(val)
    error('Specify true or false for the value.');
  end
  
  % decide on a deep copy
  bs = copy(objs, nargout);
  
  for kk=1:numel(bs)
    
    obj = bs(kk);
    
    if isempty(obj.plotinfo)
      obj.plotinfo = plotinfo();
    end
    
    obj.plotinfo.showErrors = logical(val);
    
    % add history
    obj.addHistory(getInfo('None'), pl, ao_invars(kk), objs(kk).hist);
  end
  
  % set outputs
  varargout = utils.helper.setoutputs(nargout, bs);
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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
  pl = plist({'state', 'A state to set the showErrors flag.'}, paramValue.TRUE_FALSE);
end
