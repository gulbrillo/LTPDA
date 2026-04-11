% FROMPARAMETER Construct an ao from a param object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromParameter
%
% DESCRIPTION: Construct an ao from a param object
%
% CALL:        a = fromParameter(a, pl)
%
% PARAMETER:   pl: Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = fromParameter(a, pli)
  
  % get AO info
  ii = ao.getInfo('ao', 'From Parameter');
  
  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  % Don't use find because that collapses our param value to a double.
  pin = getParamValueForParam(pl, 'parameter');
  
  desc = '';
  
  switch class(pin)
    case 'plist'
      key = find_core(pl, 'key');
      if isempty(key)
        error('When inputting a plist, the required key should be specified');
      end
      
      pidx = pin.getIndexForKey(key);
      if isempty(pidx)
        error('The specified key [%s] was not found', upper(key));
      end
      p = pin.params(pidx);
      name = p.key;
      pval = p.val;
      desc = p.desc;
      
    case 'param'
      
      name = pin.key;
      pval = pin.val;
      desc = pin.desc;
      
    case 'paramValue'
      
      name = find_core(pl, 'name');
      pval = pin;
      
    case 'char'
      
      try
        pl_model = plist(plist('built-in', pin));
      catch Me
        pl_model_list = plist.getBuiltInModels();
        if any(strcmp(pl_model_list(:,1), pin))
          rethrow(Me);
        else
          error('The input name ''%s'' is not a supported built-in model', pin);
        end
      end

      key = find_core(pl, 'key');
      if isempty(key)
        error('When inputting a plist, the required key should be specified');
      end
      
      pidx = pl_model.getIndexForKey(key);
      if isempty(pidx)
        error('The specified key [%s] was not found in the built-in model [%s]', key, pin);
      end
      p = pl_model.params(pidx);
      name = p.key;
      pval = p.val;
      desc = p.desc;
      
    otherwise
      error('The input parameter class is not supported [%s]', class(pin));
      
  end
  
  
  yunits = '';
  dy = [];
  props = [];
  switch class(pval)
    case 'double'
      dval = pval;
    case 'paramValue'
      dval = pval.getVal;
      
      % do we have other properties?
      propnames = fieldnames(pval.property);
      if ismember('unit', propnames)
        yunits = pval.getProperty('unit');
      end
      if ismember('units', propnames)
        yunits = pval.getProperty('units');
      end
      if ismember('error', propnames)
        dy = pval.getProperty('error') * dval;
      end
      if ismember('dy', propnames)
        dy = pval.getProperty('dy');
      end
      props = pval.property;
      
    otherwise
      error('Unsupported value class [%s] for key %s', class(pval), name);
  end
  
  data = cdata(dval);
  data.setYunits(yunits);
  data.setDy(dy);
  a.setName(name);
  a.setDescription(desc);
  a.data = data;
  a.setProcinfo(plist('properties', props));
  
  % Add history
  a.addHistory(ii, pl, [], []);
  
end

