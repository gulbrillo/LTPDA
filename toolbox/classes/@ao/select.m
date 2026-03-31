% SELECT select particular samples from the input AOs and return new AOs with only those samples.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SELECT select particular samples from the input AOs and return
%              new AOs with only those samples.
%
% CALL:        b = select(a, [1 2 3 4]);
%              b = select(a, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'select')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = select(varargin)
  
  callerIsMethod = utils.helper.callerIsMethod;
  
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
  
  % Collect all AOs and plists
  [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Check for samples in arguments
  samples_in  = [];
  for jj = 1:numel(rest)
    if isnumeric(rest{jj})
      samples_in = [samples_in reshape(rest{jj}, 1, [])];
    end
  end
  
  % Get sample selection from plist
  sam = find_core(pl, 'samples');
  axis = find_core(pl, 'axis');
  switch class(sam)
    case {'double', 'integer'}
      samples = [samples_in reshape(find_core(pl, 'samples'), 1, [])];
    case 'logical'
      samples = [samples_in find(sam)];
    case 'ao'
      if isa(sam.data, 'tsdata')
        if axis == 'y'
          if islogical(sam.data.y)
            samples = [samples_in find(sam.y)];
          else
            samples = [samples_in sam.y];
          end
        else
          samples = [samples_in 1:len(sam)];
        end
      elseif isa(sam.data, 'xydata') || isa(sam.data, 'fsdata')
        if axis == 'y'
          if islogical(sam.data.y)
            samples = [samples_in find(sam.y)];
          else
            samples = [samples_in reshape(sam.y, 1, [])];
          end
        else
          samples = [samples_in reshape(sam.x, 1, [])];
        end
      elseif isa(sam.data, 'cdata')
        if axis == 'y'
          if islogical(sam.data.y)
            samples = [samples_in find(sam.y)];
          else
            samples = [samples_in sam.y];
          end
        else
          samples = [samples_in 1:len(sam)];
        end
      end
  end
  samples = sort(samples);
  % Set the samples again to the plist because it is possible that the user
  % specified the not in the plist but direct as input.
  if ~isempty(samples_in)
    pl.pset('samples', samples);
  end
  
  % Loop over input AOs
  for jj = 1:numel(bs)
    if isa(bs(jj).data, 'cdata')
      % Memorise the error because setting the new value will remove the
      % error because the data size will not match to the error size.
      dy = bs(jj).data.dy;
      if numel(dy) > 1, bs(jj).data.setDy([]); end
      
      bs(jj).data.setY(bs(jj).data.y(samples));
      if numel(dy) > 1
        bs(jj).data.setDy(dy(samples));
      end
    else
      % Memorise the error because setting the new value will remove the
      % error because the data size will not match to the error size.
      dy = bs(jj).data.dy;
      dx = bs(jj).data.dx;
      if numel(dy) > 1, bs(jj).data.setDy([]); end
      if numel(dx) > 1, bs(jj).data.setDx([]); end
      
      % Get x
      x = bs(jj).data.getX;
      % set new samples
      bs(jj).data.setXY(x(samples), bs(jj).data.y(samples));
      % Set new error
      if numel(dx) > 1
        bs(jj).data.setDx(dx(samples));
      end
      if numel(dy) > 1
        bs(jj).data.setDy(dy(samples));
      end
      % only necessary for fsdata objects
      if isprop(bs(jj).data, 'enbw')
        if numel(bs(jj).data.enbw) > 1
          bs(jj).data.setEnbw(bs(jj).data.enbw(samples));
        end
      end
      % if this is tsdata, we may need to do some other steps
      if isa(bs(jj).data, 'tsdata')
        bs(jj).data.collapseX;
      end
    end
    
    if ~callerIsMethod
      % Set AO name
      bs(jj).name = sprintf('select(%s)', ao_invars{jj});
      % Add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
    end
    
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
  
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
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
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

function plo = buildplist()
  plo = plist();
  
  p = param({'samples', ['A list of samples to select. Supported containers are:<ul>' ...
    '<li>a list of indexes</li>' ...
    '<li>a vector of logicals, with correct length</li>' ...
    '<li>an analysis object, with content as above</li></ul>']}, paramValue.EMPTY_DOUBLE);
  plo.append(p);
  
  p = param({'axis', 'If the samples are specified with an AO then it is possible to choose the axis from which you want to select the samples.'}, {1 {'x', 'y'} paramValue.SINGLE});
  plo.append(p);
  
end

% END
% PARAMETERS: 'samples'  - a list of samples to select
%
