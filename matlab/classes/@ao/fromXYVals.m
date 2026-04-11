% FROMXYVALS Construct an ao from a value set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromXYVals
%
% DESCRIPTION: Construct an ao from a value set
%
% CALL:        a = aoFromXYVals(a, vals)
%
% PARAMETER:   vals:     Constant values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = fromXYVals(a, pli, callerIsMethod)
  
  if callerIsMethod
    % do nothing
  else
    % get AO info
    ii = ao.getInfo('ao', 'From XY Values');
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
  fs    = find_core(pl, 'fs');
  dtype = find_core(pl, 'type');
  t0    = find_core(pl, 't0');
  
  if isa(yvals, 'ao')
    yvals = yvals.y;
  end
  
  if isa(xvals, 'ao')
    xvals = xvals.x;
  end
  
  % Create an AO with cdata if no value is set
  if isempty(xvals) && isempty(yvals)
    error('### Please specify some X and Y values.');
  end
  
  % Try to decide what to do if the user doesn't specify dtype
  if isempty(dtype)
    if ~isempty(yvals)
      if ~isempty(fs)
        dtype = 'tsdata';
      else
        dtype = 'xydata';
      end
    else
      dtype = 'cdata';
    end
  end
  
  %--------- Now decide what to construct
  switch lower(dtype)
    
    case 'tsdata'
      if ~isempty(xvals) && ~isempty(yvals) && ~isempty(fs)
        data_obj = tsdata(xvals, yvals, fs);
      elseif ~isempty(xvals) && ~isempty(yvals)
        if numel(xvals) ~= numel(yvals) && numel(yvals) == 1
          data_obj = tsdata(xvals, yvals*ones(size(xvals)));
        else
          data_obj = tsdata(xvals, yvals);
        end
      elseif ~isempty(yvals) && ~isempty(fs)
        data_obj = tsdata(yvals, fs);
      else
        error('### To build an AO with tsdata please specify at least yvals and fs');
      end
      if ~isempty(t0)
        data_obj.setT0(time(t0));
      else
        data_obj.setT0(time(0));
      end
      
      % Handle toffset
      % For evenly sampled which means the original toffset of the data has
      % been put in the toffset field, so we need to add the user
      % specified toffset.
      % For unevenly sampled data, the data object is constructed with a
      % toffset of zero. In any case the following works for both cases
      % except when this is called from a method, in which case we don't
      % apply the defaults and the toffset could be []. MATLAB returns []
      % when you do <double> + [], so we need to check that the plist value
      % of toffset is not empty before doing the sum.
      if ~isempty(pl.find_core('toffset'))
        toffset = data_obj.toffset + 1000*pl.find_core('toffset');
        data_obj.setToffset(toffset);
      end
      
    case 'fsdata'
      if ~isempty(xvals) && ~isempty(yvals) && ~isempty(fs)
        data_obj = fsdata(xvals, yvals, fs);
      elseif ~isempty(xvals) && ~isempty(yvals)
        data_obj = fsdata(xvals, yvals);
      elseif ~isempty(yvals) && ~isempty(fs)
        data_obj = fsdata(yvals, fs);
      else
        error('### To build an AO with fsdata please specify at least xvals and yvals');
      end
      
    case 'xydata'
      if ~isempty(xvals) && ~isempty(yvals)
        data_obj = xydata(xvals, yvals);
      elseif ~isempty(yvals)
        data_obj = xydata(yvals);
      else
        error('### To build an AO with xydata please specify at least yvals');
      end
      
    case 'cdata'
      if ~isempty(yvals)
        data_obj = cdata(yvals);
      else
        error('### To build an AO with cdata please specify yvals');
      end
      
    otherwise
      error('### Can not build a data object with the given parameters.');
      
  end
  
  if isa(data_obj, 'fsdata')
    xu = pl.find_core('xunits');
    if isempty(xu) || (isa(xu, 'unit') && isempty(xu.strs))
      pl.pset('xunits', 'Hz');
    end
  elseif isa(data_obj, 'tsdata')
    xu = pl.find_core('xunits');
    if isempty(xu) || (isa(xu, 'unit') && isempty(xu.strs))
      pl.pset('xunits', 's');
    end
  end
  
  % Set errors from plist
  data_obj.setErrorsFromPlist(pl);
  
  % Set data
  a.data  = data_obj;
  
  % set units
  a.data.xaxis.setUnits(find_core(pl, 'xunits'));
  a.data.yaxis.setUnits(find_core(pl, 'yunits'));
  
  if callerIsMethod
    % do nothing
  else
    % Add history
    a.addHistory(ii, pl, [], []);
  end
    
  % Set the object properties from the plist
  a.setObjectProperties(pl, {'fs', 't0', 'toffset', 'xunits', 'yunits'});
  
end

