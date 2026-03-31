% CONVERT perform various conversions on the ao.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CONVERT perform various conversions on the ao.
%
% CALL:        ao = convert(ao, pl)
%
% PARAMETERS:
%
%              'action' - choose a conversion to make [default: none]
%
% Possible actions:
%
%    Unit conversions:
%         's to Hz'   - convert seconds to Hz in the yunits of this AO.
%         'Hz to s'   - convert Hz to seconds in the yunits of this AO.
%
%    Data conversions:
%         'to cdata'  - convert the data in the AO to a cdata type.
%         'to tsdata' - convert the data in the AO to a tsdata type.
%         'to fsdata' - convert the data in the AO to a fsdata type.
%         'to xydata' - convert the data in the AO to a xydata type.
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'convert')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = convert(varargin)
  
  %%% Check if this is a call for parameters
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
  [as, ao_invars,rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  %%% Combine plists
  pl = applyDefaults(getDefaultPlist, pls);
  
  % Get action to perform
  action = lower(find_core(pl, 'action'));
  
  if isempty(action)
    % check rest
    for kk = 1:numel(rest)
      if ischar(rest{kk})
        action = lower(rest{kk});
        pl.pset('action', action);
      end
    end
  end
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  xaxis     = pl.find_core('xaxis');
  yaxis     = pl.find_core('yaxis');
  sliceAxis = pl.find_core('sliceAxis');
  
  % Loop over AOs
  out = [];
  for jj = 1:numel(bs)
    
    switch lower(action)
      case ''
        % do nothing
        b = bs(jj);
      case 's to hz'
        b = secondsToHz(bs(jj));
      case 'hz to s'
        b = HzToSeconds(bs(jj));
      case 'to cdata'
        b = tocdata(bs(jj), yaxis);
      case 'to tsdata'
        b = totsdata(bs(jj), xaxis, yaxis);
      case 'to fsdata'
        b = tofsdata(bs(jj), xaxis, yaxis);
      case 'to xydata'
        b = toxydata(bs(jj), xaxis, yaxis, sliceAxis);
      otherwise
        error('### Unknown action requested.');
    end
    
    for oo = 1:numel(b)      
      % Set history
      b(oo).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
    end
    
    % collect outputs
    out = [out b];
  end
  
  % see if we can reshape to match the input
  if numel(out) == numel(bs)
    out = reshape(out, size(bs));
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, out);
end

%----------------------------------------------
% Convert to xydata
function a = toxydata(a, xaxis, yaxis, sliceAxis)
  
  if isa(a.data, 'data3D')
    % for each x column, create an xydata
    a = convertFrom3DToXYdata(a, xaxis, yaxis, sliceAxis);
    
  else
    a = convertTo2D(a, 'xydata', xaxis, yaxis);
  end
  
end

%----------------------------------------------
% Convert to fsdata
function a = tofsdata(a, xaxis, yaxis)
  
  if isa(a.data, 'data3D')
    
    % for each x column, we create an fsdata
    a = convertFrom3DToFSdata(a, xaxis, yaxis);
    
  else
    
    t0 = a.t0;
    toffset = a.x(1);
    a = convertTo2D(a, 'fsdata', xaxis, yaxis);
    a.setT0(t0+toffset);
    
  end
end

%----------------------------------------------
% Convert to tsdata
function a = totsdata(a, xaxis, yaxis)

  oldt0   = [];
  
  if isa(a.data, 'data3D')
    
    % for each y row, we create a time-series
    a = convertFrom3DToTSdata(a, xaxis, yaxis);
    
  else
    
    if isa(a.data, 'tsdata') || isa(a.data, 'fsdata')
      oldt0 = a.t0;
    end
    
    a = convertTo2D(a, 'tsdata', xaxis, yaxis);
    
    if ~isempty(oldt0)
      a.setT0(oldt0);
    end
    
    % we now have a time-series
    a.setXunits('s');
  end
  
