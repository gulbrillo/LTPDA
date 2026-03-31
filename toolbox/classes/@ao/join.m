% JOIN multiple AOs into a single AO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: JOIN multiple AOs into a single AO.
%              If any two AOs overlap, then the values from the first appear
%              in the output AO. 
% 
%              Note: If the input AOs are of type 'tsdata', then they will
%              be sorted in ascending order according the t0 of each
%              object. Additionally, if the 'sort' plist key is set to
%              true, then the output data will be sorted according to the
%              x-values (not applicable for cdata AOs).
% 
%
% CALL:        bs = join(a1,a2,a3,...,pl)
%              bs = join(as,pl)
%              bs = as.join(pl)
%
% INPUTS:      aN   - input analysis objects
%              as   - input analysis objects array
%              pl   - input parameter list
%
% OUTPUTS:     b    - output analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'join')">Parameters Description</a>
%
% REMARK:      Input AOs should be of the same type; if not, only AOs of the
%              type of the first input AO will be joined together to produce
%              the output.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PARAMETERS:  'zerofill' - Fills with zeros the gaps between the data
%                           points of the subsequent aos. [Default: 'false']
%              'sameT0'   - Does not recalculate t0 but uses the common
%                           one. [Default: 'false']
%                           Note: the t0 among different objects must be the same!
%              'merge'    - Rather than join input tsdata sequentially the 
%                           merge option combines overlapping data and then
%                           drops duplicates.
%

