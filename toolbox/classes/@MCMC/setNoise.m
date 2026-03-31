% setNoise Set the measured noise of the experiment.
%
% CALL: algorithm.setNoise(myNoise);
%
function varargout = setNoise(algo, varargin)
  
  % Check if this is a call for parameters
  argsIn = [{algo}, varargin];
  if utils.helper.isinfocall(argsIn{:})
    varargout{1} = getInfo(argsIn{3});
    return
  end
  
  [plIn, ~, rest] =  utils.helper.collect_objects(varargin(:), 'plist');
  
  try
    data = [rest{:}];
  catch Me
    error('### Incorrect input objects. The ''setNoise'' function accepts a matrix of ''AO'', or ''SMODEL'', or ''MATRIX'', either ''MFH'' objects and a plist. [Error:%s]', Me.message)
  end
  
  % Apply defaults
  pl = applyDefaults(getDefaultPlist(), plIn);
  
  % Check if we have to reshape the noise data
  if ~isempty(pl.find('shape'))
    data = reshape(data, pl.find('shape'));
  end
  % Set the shape of the noise to the history PLIST
  pl.pset('shape', size(data));
  
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  algo = copy(algo, nargout);
  
  if ~isempty(data)
    
    if isa(data, 'matrix')
      % Get number of experiments
      Nexp = numel(data);
      
      % Get number of channels
      Nout = numel(data(1).objs);
      
      % set inputs
      algo.noise = ao.initObjectWithSize(Nout, Nexp);
      
      for ii = 1:Nexp
        for jj = 1:Nout
          algo.noise(jj,ii) = copy(data(ii).objs(jj), 1);
        end
      end
    elseif isa(data, 'ao')
      algo.noise = copy(data, 1);
    elseif isa(data, 'mfh')
      algo.noise = copy(data, 1);
    elseif isa(data, 'smodel')
      algo.noise = copy(data, 1);
    else
      error('The MCMC noise data should be either MATRIX, AO, SMODEL or MFH objects');
    end
    
    % Add History step
    algo.addHistory(getInfo('None'), pl, {inputname(1)}, [algo.hist data.hist]);
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
  
%   p = param({'NOISE', 'blah'}, paramValue.EMPTY_DOUBLE);
%   pl.append(p);
  
  p = param({'shape', 'shape of the noise data (applies to AOs, MFH objects and the contents of MATRIX objects). For the case of multiple experiments and/or multiple channels.'}, paramValue.EMPTY_DOUBLE);
  pl_default.append(p);
  
end

% END