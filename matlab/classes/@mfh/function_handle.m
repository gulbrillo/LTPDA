% FUNCTION_HANDLE returns a MATLAB function handle version of the function.
% 
% CALL
%             fh = function_handle(mfh)
% 
% 
function s = function_handle(f)
  s = '@(';
  nInputs = numel(f.inputs);
  for kk=1:nInputs
    s = [s f.inputs{kk}];
    if kk < nInputs
      s = [s ','];
    end
  end
  
  s = [s ')'];
  s = [s '(' f.func ')'];
  
  % declare input functions
  for kk=1:numel(f.subfuncs)
    ff = f.subfuncs(kk);
    s = strrep(s, sprintf('%s', ff.name), sprintf('%s.eval', ff.name));
  end
end
% END