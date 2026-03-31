% TOFFSET Get the data property 'toffset'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the data property 'toffset'.
%
% CALL:        val = toffset(a1,a2,a3,...)
%              val = toffset(as)
%              val = as.toffset()
%
% INPUTS:      aN   - input analysis objects (tsdata)
%              as   - input analysis objects array (tsdata)
%
% OUTPUTS:     val  - array of with 'toffset', one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'toffset')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = toffset(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  property = 'toffset';
  
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
  out = zeros(1, numel(as));
  for jj = 1:numel(as)
    if isprop_core(as(jj).data, property)
      out(jj) = as(jj).data.(property)/1e3;
    else
      utils.helper.msg(msg.IMPORTANT, 'The %dth object has no %s property. Setting result to NaN', jj, property);
      out(jj) = NaN;
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
