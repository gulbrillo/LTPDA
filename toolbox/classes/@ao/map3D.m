% MAP3D maps the input 1 or 2D AOs on to a 3D AO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MAP3D maps the input 1 or 2D AOs on to a 3D AO.
% 
% The inputs AOs should be all either 1 or 2D. For 1D inputs, they should
% all be the same length. For 2D inputs, they should all have the same
% length.
%
% CALL:        bs = map3D(a1,a2,a3,...,pl)
%              bs = map3D(as,pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'map3D')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = map3D(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Apply defaults to plist
  usepl = applyDefaults(getDefaultPlist, varargin{:});
  
  % Check for type
  if isa(bs(1).data, 'cdata')
    nDim = 1;
    nX   = bs(1).len;
  elseif isa(bs(1).data, 'data2D')
    nDim = 2;
    nX   = length(bs(1).x);
  else
    error('map3D accepts only 1 and 2D input AOs');
  end
  
  for kk=2:numel(bs)
    if isa(bs(kk).data, 'cdata') && nDim ~= 1
      error('map3D needs either 1D or 2D inputs, but not mixed');
    elseif isa(bs(kk).data, 'data2D') && nDim ~= 2
      error('map3D needs either 1D or 2D inputs, but not mixed');
    elseif ~isa(bs(kk).data, 'cdata') && ~isa(bs(kk).data, 'data2D')
      error('map3D accepts only 1 and 2D input AOs');
    end
    
    if nDim == 1
      if bs(kk).len ~= nX
        error('All input AOs must be of the same length');
      end
    else
      if length(bs(kk).x) ~= nX
        error('All input AOs must be of the same length');
      end
    end
    
  end
  

  if nDim == 1
    
    z = bs.y;
    x = 1:bs(1).len;
    y = 1:numel(bs);
    
    xunits = 'Index';
    yunits = 'Index';
    zunits = bs(1).yunits;
    
  else
    
    z = bs.y;
    x = bs(kk).x;
    y = 1:numel(bs);
    
    xunits = bs(1).xunits;
    yunits = 'Index';
    zunits = bs(1).yunits;
    
  end
  
  % Output data
  do = xyzdata(x, y, z.');
  do.setXunits(xunits);
  do.setYunits(yunits);
  do.setZunits(zunits);
  
  a = ao();
  a.data = do;
  % name
  name = 'map3D(';
  for kk=1:numel(bs)
    name = [name sprintf('%s,', ao_invars{kk})];
  end
  name = [name(1:end-1) ')'];
  a.name = name;
      
  % Add history
  if ~callerIsMethod
    a.addHistory(getInfo('None'), usepl, ao_invars, [bs.hist]);
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, a);
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
  
  % General plist for Welch-based, linearly spaced spectral estimators
  pl = plist();
  
end

