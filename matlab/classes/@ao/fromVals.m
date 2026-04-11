% FROMVALS Construct an ao from a value set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromVals
%
% DESCRIPTION: Construct an ao from a value set
%
% CALL:        a = fromVals(a, pli, callerIsMethod)
%
% PARAMETERS:
%         N:    Number of copies of the object to produce
%         vals: Constant values
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = fromVals(a, pli, callerIsMethod)
  
  % override this because otherwise we risk no having history in objects.
  % We need to think more about how to do this more optimally.
  callerIsMethod = false;
  
  if callerIsMethod
    % do nothing
  else
    % get AO info
    ii = ao.getInfo('ao', 'From Values');
  end
  
  % Combine input plist with default values
  if callerIsMethod
    pl        = pli;
    N = 1;
  else
    % Combine input plist with default values
    % TODO: the parse step should be removed and included somehow into plist/applyDefaults
    pl = applyDefaults(ii.plists, pli);
    % Get values from the plist
    N = find_core(pl, 'N');
  end
  
  
  vals = find_core(pl, 'vals');
  
  % Create an AO with cdata if no value is set
  if isempty(vals)
    vals = 0;
  end
  
  % Check if we have an AO here, in which case we look for the axis key  
  if isa(vals, 'ao')
    axis = pl.find_core('axis');
    switch lower(axis)
      case 'x'
        vals = [vals.x];
      case 'y'
        vals = [vals.y];
      case 'z'
        vals = [vals.z];
      otherwise
        error('Unsupported axis [%s]', axis);
    end      
  end
  
  % Set data
  if N == 1
    a.data = cdata(vals);
  else
    a.data = cdata(repmat(vals, 1, N));
  end
  
  if callerIsMethod
    % do nothing
  else
    % Add history
    a.addHistory(ii, pl, [], []);
  end
  
  % Set errors from plist
  a.data.setErrorsFromPlist(pl);
  
  % Set yunits
  a.data.setYunits(pl.find_core('yunits'));
  
  % Set any remaining object properties which exist in the default plist
  a.setObjectProperties(pl, {'yunits'});
  
end

