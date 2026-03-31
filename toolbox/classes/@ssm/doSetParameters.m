% DOSETPARAMETERS Sets the values of the given parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DOSETPARAMETERS Sets the values of the given parameters.
%
% CALL:        obj = obj.setParameters({'key1', ...}, [val1, ...]);
%              obj = obj.setParameters(plist);
%              obj = obj.setParameters('key', val);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sys = doSetParameters(sys, setnames, setvalues)
  Nset = numel(setvalues);
  for jj = 1:Nset
    if ~any(strcmpi(setnames{jj}, sys.params.getKeys))
      warning(['### parameter named ' setnames{jj} ' was not found in system ' sys.name])
    else
      sys.params.pset(setnames{jj}, setvalues(jj));
    end
  end
  
end