function varargout = join(varargin)
  
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
  
  % short circuit
  if numel(as) == 1
    if nargout == 1
      a = copy(as,1);
      varargout{1} = a;
    end
    return 
  end
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist, varargin{:});

  
  %----------------------------------------------
  % Get data type from the first AO
  dtype = class(as(1).data);
  
  % Sort the input AOs by t0, if applicable
  if pl.find('sort times')
    if isa(as(1).data, 'tsdata')
      times = as.t0.double;
      [~, idx] = sort(times);
      as = as(idx);
    end
  end
  
  %----------------------------------------------
  % Go through each AO and collect the data of type 'dtype'
  
  histin = [];
  xo     = [];
  yo     = [];
  zo     = [];
  dxo    = [];
  dyo    = [];
  dzo    = [];
  xos    = [];
  yos    = [];
  zos    = [];
  dxos   = [];
  dyos   = [];
  dzos   = [];
  xunits = [];
  yunits = [];
  zunits = [];
  enbw0  = [];
  fs     = -1;
  aname  = '';
  adescr = '';
  pi = [];
  T0s = [];
  endTs = [];
  if as(1).data.isprop('xaxis')
    xunitsSimple = simplify(as(1).data.xunits);
    xunits       = as(1).data.xunits;
  else
    xunits      = unit();
  end
  yunitsSimple = simplify(as(1).data.yunits);
  yunits       = as(1).data.yunits;
  
  if as(1).data.isprop('zaxis')
    zunitsSimple = simplify(as(1).data.zunits);
    zunits       = as(1).data.zunits;
  end
  
  % Get the tolerance for considering fs equal
  fstol = find_core(pl, 'fstol');

  % Compute time offset for tsdata objects to avoid rounding errors later
  if strcmp(dtype, 'tsdata')
    minT0milli = getMinT0(as);
  else
    minT0milli = 0;
  end
  
  if strcmp(dtype, 'xyzdata')
    for ii = 1:numel(as)
      ts = as(ii).timespan();
      T0s   = [T0s, ts.startT];
      endTs = [endTs, ts.endT];
    end
    minT0milli = min(T0s);
    minT0milli = minT0milli.utc_epoch_milli;
    maxTmilli  = max(endTs);
    maxTmilli  = maxTmilli.utc_epoch_milli;
  end
  
  % loop over AOs
  for jj = 1 :numel(as)
    % Only get the data type we want
    if isa(as(jj).data, dtype)
      switch lower(dtype)
        case 'tsdata'          
          
          % collect the samples from this AO
          [xo, yo, dxo, dyo] = collectTsdata(as(jj), xo, yo, dxo, dyo, minT0milli, pl, fs);
                    
          % check fs
          if (fs > 0) && (abs(as(jj).data.fs - fs) > fstol*fs)
            fprintf('## Warning: Data has different sample rates [%g, %g]\n', as(jj).data.fs, fs);
          end
          
          % store fs
          fs = as(jj).data.fs;
          
          % check xunits
          if ~isequal(xunitsSimple, simplify(as(jj).data.xunits))
            error('### The x-units of the analysis objects are not the same %s <-> %s', char(xunits), char(as(jj).data.xunits));
          end
          % check yunits
          u = simplify(as(jj).data.yunits);
          if ~isempty(u) && ~isempty(u.strs) && ~isequal(yunitsSimple, u)
            warning('### The y-units of the analysis objects are not the same %s <-> %s', char(yunits), char(as(jj).data.yunits));
          end
          
          % store T0
          T0s(jj) = as(jj).t0;
          
        case 'fsdata'          
          
          % collect the samples from this AO
          [xo, yo, dxo, dyo, enbw0] = collectFsdata(as(jj), xo, yo, dxo, dyo, enbw0, pl);

          % store fs
          fs = as(jj).data.fs;
          
          % check xunits
          if ~isequal(xunitsSimple, simplify(as(jj).data.xunits))
            error('### The x-units of the analysis objects are not the same %s <-> %s', char(xunits), char(as(jj).data.xunits));
          end
          % check yunits
          if ~isequal(yunitsSimple, simplify(as(jj).data.yunits))
            error('### The y-units of the analysis objects are not the same %s <-> %s', char(yunits), char(as(jj).data.yunits));
          end
          
        case 'xydata'
          
          [xo, yo, dxo, dyo] = collectXydata(as(jj), xo, yo, dxo, dyo);
          
          % check xunits
          if ~isequal(xunitsSimple, simplify(as(jj).data.xunits))
            error('### The x-units of the analysis objects are not the same %s <-> %s', char(xunits), char(as(jj).data.xunits));
          end
          % check yunits
          if ~isequal(yunitsSimple, simplify(as(jj).data.yunits))
            error('### The y-units of the analysis objects are not the same %s <-> %s', char(yunits), char(as(jj).data.yunits));
          end
          
        case 'xyzdata'
          
          [xo, yo, zo, dxo, dyo, dzo] = collectXyzdata(as(jj), xo, yo, zo, dxo, dyo, dzo, minT0milli, pl);
          
          % check xunits
          if ~isequal(xunitsSimple, simplify(as(jj).data.xunits))
            error('### The x-units of the analysis objects are not the same %s <-> %s', char(xunits), char(as(jj).data.xunits));
          end
          % check yunits
          if ~isequal(yunitsSimple, simplify(as(jj).data.yunits))
            error('### The y-units of the analysis objects are not the same %s <-> %s', char(yunits), char(as(jj).data.yunits));
          end
          % check zunits
          if ~isequal(zunitsSimple, simplify(as(jj).data.zunits))
            error('### The z-units of the analysis objects are not the same %s <-> %s', char(zunits), char(as(jj).data.zunits));
          end
              
        case 'cdata'
          try
            
            [yo, dyo] = collectCdata(as(jj), yo, dyo);
            
          catch E
            disp(E.message)
            error('### It is not possible to join the data or error because they have different dimensions.');
          end
          
          % check yunits
          if ~isequal(yunitsSimple, simplify(as(jj).data.yunits))
            error('### The y-units of the analysis objects are not the same %s <-> %s', char(yunits), char(as(jj).data.yunits));
          end
          
        otherwise
          error('### Unknown data type');
      end
      % Collect this input history
      histin = [histin as(jj).hist];
      % Collect the 'plotinfo'
      if ~isempty(as(jj).plotinfo)
        pi = as(jj).plotinfo;
      end
      % Collect the descriptions
      if isempty(adescr)
        adescr = as(jj).description;
      else
        adescr = [adescr ', ' as(jj).description];
      end
      % Collect names, invars
      if ~isempty(aname)
        if ~strcmp(aname, as(jj).name)
          aname = [aname ',' as(jj).name];
        end
      else
        aname = as(jj).name;
      end
    else
      warning('!!! Ignoring AO input with data type %s', dtype);
    end
  end
  
  %----------------------------------------------
  % Now sort output vectors
  if strcmp(dtype, 'xyzdata')
    [xos, yos, zos, dxos, dyos, dzos] = sortXyzdata(xo, yo, zo, dxo, dyo, dzo, pl);
  else  
    [xos, yos, dxos, dyos] = sortData(xo, yo, dxo, dyo, pl, dtype);
  end
  
  % Keep the data shape if the input AO
  if ~strcmp(dtype, 'xyzdata')
    if size(as(1).data.y,1) == 1
      xos = xos.';
      yos = yos.';
    end
  end

  %%% Build output data object
  data = getData(dtype, xos, yos, zos, dxos, dyos, dzos, fs, enbw0, xunits, yunits, zunits, minT0milli);
  
  %----------------------------------------------
  % Build output AO
  if nargout == 0
    a = as(1);
    a.data = data;
  else
    a = ao(data);
  end
  
  % I think you have to manually set the timespan for the joined xyzdata.
  if strcmp(dtype, 'xyzdata')
    ts = timespan((minT0milli/1000), (maxTmilli/1000));
    a.setTimespan(ts);
  end
  
  % Set name
  a.name = aname;
  % Set description
  a.description = adescr;
  % Set plotinfo
  a.plotinfo = pi;
  % Add history
  a.addHistory(getInfo('None'), pl, ao_invars, histin);
  
  %----------------------------------------------
  % set output
  varargout{1} = a;
