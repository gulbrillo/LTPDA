% DOUBLE overloads double() function for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DOUBLE overloads double() function for analysis objects.
%
% CALL:        y = double(ao_in);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'double')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = double(varargin)

  % Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % the most common case: 1 input ao or vector of aos, which means we know
  % we are getting AOs, and don't need to do expensive checks.
  if nargin == 1
    as = varargin{1};
    out = double([]);
    for kk = 1:numel(as)
      out = [out double(as(kk).data.getY)];
    end
    varargout{1} = out;
    return;
  end

  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if ~callerIsMethod
    import utils.const.*
    utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
    
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all AOs and plists
    as = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  else 
    % Assume the input is a single AO or a vector of AOs
    as = varargin{1};
  end
  
  out = double([]);
  for kk = 1:numel(as)
    out = [out double(as(kk).data.getY)];
  end
  
  varargout{1} = out;
  
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
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.converter, '', sets, pl);
  ii.setModifier(false);
  ii.setOutmin(0);
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

function pl_default = buildplist()
  pl_default = plist.EMPTY_PLIST;
end

