% INTERPMISSING interpolate missing samples in a time-series.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INTERPMISSING interpolate missing samples in a time-series. Missing samples
%               are identified as being those where the time-span between one
%               sample and the next is larger than d/fs where d is a
%               tolerance value. Missing data is then placed in the gap in
%               steps of 1/fs. Obviously this is only really correct for
%               evenly sampled time-series.
%
% CALL:        bs = interpmissing(as)
%
% INPUTS:      as  - array of analysis objects
%              pl  - parameter list (see below)
%
% OUTPUTS:     bs  - array of analysis objects, one for each input
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'interpmissing')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = interpmissing(varargin)

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
  dtol = find_core(pl, 'd');

  % Get only tsdata AOs
  for jj = 1:numel(bs)
    if isa(bs(jj).data, 'tsdata')

      % capture input history
      ih = bs(jj).hist;

      % find missing samples
      t    = [];
      d    = diff(bs(jj).data.getX);
      idxs = find(d>dtol/bs(jj).data.fs);
      utils.helper.msg(msg.PROC1, 'found %d data gaps', numel(idxs));

      % create new time grid
      count = 0;
      fs    = bs(jj).data.fs;
      for k = 1:numel(idxs)
        idx = idxs(k);
        if isempty(t)
          t   = bs(jj).data.getX(1:idxs(1));
        end
        % now add samples at 1/fs until we are within 1/fs of the next sample
        gap   = bs(jj).data.getX(idx+1) - bs(jj).data.getX(idx) - 1/fs;
        tfill = [[1/fs:1/fs:gap] + bs(jj).data.getX(idx)].';
        count = count + numel(tfill);
        
        if k==numel(idxs)
          t = [t; tfill; bs(jj).data.getX(idx+1:end)];
        else
          t = [t; tfill; bs(jj).data.getX(idx+1:idxs(k+1))];
        end
      end
      utils.helper.msg(msg.PROC1, 'filled with %d samples', count);

      % now interpolate onto this new time-grid
      if ~isempty(t)
        bs(jj).interp(plist('vertices', t, 'method', find_core(pl, 'method')));
        % clear errors
        bs(jj).clearErrors;
      else
        utils.helper.msg(msg.PROC1, 'no missing samples found in %s - no action performed.', ao_invars{jj});
      end
      
      if ~callerIsMethod
        % Set name
        bs(jj).name = sprintf('interpmissing(%s)', ao_invars{jj});
        % Add history
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), ih);
      end
    else
      utils.helper.msg(msg.PROC1, 'skipping AO %s - it''s not a time-series AO.', ao_invars{jj});
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
  
  % d
  p = param({'d','The time interval tolerance for finding missing samples.'}, {1, {1.5}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Interpolation method
  pl.append(subset(ao.getInfo('interp').plists, 'method'));
  
end
