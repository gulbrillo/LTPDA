% DY Get the data property 'dy'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Get the data property 'dy'.
%
% CALL:        val = obj.dy();
%
% INPUTS:      obj - must be a single data2D object.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'dy')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = dy(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % Collect numeric and char arguments to pass to getDy
  args = {};
  for kk = 1:nargin
    if isnumeric(varargin{kk}) || ischar(varargin{kk}) || islogical(varargin{kk})
      args = [args {varargin{kk}}];
    end
  end
  
  as = varargin{1};

  % Get property
  out = [];
  for jj = 1:numel(as)
    out = [out as(jj).data.getDy(args{:})];
  end

  % Set output
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
