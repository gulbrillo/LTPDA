% LEN overloads the length operator for Analysis objects. Length of the data samples.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LEN overloads the length operator for Analysis objects.
%              Number of data samples in the analysis objects.
%              LEN(ao) is the length of the elements of ao_in.data.
%
% CALL:        l = len(ao_in);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'len')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = len(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;

  if ~callerIsMethod
    % Collect input variable names
    in_names = cell(size(varargin));
    try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
    
    % Collect all AOs and plists
    [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  else
    % Assume the input is a single AO or a vector of AOs
    as = varargin{1};
  end

  % go through analysis objects
  out = zeros(size(as));
  for jj = 1:numel(as)
    out(jj) = numel(as(jj).data.getY);
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
