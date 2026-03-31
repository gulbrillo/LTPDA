% DOUBLE - converts a matrix of objects into matrix of numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DOUBLE - converts a matrix of objects into matrix of numbers
%
% CALL:        b = double(a)
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'double')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = double(varargin)
  
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
  
  % Collect all MATRIX objects and plists
  objs = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  pl   = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  %%% Decide on a deep copy or a modify
  objs = copy(objs, nargout);
  
  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Loop over input MATRIX objects
  outVals = [];
  for jj = 1:numel(objs)
    
    inObjs = objs(jj).objs;
    try
      dataObjs = [inObjs.data];
      axisObjs = [dataObjs.yaxis];
      vals = [axisObjs.data];
      if numel(vals) == numel(objs)
        vals = reshape(vals, objs(jj).size);
      end
      outVals = [outVals, vals];
    catch
      % We come here if
      % - the inside objects are no AOs
      % - the data objects of the inside AOs are not the same
      % - the y-values of the data objects are not single values
      %
      % In this case we don't do anything.
    end
  end
  
  % Set output
  varargout{1} = outVals;
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
  pl = plist();
end

