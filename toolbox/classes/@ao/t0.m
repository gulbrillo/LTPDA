% T0 Get the data property 't0'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the data property 't0'.
%
% CALL:        val = t0(a1,a2,a3,...)
%              val = t0(as)
%              val = as.t0()
%
% INPUTS:      aN   - input analysis objects (tsdata or fsdata)
%              as   - input analysis objects array (tsdata or fsdata)
%
% OUTPUTS:     val  - array of with 't0', one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 't0')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = t0(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  property = 't0';
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;

  if ~callerIsMethod
    % Collect all AOs
    as = utils.helper.collect_objects(varargin(:), 'ao');
  else
    % Assume the input is a single AO or a vector of AOs
    as = varargin{1};
  end

  % Extract the property
  for jj = 1:numel(as)
    if isprop_core(as(jj).data, property)
      out(jj) = as(jj).data.(property);
    else
      utils.helper.msg(msg.IMPORTANT, 'The %dth object has no %s property. Setting result to NaN', jj, property);
      out(jj) = time(NaN);
    end
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, out);
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
  ii.setModifier(false);
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
  pl = plist.EMPTY_PLIST;
end