end

function data = getData(dtype, xos, yos, zos, dxos, dyos, dzos, fs, enbw0, xunits, yunits, zunits, minT0milli)
  switch lower(dtype)
    case 'tsdata'      
      data = tsdata(xos, yos);
      data.setT0((minT0milli/1000));
      data.setDx(dxos);
      data.setDy(dyos);
      data.setXunits(xunits);
      data.setYunits(yunits);
      data.collapseX;
    case 'fsdata'
      if all(isnan(enbw0))
        enbw0 = [];
      elseif all(diff(enbw0) == 0)
        enbw0 = enbw0(1);
      end
      data = fsdata(xos, yos);
      data.setDx(dxos);
      data.setDy(dyos);
      data.setEnbw(enbw0);
      data.setFs(fs);
      data.setXunits(xunits);
      data.setYunits(yunits);
    case 'xydata'
      data = xydata(xos, yos);
      data.setDx(dxos);
      data.setDy(dyos);
      data.setXunits(xunits);
      data.setYunits(yunits);
    case 'xyzdata'
      data = xyzdata(xos, yos, zos);
      data.setDx(dxos);
      data.setDy(dyos);
      data.setDz(dzos);
      data.setXunits(xunits);
      data.setYunits(yunits);
      data.setZunits(zunits);
    case 'cdata'
      data = cdata(yos);
      data.setDy(dyos);
      data.setYunits(yunits);
  end
end
  
function [xos, yos, dxos, dyos] = sortData(xo, yo, dxo, dyo, pl, dtype)
  
  if ~isempty(xo) && (pl.find_core('sort') ||  pl.find_core('merge'))
    [xos, idx] = sort(xo);
    yos = yo(idx);
    dxos = dxo(idx);
    dyos = dyo(idx);
  else
    xos = xo;
    yos = yo;
    dxos = dxo;
    dyos = dyo;
  end
  
  % If the merge data has been done there are potentially a lot of
  % duplicate values. This removes them.  
  if strcmp(dtype, 'tsdata') && pl.find_core('merge')
    duptol = find_core(pl, 'duptol');
    d = abs(diff(xos));
    idx = find(d<duptol);
    xos(idx) = [];
    yos(idx) = [];
    dxos(idx) = [];
    dyos(idx) = [];
  end
  
  if all(dxos == 0)
    dxos = [];
  elseif all(diff(dxos) == 0)
    dxos = dxos(1);
  end
  if all(dyos == 0)
    dyos = [];
  elseif all(diff(dyos) == 0)
    dyos = dyos(1);
  end
     
end

