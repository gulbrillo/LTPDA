%
% St the injection signals of the investigation.
%
% CALL: algorithm.setInputs(in);
%
function varargout = setInputs(algo, varargin)
  
  % Check if this is a call for parameters
  argsIn = [{algo}, varargin];
  if utils.helper.isinfocall(argsIn{:})
    varargout{1} = getInfo(argsIn{3});
    return
  end
  
  algo = copy(algo, nargout);
  
  % collect plists
  [plIn, ~, rest] =  utils.helper.collect_objects(varargin(:), 'plist');
  
  % Apply defaults
  pl = applyDefaults(getDefaultPlist(), plIn);
  
  try
    data = [rest{:}];
  catch Me
    error('### Incorrect input objects. The ''setInputs'' function accepts a matrix of ''AO'', or ''SMODEL'', or ''MATRIX''  objects and a plist. [Error:%s]', Me.message)
  end
  
  % Check if we have to reshape the noise data
  if ~isempty(pl.find('shape'))
    data = reshape(data, pl.find('shape'));
  end
  % Set the shape of the noise to the history PLIST
  pl.pset('shape', size(data));

  % Initialise 
  dataHist = [];
  
  if ~isempty(data)
    if isa(data, 'matrix')
      % Get number of experiments
      Nexp = numel(data);
      
      % Get number of channels
      Nin = numel(data(1).objs);
      
      % set inputs
      algo.inputs = ao.initObjectWithSize(Nin, Nexp);
      
      for ii = 1:Nexp
        for jj = 1:Nin
          algo.inputs(jj,ii) = copy(data(ii).objs(jj), 1);
        end
      end
      dataHist = data.hist;
    elseif isa(data, 'ao')
      algo.inputs = copy(data, 1);
      dataHist = data.hist;
    elseif isnumeric(data)
      algo.inputs = data;
      pl = pl.pset('inputs', data);
    else
      error('The MCMC inputs should be either matrix of ao objects');
    end
    
    algo.addHistory(getInfo('None'), pl, {inputname(1)}, [algo.hist dataHist]);
  
  end
  
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
  
  p = param({'inputs', 'The input data.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
  p = param({'shape', 'shape of the noise data (applies to AOs and the contents of MATRIX objects). For the case of multiple experiments and/or multiple channels.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
end

% END