end


%------------------------------------------------
% Utility to convert to x-y data from 3D data
function out = convertFrom3DToXYdata(a, xaxis, yaxis, sliceAxis)
    
  if strcmpi(sliceAxis, 'z')
    error('The  z-axis can not be chosen as the slice axis');
  end
  
  out = [];
  switch sliceAxis
    case 'x'
      
      y = a.y;
      for kk=1:numel(y)
        
        % For 3D data the t0 seems to be set as NaN. Check and set based on
        % timespan instead.
        t0 = 'NaN';
        if isprop(a.data, 't0')
          t0 = a.data.t0;
        end        
        if strcmp(t0, 'NaN')
          if ~isempty(a.timespan)
            t0 = a.timespan.startT;
          end
        end
        
        z  = a.z;
        z = z(kk, :);
        dz = a.dz;
        if ~isempty(dz)
          dz = dz(kk, :);
        end
        b = ao(plist('xvals', a.x, 'yvals', z, 't0', t0, 'type', 'xydata'));
        b.setXaxisName(a.xaxisname);
        b.setYaxisName(a.zaxisname);
        
        b.setXunits(a.xunits);
        b.setYunits(a.zunits);
        
        b.setName(sprintf('%s @ %s=%f', a.name, a.yaxisname, y(kk)));
        out = [out b];
      end
      
    case 'y'
      x = a.x;
      sampPer = round(mean(diff(x)));
      for kk=1:numel(x)
        
        % For 3D data the t0 seems to be set as NaN. Check and set based on
        % timespan instead.
        t0 = 'NaN';
        if isprop(a.data, 't0')
          t0 = a.data.t0;
        end        
        if strcmp(t0, 'NaN') && ~isempty(a.timespan)
          t0 = a.timespan.startT;
        end
        
        z  = a.z;
        z = z(:, kk);
        dz = a.dz;
        if ~isempty(dz)
          dz = dz(:, kk);
        end
        b = ao(plist('xvals', a.y, 'yvals', z, 't0', t0, 'type', 'xydata'));        
        
        b.setXaxisName(a.yaxisname);
        b.setYaxisName(a.zaxisname);        
        b.setXunits(a.yunits);
        b.setYunits(a.zunits);
        
        % Set the timespan the new data covers.
        if a.data.xunits.isequal(unit('s'))
          t0 = t0 + x(kk);
          b.setTimespan(timespan(t0, t0+sampPer));
        end
        
        b.setName(sprintf('%s @ %s=%f', a.name, a.xaxisname, x(kk)));
        out = [out b];
      end      
    otherwise
      error('Unknown slice axis [%s]', sliceAxis);
  end
  
  % we return a single object
  out = matrix(out);
  
end


%------------------------------------------------
% Utility to convert to frequency-series data from 3D data
function out = convertFrom3DToFSdata(a, xaxis, yaxis)
    
  out = [];
  x = a.x;
  for kk=1:numel(x)
    
    % For 3D data the t0 seems to be set as NaN. Check and set based on
    % timespan instead.
    t0 = 'NaN';
    if isprop(a.data, 't0')
      t0 = a.data.t0;
    end        
    if strcmp(t0, 'NaN')
      t0 = a.timespan.startT;
    end
    
    z  = a.z;
    z = z(:, kk);
    dz = a.dz;
    if ~isempty(dz)
      dz = dz(:, kk);
    end
    b = ao(plist('xvals', a.y, 'yvals', z, 't0', t0, 'type', 'fsdata'));
    b.setXaxisName(a.yaxisname);
    b.setYaxisName(a.zaxisname);
    b.setName(sprintf('%s @ %s=%f', a.name, a.xaxisname, x(kk)));
    out = [out b];
  end
  
  % we return a single object
  out = matrix(out);
  
end

