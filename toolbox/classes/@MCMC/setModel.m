% setModel Set the model of the investigation.
%
% CALL: algorithm.setModel(myModel);
%
function varargout = setModel(algo, varargin)
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Check if this is a call for parameters
  argsIn = [{algo}, varargin];
  if utils.helper.isinfocall(argsIn{:})
    varargout{1} = getInfo(argsIn{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % collect plists
  [plIn, ~, rest] =  utils.helper.collect_objects(varargin(:), 'plist');
  
  % Apply defaults
  pl = applyDefaults(getDefaultPlist(), plIn);
  
  try
    mdl = [rest{:}];
  catch Me
    error('### Incorrect input objects. The ''setNoise'' function accepts a matrix of ''AO'', or ''SMODEL'', or ''MATRIX'', either ''MFH'' objects and a plist. [Error:%s]', Me.message)
  end
 
  % Decide on a deep copy or a modify
  algo = copy(algo, nargout);
  
  % Check if we have to reshape the noise data
  if ~isempty(pl.find('shape'))
    mdl = reshape(mdl, pl.find('shape'));
  end
  % Set the shape of the noise to the history PLIST
  pl.pset('shape', size(mdl));
    
  algo.model = copy(mdl, 1);
  
  algo.addHistory(getInfo('None'), pl, {inputname(1)}, [algo.hist mdl.hist]);

  varargout = utils.helper.setoutputs(nargout, algo);
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
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------

function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl_default = buildplist()
  pl_default = plist();
  
  p = param({'shape', 'shape of the model (applies to MFH, SMODEL). For the case of multiple experiments and/or multiple channels.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
end

% END