function [xos, yos, zos, dxos, dyos, dzos] = sortXyzdata(xo, yo, zo, dxo, dyo, dzo, pl)
  
  switch find_core(pl, 'joinaxis')
    case 'x'
      
      [xos, idx] = sort(xo);
      yos = yo;
      dyos = dyo;
      zos = zo(:,idx);
      if numel(dxo) > 1
        dxos = dxo(idx);
      else
        dxos = dxo;
      end
      if numel(dzo) > 1
        dzos = dzo(:,idx);
      else
        dzos = dzo;
      end
      
      duptol = find_core(pl, 'duptol');
      d = abs(diff(xos));
      idx = find(d<duptol);
      xos(idx) = [];
      zos(:,idx) = [];
      
      if numel(dxos) > 1
        dxos(idx) = [];
      end
      if numel(dzos) > 1
        dzos(:,idx) = [];
      end
      
    case 'y'
      error('### The code for joining xyzdata in the y axis still needs to be written.');
    otherwise
      error('### Unknown axis to join xyzdata.');
  end
  
  if all(dxos == 0)
    dxos = [];
  elseif all(diff(dxos) == 0)
    dxos = dxos(1);
  end
  if all(dyos == 0)
    dyos = [];
  elseif all(diff(dyos) == 0)
    dyos = dyos(1);
  end
  if all(dzos == 0)
    dzos = [];
  elseif all(diff(dzos) == 0)
    dzos = dzos(1);
  end
     
end

function [yo, dyo] = collectCdata(as, yo, dyo)
  yo = [yo; as.y];
  if numel(as.dy) == 0
    dy = zeros(numel(as.y),1);
  elseif numel(as.dy) == 1
    dy = ones(numel(as.y),1) .* as.dy;
  else
    dy = as.dy;
  end
  dyo = [dyo; dy];
end
            
function [xo, yo, dxo, dyo] = collectXydata(as, xo, yo, dxo, dyo)
  
  xo = [xo; as.x];
  yo = [yo; as.y];
  if numel(as.dx) == 0
    dx = zeros(numel(as.x),1);
  elseif numel(as.dx) == 1
    dx = ones(numel(as.x),1) .* as.dx;
  else
    dx = as.dx;
  end
  dxo = [dxo; dx];
  if numel(as.dy) == 0
    dy = zeros(numel(as.y),1);
  elseif numel(as.dy) == 1
    dy = ones(numel(as.y),1) .* as.dy;
  else
    dy = as.dy;
  end
  dyo = [dyo; dy];
end

function [xo, yo, zo, dxo, dyo, dzo] = collectXyzdata(as, xo, yo, zo, dxo, dyo, dzo, minT0milli, pl)
  
  switch find_core(pl, 'joinaxis')
    case 'x'          
      % If x-axis is in seconds convert to absolute times.
      if as.data.xunits.isequal(unit('s'))
        ts = as.timespan();
        t0 = (ts.startT.utc_epoch_milli - minT0milli)/1000;        
        x = as.x + t0;
      else
        x = as.x;
      end

      xo = [xo; x];
      yo = as.y;
      zo = [zo, as.z];

      if numel(as.dx) == 0
        dx = zeros(numel(as.x),1);
      elseif numel(as.dx) == 1
        dx = ones(numel(as.x),1) .* as.dx;
      else
        dx = as.dx;
      end
      dxo = [dxo; dx];

      if numel(as.dy) == 0
        dy = zeros(numel(as.y),1);
      elseif numel(as.dy) == 1
        dy = ones(numel(as.y),1) .* as.dy;
      else
        dy = as.dy;
      end
      dyo = [dyo; dy];

      if numel(as.dz) == 0
        dz = zeros(size(as.z));
      elseif numel(as.dz) == 1
        dz = ones(numel(as.z),1) .* as.dz;
      else
        dz = as.dz;
      end
      dzo = [dzo, dz];

    case 'y'
      error('### The code for joining xyzdata in the y axis still needs to be written.');
    otherwise
      error('### Unknown axis to join xyzdata.');
  end
  
end

