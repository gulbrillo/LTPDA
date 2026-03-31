% YUNITS Get the data property 'yunits'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the data property 'yunits'.
%
% CALL:        val = yunits(a1,a2,a3,...)
%              val = yunits(as)
%              val = as.yunits()
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%
% OUTPUTS:     val  - array of with 'yunits', one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'yunits')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = yunits(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  property = 'yaxis.units';

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
    if isprop_core(as(jj).data, 'yaxis')
      out(jj) = as(jj).data.yunits;
    else
      utils.helper.msg(msg.IMPORTANT, 'The %dth object has no %s property. Setting result to empty unit', jj, property);
      out(jj) = unit();
    end
  end
  
  % Set output
  if nargout == numel(as)
    % List of outputs
    for ii = 1:numel(as)
      varargout{ii} = out(ii);
    end
  else
    % Single output
    varargout{1} = out;
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
    pl   = getDefaultPlist();
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

