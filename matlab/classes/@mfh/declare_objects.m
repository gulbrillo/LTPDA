% DECLARE_OBJECTS declares all constants and sub-functions in the workspace
% of the calling function.
%
% CALL
%             declare_objects(mfh)
%
%
function declare_objects(f)
  
  varname = inputname(1);
  
  % declare constants
  for kk=1:numel(f.constants)
    evalin('caller', sprintf('%s = %s.constObjects{%d};', char(f.constants{kk}), varname, kk));
  end
  
  % declare input functions
  for kk=1:numel(f.subfuncs)
    ff = f.subfuncs(kk);
    evalin('caller', sprintf('%s = %s.subfuncs(%d);', ff.name, varname, kk));
  end
  
end
% END