%------------------------------------------------
% Utility to convert to time-series data from 3D data
function out = convertFrom3DToTSdata(a, xaxis, yaxis)
    
  out = [];
  y = a.y;
  for kk=1:numel(y)
    
    % For 3D data the t0 seems to be set as NaN. Check and set based on
    % timespan instead.
    t0 = 'NaN';
    if isprop(a.data, 't0')
      t0 = a.data.t0;
    end        
    if strcmp(t0, 'NaN')
      t0 = a.timespan.startT;
    end
    
    z  = a.z;
    z = z(kk, :);
    dz = a.dz;
    if ~isempty(dz)
      dz = dz(kk, :);
    end
    b = ao(plist('xvals', a.x, 'yvals', z, 't0', t0, 'type', 'tsdata'));
    b.setXaxisName(a.xaxisname);
    b.setYaxisName(a.zaxisname);
    b.setName(sprintf('%s @ %s=%f', a.name, a.yaxisname, y(kk)));
    out = [out b];
  end
  
  % we return a single object
  out = matrix(out);
  
end

%------------------------------------------------
% Utility to convert to 2D data
function a = convertTo2D(a, type, xaxis, yaxis)
  
  if isa(a.data, 'cdata')
    x      = 1:numel(a.data.y);
    dx     = [];
    xunits = unit();
  else
    [x, dx, xunits] = dataOfAxis(a, xaxis);
  end
  
  [y, dy, yunits] = dataOfAxis(a, yaxis);
  
  a.data = feval(type, x, y);
  a.data.setDx(dx);
  a.data.setDy(dy);
  a.data.setXunits(xunits);
  a.data.setYunits(yunits);
  
end

function [data, ddata, dunits] = dataOfAxis(a, axis)
  switch axis
    case 'x'
      data   = a.x;
      ddata  = a.dx;
      dunits = a.xunits;    
    case 'y'
      data   = a.data.y;
      ddata  = a.data.dy;
      dunits = a.data.yunits;    
    case 'z'
      data   = a.z;
      ddata  = a.dz;
      dunits = a.zunits;    
    otherwise
      error('Unknown axis [%s]', axis);
  end
  
end

%----------------------------------------------
% Convert to cdata
function a = tocdata(a, axis)
  switch axis
    case 'x'
      y      = a.x;
      dy     = a.dx;
      yunits = a.xunits;
    case 'y'
      y      = a.y;
      dy     = a.dy;
      yunits = a.yunits;
    case 'z'
      y      = a.z;
      dy     = a.dz;
      yunits = a.zunits;
    otherwise
      error('Unknown axis [%s]', axis);
  end
  
  a.data = cdata();
  a.data.setY(y);
  a.data.setDy(dy);
  a.data.setYunits(yunits);
end

%----------------------------------------------
% Convert any 's' units to 'Hz' in the yunits
function a = secondsToHz(a)
  a.data.yaxis.units.sToHz;
end

%----------------------------------------------
% Convert any 'Hz' units to 's' in the yunits
function a = HzToSeconds(a)
  a.data.yaxis.units.HzToS;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
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
  pl = plist({'action', 'Choose the action to perform.'}, ...
    {1, {'', 's to Hz', 'Hz to s', 'to cdata', 'to tsdata', 'to fsdata', 'to xydata'}, paramValue.SINGLE});
  
  % xaxis
  p = param({'xaxis', 'The axis to use to fill the new x field.'}, {1, {'x', 'y', 'z'}, paramValue.SINGLE});
  pl.append(p);
  
  % yaxis
  p = param({'yaxis', 'The axis to use to fill the new y field.'}, {2, {'x', 'y', 'z'}, paramValue.SINGLE});
  pl.append(p);
  
  % sliceaxis
  p = param({'sliceaxis', 'For the case of converting 3D data to xydata, choose the axis on which to perform the slicing.'}, {2, {'x', 'y'}, paramValue.SINGLE});
  pl.append(p);
  
end

