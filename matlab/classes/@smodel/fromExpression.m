% FROMEXPRESSION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromExpression
%
% DESCRIPTION: Construct an smodel from an expression
%
% CALL:        mdl = fromExpression(a, pl)
%
% PARAMETER:   pl   - plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mdl = fromExpression(mdl, pli)
  
  % get smodel info
  ii = smodel.getInfo('smodel', 'From Expression');
  
  % Combine input plist with default values
  pl = applyDefaults(ii.plists, pli);
  
  % Set fields
  expr   = pl.find_core('expression');
  params = pl.find_core('params');
  vals   = pl.find_core('values');
  xvar   = pl.find_core('xvar');
  xvals  = pl.find_core('xvals');
  
  % Check the contents of vals
  if iscell(vals)
    for ll=1:numel(vals)
      if isa(vals{ll}, 'ao')
        vals{ll} = vals{ll}.y;
      end
    end
  else
    if isa(vals, 'ao')
      vals = {vals.y};
    end
  end
  
  % Set params and default values
  if ~isempty(params)
    mdl.params = params;
    if ~isempty(vals)
      mdl.values = vals;
    end
  end
  
  % Set x-variable
  if ~isempty(xvar)
    mdl.xvar = xvar;
  end
  
  % Set x-values
  if ~isempty(xvals)
    if isa(xvals, 'ao')
      mdl.xvals = xvals.x;
    else
      mdl.xvals = xvals;
    end
  end
  
  % Set expression
  mdl.expr = msym(expr);
  
  % Add history
  mdl.addHistory(ii, pl, [], []);
  
  % Set object properties
  mdl.setObjectProperties(pl, {'params', 'values', 'xvar', 'xvals'});
  
end
