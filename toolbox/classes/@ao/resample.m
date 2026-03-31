% RESAMPLE overloads resample function for AOs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RESAMPLE overloads resample function for AOs.
%
% CALL:        bs = resample(a1,a2,a3,...,pl)
%              bs = resample(as,pl)
%              bs = as.resample(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     bs   - array of analysis objects, one for each input
%
% If no filter is specified for the resampling, then the default MATLAB
% filter is used. This is returned in the procinfo as an mfir object.
%
% Note: for input data types other than double, nearest neighbour
% interpolation is performed, and any specified filter is ignored.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'resample')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = resample(varargin)
  
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
  
  % check data types
  bs.checkNumericDataTypes(getInfo());
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});
  
  if isempty(pl)
    error('### Please give a plist with a parameter ''fsout''.');
  end
  
  % Get output sample rate
  fsout = find_core(pl, 'fsout');
  if isempty(fsout)
    error('### Please give a plist with a parameter ''fsout''.');
  end
  
  % Get a filter if specified
  filt = find_core(pl, 'filter');
  if ~isempty(filt) && ~isa(filt, 'mfir')
    error('The filter specified must be an mfir filter object (FIR filter).');
  end
  
  % Loop over AOs
  for jj = 1:numel(bs)
    if ~isa(bs(jj).data, 'tsdata')
      warning('!!! Skipping non-tsdata AO: %s', ao_invars{jj});
    elseif bs(jj).len <= 1
      warning('!!! Skipping AO with too few samples: %s', ao_invars{jj});
    else
      % Compute the resampling factors
      [P_fs, Q_fs] = utils.math.intfact(fsout, bs(jj).data.fs);
      [Q_Ts, P_Ts] = utils.math.intfact(1/fsout, 1/bs(jj).data.fs);
      if P_fs <= P_Ts
        P = P_fs;
        Q = Q_fs;
      else
        P = P_Ts;
        Q = Q_Ts;
      end
      utils.helper.msg(msg.PROC1, 'resampling by %g/%g', P, Q);
      
      % Check we have an evenly sampled data series
      if ~bs(jj).data.evenly()
        error('### The AO %s is unevenly sampled. It can not be resampled this way.', ao_invars{jj});
      end
      % It might be even with even sampled data that the x-vector isn't
      % collapsed -> force the collapse.
      bs(jj).data.collapseX;
      % clear errors
      bs(jj).clearErrors;
      
      % resample y
      y = bs(jj).data.getY;
      if ~isa(y, 'double')
        dclass = class(y);
        if ~isempty(filt)
          warning('The specified antialiasing filter will be ignored for object [%s] or type [%s]', bs(jj).name, dclass);
        end
        % interpolate on new grid with nearest neighbour
        vertices = bs(jj).x(1) + [0:1/fsout:bs(jj).nsecs-1/fsout];
        newY = interp1(bs(jj).x, double(bs(jj).y), vertices, 'nearest');
        bs(jj).data.setY(cast(newY, dclass));
        bs(jj).setProcinfo();
      else
        if isempty(filt)
          [newy, b] = resample(bs(jj).data.getY, P, Q);
          bs(jj).data.setY(newy);
          f = mfir(b, bs(jj).fs);
          bs(jj).setProcinfo(plist('filter', f));
        else
          [G,~] = rat(fsout/bs(jj).fs, 1e-12);
          b = G*filt.a;
          bs(jj).data.setY(resample(bs(jj).data.getY, P, Q, b));
          bs(jj).setProcinfo(plist('filter', filt));
        end
      end
      
      % Set new sample rate
      bs(jj).data.setFs(fsout);
      
      if ~callerIsMethod
        % Set output AO name
        bs(jj).name = sprintf('resample(%s)', ao_invars{jj});
        % Add history
        bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
      end
      
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
  ii.addSupportedNumTypes('single', 'int8', 'int16', 'int32', 'int64', 'uint8', 'uint16', 'uint32', 'logical');
  
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
  
  % Type
  p = param({'fsout',['The desired output frequency<br>'...
    '(must be > 0).']}, paramValue.EMPTY_DOUBLE);
  pl.append(p);
  
  p = param({'filter', 'The filter to apply in the resampling process. Note: filtering is only supported for input data of type double.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
end
% END