function [xo, yo, dxo, dyo, enbw0] = collectFsdata(as, xo, yo, dxo, dyo, enbw0, pl)
  
  if pl.find_core('merge')
    
    xo  = [xo; as.x];
    yo  = [yo; as.y];
    
    % Need to protect against situation where some objects have errors
    % while others don't, otherwise the error vector will be a different
    % length to the data.
    if numel(as.dx) == 0
      dxo = [dxo; zeros(numel(as.x),1)];
    elseif numel(as.dx) == 1
      dxo = [dxo; ones(numel(as.x),1).*as.dx];
    else
      dxo = [dxo; as.dx];
    end
    if numel(as.dy) == 0
      dyo = [dyo; zeros(numel(as.y),1)];
    elseif numel(as.dy) == 1
      dyo = [dyo; ones(numel(as.y),1).*as.dy];
    else
      dyo = [dyo; as.dy];
    end
    
  else
    %%% Collect all fsdata samples
    if isempty(xo)
      idxBefore = 1:numel(as.x);
      idxAfter  = [];
    else
      idxBefore = find(as.x < xo(1));
      idxAfter  = find(as.x > xo(end));
    end
    xo = [as.x(idxBefore); xo; as.x(idxAfter)];
    yo = [as.y(idxBefore); yo; as.y(idxAfter)];
    
    %%% Collect all errors
    % dx
    if numel(as.dx) == 0
      dx = zeros(numel(as.x),1);
    elseif numel(as.dx) == 1
      dx = ones(numel(as.x),1) .* as.dx;
    else
      dx = as.dx;
    end
    dxo = [dx(idxBefore); dxo; dx(idxAfter)];
    % dy
    if numel(as.dy) == 0
      dy = zeros(numel(as.y),1);
    elseif numel(as.dy) == 1
      dy = ones(numel(as.y),1) .* as.dy;
    else
      dy = as.dy;
    end
    dyo = [dy(idxBefore); dyo; dy(idxAfter)];
    % enbw
    if numel(as.data.enbw) == 0
      enbw = NaN(numel(as.y),1);
    elseif numel(as.data.enbw) == 1
      enbw = ones(numel(as.y),1) .* as.data.enbw;
    else
      enbw = as.data.enbw;
    end
    enbw0 = [enbw(idxBefore); enbw0; enbw(idxAfter)];
  end
  
end

