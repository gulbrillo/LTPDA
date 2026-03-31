% AVERAGE averages aos point-by-point
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: AVERAGE averages aos point-by-point.
%              For each point, an average is taken over all the input objects.
%              The uncertainty is calculated as the standard deviation of the mean.
%              The objects must have the same length and yunits.
%
%         s1:   2 1 2 5 2 3 3
%         s2:   7 2 3 4 2 1 1
%         s3:   0 0 7 6 5 5 5
%         ===================
%         out:  3 1 4 5 3 3 3
%
% CALL:        b = average(a1, a2, a3, ..., pl)
%
% EXAMPLES:
%
% a1 = ao(plist('waveform', 'noise', 'nsecs', 1000, 'fs', 1, 'yunits', 'm'));
% a2 = ao(plist('waveform', 'noise', 'nsecs', 1000, 'fs', 1, 'yunits', 'm'));
% a3 = ao(plist('waveform', 'noise', 'nsecs', 1000, 'fs', 1, 'yunits', 'm'));
% a4 = average(a1, a2, a3);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'average')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = average(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Check if the method was called by another method
  callerIsMethod = utils.helper.callerIsMethod;
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  if nargout == 0
    error('### average cannot be used as a modifier. Please give an output variable.');
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Make a copy of the input objects history
  inhists = [as(:).hist];
  
  % Copy the input objects so we inherit all properties
  b  = copy(as(1), true);
  
  % Choose if to calculate weighted mean
  weights = find_core(pl, 'weights');
  
  % Collect the data, and check that:
  % - all objects belong to the same class
  % - all objects have the same yunits
  % - all objects have the same length
  
  Nobj = numel(as);
  data_class     = class(as(1).data);
  data_yunits    = as(1).data.yunits;
  data_matrix    = as(1).data.getY;
  
  data_length    = numel(data_matrix);
  
  switch lower(weights)
    case 'none'
      weights_matrix = ones(data_length, 1);
    case 'dy'
      if ~isempty(as(1).data.getDy) && numel(as(1).data.getDy) == 1
        weights_matrix = 1./(as(1).data.getDy) * ones(data_length, 1);
      else
        weights_matrix = 1./(as(1).data.getDy);
      end
    case {'dy2', 'dy^2'}
      if ~isempty(as(1).data.getDy) && numel(as(1).data.getDy) == 1
        weights_matrix = 1./(as(1).data.getDy).^2 * ones(data_length, 1);
      else
        weights_matrix = 1./(as(1).data.getDy).^2;
      end
    otherwise
      weights_matrix = ones(data_length, 1);
  end
  
  
  for jj = 2:Nobj
    % - all objects should belong to the same class
    if ~strcmp(class(as(jj).data), data_class)
      error('### The first ao data object is a %s, while the %dth is a %s. The data must all belong to the same class!', ...
        data_class, jj, class(as(jj).data));
    end
    
    % - all objects should have the same yunits
    if  ~isequal(as(jj).data.yunits, data_yunits)
      error('### The first ao data object has yunits = %s, while the %dth has yunits = %s. The data must all have the same yunits!', ...
        char(data_yunits), jj, char(as(jj).data.yunits));
    end
    
    % - all objects should have the same length
    try
      % The data.getY methods always give columns, so this syntax should give a proper matrix
      data_matrix = [data_matrix as(jj).data.getY];
      switch lower(weights)
        case 'none'
          weights_matrix = [weights_matrix ones(data_length, 1)];
        case 'dy'
          % Weights will be taken from objects dy field as w = 1/dy
          % Handle the situation where the uncertainty is set by single
          % value
          if ~isempty(as(1).data.getDy) && numel(as(jj).data.getDy) == 1
            weights_matrix = [weights_matrix 1./(as(jj).data.getDy) * ones(data_length, 1)];
          else
            weights_matrix = [weights_matrix 1./(as(jj).data.getDy)];
          end
        case {'dy2', 'dy^2'}
          % Weights will be taken from objects dy field as w = 1/dy^2
          % Handle the situation where the uncertainty is set by single
          % value
          if ~isempty(as(1).data.getDy) && numel(as(jj).data.getDy) == 1
            weights_matrix = [weights_matrix 1./(as(jj).data.getDy).^2 * ones(data_length, 1)];
          else
            weights_matrix = [weights_matrix 1./(as(jj).data.getDy).^2];
          end
        otherwise
          weights_matrix = [weights_matrix ones(data_length, 1)];
      end
    catch ME
      switch ME.identifier
        case 'MATLAB:catenate:dimensionMismatch'
          error('### The first ao data object has %d points, while the %dth has %d points. The data must all have the same size!', ...
            data_length, jj, numel(as(jj).data.getY));
        otherwise
          error('### Something went wrong while concatenating the data. Stopping.');
      end
      
    end
    
    if strcmp(data_class, 'fsdata')
      b.data.setNavs(b.data.navs + as(jj).data.navs);
    end

  end
  
  % Go for the actual calculation.
  if Nobj > 1
    % The data.getY methods always give columns, so we just need to operate on the second dimension
    dim = 2;
    b.data.setY(sum(data_matrix .* weights_matrix, dim) ./ sum(weights_matrix, dim));
    b.data.setDy(std(data_matrix, 0, dim) / sqrt(Nobj));
    
  else
    % Nothing to do in this case
  end
  
  if ~callerIsMethod
    % create new output history
    b.addHistory(getInfo('None'), pl, [ao_invars(:)], inhists);
    % set name
    b.name = sprintf('average(%s)', [ao_invars{:}]);
  end
  
  % Set output
  varargout{1} = b;
  
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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
  
  pl = plist();
  
  % weights
  p = param({'weights', ['Option to calculate a weighted mean. Choose a method between:<ul>', ...
    '<li>none       - no weigthing done</li>', ...
    '<li>dy2, dy^2  - weights will be taken from objects dy field as w = 1/dy^2</li>', ...
    '<li>dy         - weights will be taken from objects dy field as w = 1/dy</li></ul>']}, ...
    {1, {'NONE', 'DY2', 'DY^2','DY'}, paramValue.SINGLE});
  pl.append(p);
  
end

