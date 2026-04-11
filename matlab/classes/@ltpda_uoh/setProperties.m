% SETPROPERTIES set different properties of an object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: set different properties of an object. It is possible to define
%              the property/value pairs in a plist or direct as the input.
%
% CALL:        obj = setProperties(obj, 'prop1', val1, 'prop2', val2);
%              obj = setProperties(obj, pl);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = setProperties(varargin)
  
  % Collect all user objects with history
  [objs, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ltpda_uoh');
  [pl,   pl_invars, rest] = utils.helper.collect_objects(rest(:), 'plist');
  
  if numel(pl) > 0 && numel(rest) > 0
    error('### I Don''t know what do do. If a parameter should contain a plist then specify the property and the value in a plist');
  end
  
  % Decide on a deep copy or a modify
  objs = copy(objs, nargout);
  
  % Combine the rest of the inputs to the plist
  while length(rest) >= 2
    prop = upper(rest{1});
    val  =       rest{2};
    rest = rest(3:end);
    
    if ischar(prop)
      pl = combine(plist(prop, val), pl);
    else
      error('### The input property must be a char but it is a [%s] object', class(prop));
    end
  end
  
  for ii = 1:numel(objs)
    
    obj_class = class(objs(ii));
    mthds = methods(obj_class);
    
    for jj = 1:pl.nparams
      
      cmd = ['set' pl.params(jj).key(1) lower(pl.params(jj).key(2:end))];
      
      % Special case for the timespan class because the set methos for the
      % 'startT' and 'endT' properties ends with a capital letter
      if isa(objs, 'timespan') && ...
          (strcmpi(pl.params(jj).key, 'endT')   ||...
          strcmpi(pl.params(jj).key, 'startT'))
        cmd(end) = 'T';
      end
      
      if utils.helper.ismember(cmd, mthds)
        %%%%%%%%%%   It exists a set method to set the property   %%%%%%%%%%
        try
          if iscell(pl.params(jj).getVal) && length(pl.params(jj).getVal) == length(objs)
            %%% Set the value in the cell
            feval(cmd, objs(ii), pl.params(jj).getVal{ii});
            %%% Reset the value in the plistUset to this single value
            objs(ii).hist.plistUsed.pset(pl.params(jj).key, pl.params(jj).getVal{ii});
          else
            %%% Set the value
            feval(cmd, objs(ii), pl.params(jj).getVal);
          end
          %%% Deprecation warning
          warning('!!! Setting property ''%s'' which is not in the default plist is now deprecated and will be removed in future versions. Please use dedicated setter methods', ...
            pl.params(jj).key);
        catch ME
          fprintf(2, '%s\n\n', ME.message);
          warning(utils.const.warnings.METHOD_NOT_FOUND, '!!! Can not set the the property [%s] because the setter-method fails.', lower(pl.params(jj).key));
        end
      elseif objs(ii).isprop(lower(pl.params(jj).key))
        warning(utils.const.warnings.METHOD_NOT_FOUND, '!!! The Object has the property [%s] but there doesn''t exist a public set method', lower(pl.params(jj).key));
      end
      
    end % End loop over params
    
  end % for-loop over all objects
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, objs);
  
end
