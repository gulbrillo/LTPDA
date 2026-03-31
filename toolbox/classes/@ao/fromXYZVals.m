% FROMXYZVALS Construct an ao from a value set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromXYZVals
%
% DESCRIPTION: Construct an ao from a value set
%
% CALL:        a = aoFromXYVals(a, vals)
%
% PARAMETER:   vals:     Constant values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = fromXYZVals(a, pli, callerIsMethod)
  
  if callerIsMethod
    % do nothing
  else
    % get AO info
    ii = ao.getInfo('ao', 'From XYZ Values');
  end
  
  if callerIsMethod
    pl        = pli;
  else
    % Combine input plist with default values
    % TODO: the parse step should be removed and included somehow into plist/applyDefaults
    [pl, ~] = applyDefaults(ii.plists, pli);
  end
  
  % Get values from the plist
  xvals = find_core(pl, 'xvals');
  yvals = find_core(pl, 'yvals');
  zvals = find_core(pl, 'zvals');
  zaxis = find_core(pl, 'zaxis');
  
  % properties to pick up along the way through
  dz     = [];
  zunits = [];
  dx     = [];
  xunits = [];
  dy     = [];
  yunits = [];
  desc   = '';
  name   = '';
  
  % check the z-values
  if isa(zvals, 'ao')
    desc = zvals.description;
    switch zaxis
      case 'x'        
        dz = transpose(zvals.dx);
        zunits = zvals(1).xunits;
        zvals = transpose(zvals.x);        
      case 'y'
        dz = transpose(zvals.dy);
        zunits = zvals(1).yunits;
        zvals = transpose(zvals.y);        
      case 'z'
        dz = transpose(zvals.dz);
        zunits = zvals(1).zunits;
        name   = zvals(1).name;
        zvals = zvals.z;
      otherwise
        error('Unrecognized z-axis value %s', zaxis);
    end
  end
  
  if isa(yvals, 'ao')
    dy = yvals.dy;
    yunits = yvals.yunits;
    yvals  = yvals.y;
  end
  
  ts = [];
  if isa(xvals, 'ao')
    dx = xvals.dx;
    xunits = xvals.xunits;
    ts = xvals.timespan;
    xvals  = transpose(xvals.x);
  end
  
  % Create an AO with cdata if no value is set
  if isempty(xvals) || isempty(yvals) || isempty(zvals)
    error('### Please specify some X, Y and Z values.');
  end
  
  % Construct xyz-data object
  data_obj = xyzdata(xvals, yvals, zvals);
  
  % Set errors
  dx = plistOrDefault(pl, 'dx', dx);
  dy = plistOrDefault(pl, 'dx', dy);
  dz = plistOrDefault(pl, 'dx', dz);
  proppl = plist('dx', dx, 'dy', dy, 'dz', dz);
  data_obj.setErrorsFromPlist(proppl);

  % set units
  data_obj.setXunits(plistOrDefault(pl, 'xunits', xunits));
  data_obj.setYunits(plistOrDefault(pl, 'yunits', yunits));
  data_obj.setZunits(plistOrDefault(pl, 'zunits', zunits));
    
  % Set data
  a.data  = data_obj;
  
  % Set timespan
  a.timespan = plistOrDefault(pl, 'timespan', ts);;
  
  % Set description
  a.description = plistOrDefault(pl, 'description', desc);
  
  % Set name
  a.name = plistOrDefault(pl, 'name', name);
    
  if callerIsMethod
    % do nothing
  else
    % Add history
    a.addHistory(ii, pl, [], []);
  end
  
end

function val = plistOrDefault(pl, key, val)
  
  pval = pl.find_core(key);
  if ~isempty(pval)
    val = pval;
  end
end

