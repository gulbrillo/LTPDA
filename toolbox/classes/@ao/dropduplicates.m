% DROPDUPLICATES drops all duplicate samples in time-series AOs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DROPDUPLICATES drops all duplicate samples in time-series AOs. Duplicates
%                are identified by having a two consecutive time stamps
%                closer than a set tolerance.
%
% CALL:        bs = dropduplicates(as)
%
% INPUTS:      as  - array of analysis objects
%              pl  - parameter list (see below)
%
% OUTPUTS:     bs  - array of analysis objects, one for each input
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'dropduplicates')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = dropduplicates(varargin)

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

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  % Get tolerance
  tol = find_core(pl, 'tol');

  % Get only tsdata AOs
  for jj = 1:numel(bs)
    if isa(bs(jj).data, 'tsdata')
      d = abs(diff(bs(jj).data.getX));
      idx = find(d<tol);
      utils.helper.msg(msg.PROC1, 'found %d duplicate samples', numel(idx));
      % Get values
      x  = bs(jj).data.getX();
      y  = bs(jj).data.getY();
      dx = bs(jj).data.getDx();
      dy = bs(jj).data.getDy();
      bs(jj).clearErrors();
      % Wipe out x samples
      bs(jj).data.setX(removeSamples(x, idx));
      % Wipe out y samples
      bs(jj).data.setY(removeSamples(y, idx));
      % Wipe out error
      if numel(dx) > 1
        bs(jj).data.setDx(removeSamples(dx, idx));
      end
      if numel(dy) > 1
        bs(jj).data.setDy(removeSamples(dy, idx));
      end
      if ~callerIsMethod
        % set name
        bs(jj).name = sprintf('dropduplicates(%s)', ao_invars{jj});
        % Add history
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
      end
      
      bs(jj).procinfo = plist('dropped samples', idx);
      
    else
      warning('!!! Skipping AO %s - it''s not a time-series AO.', ao_invars{jj});
      bs(jj) = [];
    end
  end

  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
end

%--------------------------------------------------------------------------
% data = removeSamples(data, samples)
%--------------------------------------------------------------------------
function data = removeSamples(data, samples)
  data(samples) = [];
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
  
  % tol
  p = param({'tol','The time interval tolerance to consider two consecutive samples as duplicates.'}, ...
    {1, {5e-3}, paramValue.OPTIONAL});
  pl.append(p);
  
end


