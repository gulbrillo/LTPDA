% DSMEAN performs a simple downsampling by taking the mean of every N samples.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DSMEAN performs a simple downsampling by taking the mean of
%              every N samples. The downsample factor (N) is taken as
%              round(fs/fsout). The original vector is then truncated to a
%              integer number of segments of length N. It is then reshaped
%              to N x length(y)/N. Then the mean is taken.
%
% CALL:        b = dsmean(a, pl)
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'dsmean')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = dsmean(varargin)

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
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);

  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);

  % Extract necessary parameters
  fsout  = find_core(pl, 'fsout');
  offset = find_core(pl, 'offset');
  
  % Loop over input AOs
  for jj = 1:numel(bs)
    if ~isa(bs(jj).data, 'tsdata')
      warning('!!! Can only downsample time-series (tsdata) objects. Skipping AO %s', ao_invars{jj});
    else
      % downsample factor
      fs_orig = bs(jj).data.fs;
      dsf = round(fs_orig/fsout);
      
      if (fs_orig/fsout) ~= dsf
        warning('!!! Can only downsample by an integer factor of original. Output will be at %g Hz.', fs_orig/dsf);
      end
      
      if dsf < 1
        error('### I can''t downsample - the sample rate is already lower than the requested.');
      elseif dsf>1
        % Do Y data
        n = floor(length(bs(jj).data.y(offset+1:end)) / dsf);
        idx = offset + (1:n*dsf);
        y = bs(jj).data.y(idx);
        % reshape and take mean
        bs(jj).data.setY(mean(reshape(y, dsf, n)));
        
        % If we have an x we should resample it
        if ~isempty(bs(jj).data.x)
          x = bs(jj).data.x(idx);
          % reshape and take mean
          bs(jj).data.setX(mean(reshape(x, dsf, n)));
        else
          % otherwise we need to adjust t0
          toffset = sum(0:dsf-1)/dsf/fs_orig;
          bs(jj).data.setT0(bs(jj).data.t0 + toffset + offset/fs_orig);
        end
      end
      % Build output AO
      bs(jj).data.setFs(fs_orig/dsf);
      bs(jj).name = sprintf('dsmean(%s)', ao_invars{jj});
      % Add history
      bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
      % Clear the errors since they don't make sense anymore
      clearErrors(bs(jj));
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

function pl = buildplist()
  pl = plist();
  
  % FSOUT
  p = param({'fsout', 'The output sample rate.'}, {1, {10}, paramValue.OPTIONAL});
  pl.append(p);
  
  % OFFSET
  p = param({'offset', 'Start averaging at a different index.'}, paramValue.DOUBLE_VALUE(0));
  pl.append(p);
  
end


