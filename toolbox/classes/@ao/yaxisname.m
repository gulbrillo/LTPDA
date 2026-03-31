% YAXISNAME Get the y axis name of the underlying data object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the y axis name of the underlying data object.
%
% CALL:        val = yaxisname(a1,a2,a3,...)
%              val = yaxisname(as)
%              val = as.yaxisname()
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%
% OUTPUTS:     val  - cell-array of strings, one for each input object. For
%                     a single output, a string is returned.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'yaxisname')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = yaxisname(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  property = 'yaxis.name';

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
  out = {};
  for jj = 1:numel(as)
    if isprop_core(as(jj).data, 'yaxis')
      out{jj} = as(jj).data.yaxisname;
    else
      utils.helper.msg(msg.IMPORTANT, 'The %dth object has no %s property. Setting result to empty string', jj, property);
      out{jj} = '';
    end
  end
  
  % Set output
  if nargout == numel(as)
    % List of outputs
    varargout = out;
  else
    if numel(out) == 1
      varargout{1} = out{1};
    else
      % Single output
      varargout{1} = out;
    end
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