function [xo, yo, dxo, dyo, t0] = collectTsdata(as, xo, yo, dxo, dyo, minT0milli, pl, fs)
  
  % here we concatenate time-series
  t0 = (as.data.t0.utc_epoch_milli - minT0milli)/1000;
  % make proper time vector
  x = as.x + t0;
  
  if pl.find_core('merge')
    
    xo  = [xo; x];
    yo  = [yo; as.y];
    
    % Need to protect against situation where some objects have errors
    % while others don't, otherwise the error vector will be a different 
    % length to the data.
    if numel(as.dx) == 0      
      dxo = [dxo; zeros(numel(as.x),1)];      
    elseif numel(as.dx) == 1      
      dxo = [dxo; ones(numel(as.x),1).*as.dx];
    else
      dxo = [dxo; as.dx];
    end    
    if numel(as.dy) == 0      
      dyo = [dyo; zeros(numel(as.y),1)];      
    elseif numel(as.dy) == 1      
      dyo = [dyo; ones(numel(as.y),1).*as.dy];
    else
      dyo = [dyo; as.dy];
    end
    
  else
    
    % only add samples past the end of existing (first loop)
    if isempty(xo)
      yo = as.y;
      xo = x;
      if numel(as.dx) == 0
        dxo = zeros(numel(as.x),1);
      elseif numel(as.dx) == 1
        dxo = ones(numel(as.x),1) .* as.dx;
      else
        dxo = as.dx;
      end
      if numel(as.dy) == 0
        dyo = zeros(numel(as.y),1);
      elseif numel(as.dy) == 1
        dyo = ones(numel(as.y),1) .* as.dy;
      else
        dyo = as.dy;
      end
    else
      idxPost = find(x > max(xo));
      idxPre  = find(x < min(xo));
      
      %%%%%%%%%%   Fill the gaps with zeros   %%%%%%%%%%
      zerofill = utils.prog.yes2true(find_core(pl, 'zerofill'));
      
      if zerofill
        % Check if there is a gap between the x-values and the pre-values.
        if ~isempty(idxPre)
          interStart = x(idxPre(end));
          interEnd   = xo(1);
          nsecsPre2no = interEnd - interStart;
          
          % The gap must be larger than 1/fs in order to
          % fill the gap with zeros
          if nsecsPre2no > 1/fs
            x_interPre = linspace(interStart+1/fs, interEnd-1/fs, nsecsPre2no*fs-2*1/fs).';
            y_interPre = zeros(length(x_interPre), 1);
          else
            x_interPre = [];
            y_interPre = [];
          end
        else
          x_interPre = [];
          y_interPre = [];
        end
        
        % Check if there is a gap between the x-values and the post-values.
        if ~isempty(idxPost)
          interStart   = xo(end);
          interEnd     = x(idxPost(1));
          nsecsPost2no = interEnd - interStart;
          
          % The gap must be larger than 1/fs in order to
          % fill the gap with zeros
          if nsecsPost2no > 1/fs
            x_interPost = linspace(interStart+1/fs, interEnd-1/fs, nsecsPost2no*fs-1/fs).';
            y_interPost = zeros(length(x_interPost), 1);
          else
            x_interPost = [];
            y_interPost = [];
          end
        else
          x_interPost = [];
          y_interPost = [];
        end
        
      else
        %%%%%%%%%%   Don't fill the gaps with zeros   %%%%%%%%%%
        x_interPre  = [];
        y_interPre  = [];
        x_interPost = [];
        y_interPost = [];
      end
      xo = [x(idxPre); x_interPre; xo; x_interPost; x(idxPost)];
      yo = [as.data.getY(idxPre); y_interPre; yo; y_interPost; as.data.getY(idxPost)];
      
      %%% Collect errors
      if numel(as.dx) == 0
        dx = zeros(numel(as.x),1);
      elseif numel(as.dx) == 1
        dx = ones(numel(as.x),1) .* as.dx;
      else
        dx = as.dx;
      end
      
      if numel(as.dy) == 0
        dy = zeros(numel(as.y),1);
      elseif numel(as.dy) == 1
        dy = ones(numel(as.y),1) .* as.dy;
      else
        dy = [as.dy];
      end
      
      x_interPre = zeros(numel(x_interPre),1);
      y_interPre = zeros(numel(y_interPre),1);
      x_interPost = zeros(numel(x_interPost),1);
      y_interPost = zeros(numel(y_interPost),1);
      dxo = [dx(idxPre); x_interPre; dxo; x_interPost; dx(idxPost)];
      dyo = [dy(idxPre); y_interPre; dyo; y_interPost; dy(idxPost)];
    end
  end
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
  ii.setArgsmin(2);
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
  
  % Zero fill
  p = param({'zerofill','Fills with zeros the gaps between the data points of the subsequent aos.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % Same T0
  p = param({'sameT0', ['Does not recalculate t0 but uses the common one.<br>', ...
    'Note: the t0 among different objects must be the same!']}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % fstol
  p = param({'fstol', ['Relative tolerance between sampling frequency of different objects.<br>', ...
    'Jitter in the sampling frequency by less than this amount will be neglected.<br>', ...
    'If the difference is more than the set value, an error will occur.']}, paramValue.DOUBLE_VALUE(1e-6));
  pl.append(p);
  
  % sort
  p = param({'sort', ['Sort the output data by their x-values.']}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % sort times
  p = param({'sort times', ['Sort the input objects by their T0s.']}, paramValue.TRUE_FALSE);
  pl.append(p);
  
  % Merge
  p = param({'merge', ['Rather than join input tsdata sequentially the merge option combines overlapping data and then drops duplicates. Ignores fill zeros.']}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % Drop duplicate tolerance
  p = param({'duptol', 'The time interval tolerance to consider two consecutive samples as duplicates. Only used when merge is set to true.'}, ...
    {1, {5e-3}, paramValue.OPTIONAL});
  pl.append(p);
  
  % Axis to join
  p = param({'joinaxis', 'For the case of joining 3D data, choose the axis on which to perform the join.'}, {1, {'x', 'y'}, paramValue.SINGLE});
  pl.append(p);
  
end


%--------------------------------------------------------------------------
% Get Offset of this set of time-vectors
%--------------------------------------------------------------------------
function Toff = getMinT0(as)
  Toff = min(as.t0);
  Toff = Toff.utc_epoch_milli;
end

