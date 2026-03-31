% SETOUNITS sets the 'ounits' property a transfer function object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SETOUNITS sets the 'ounits' property a transfer function object.
%
% CALL:        objs.setOunits(val);
%              objs.setOunits(val1, val2);
%              objs.setOunits(plist('ounits', val));
%              objs = objs.setOunits(val);
%
% INPUTS:      objs: Can be a vector, matrix, list, or a mix of them.
%              val:
%                 1. Single string e.g. 'Hz'
%                      Each transfer function object get this value.
%                 2. Single string in a cell-array e.g. {'Hz'}
%                      Each transfer function object get this value.
%                 3. cell-array with the same number of strings as in objs
%                    e.g. {'Hz', 'V', 's'} and 3 transfer function objects in objs
%                      Each transfer function object get its corresponding
%                      value from the cell-array
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_tf', 'setOunits')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setOunits(varargin)
  
  % Check if this is a call from a class method
  callerIsMethod = utils.helper.callerIsMethod;
  
  if callerIsMethod
    fb     = varargin{1};
    values = varargin(2:end);
    
  else
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
    
    % Collect all ltpda transfer objects
    [fb,  fb_invars, rest] = utils.helper.collect_objects(varargin(:), 'ltpda_tf', in_names);
    [pls, invars,    rest] = utils.helper.collect_objects(rest(:), 'plist');
    
    % Define property name
    pName = 'ounits';
    
    % Get values for the ltpda transfer objects
    [fb, values] = processSetterValues(fb, pls, rest, pName);
    
    % Combine input plists and default PLIST
    pls = applyDefaults(getDefaultPlist(), pls);
    
  end % callerIsMethod
  
  % Decide on a deep copy or a modify
  fb = copy(fb, nargout);
  
  for jj = 1:numel(fb)
    if numel(values) == 1
      fb(jj).ounits = values{1};
    else
      fb(jj).ounits = values{jj};
    end
    if ~callerIsMethod
      plh = pls.pset(pName, values{jj});
      fb(jj).addHistory(getInfo('None'), plh, fb_invars(jj), fb(jj).hist);
    end
  end
  
  % Set output
  nObjs = numel(fb);
  if nargout == nObjs;
    % List of outputs
    for ii = 1:nObjs
      varargout{ii} = fb(ii);
    end
  else
    % Single output
    varargout{1} = fb;
  end
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
  pl = plist({'ounits', 'The unit to set.'}, paramValue.EMPTY_STRING);
end
