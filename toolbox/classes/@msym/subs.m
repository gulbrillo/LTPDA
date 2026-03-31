% SUBS Symbolic substitution.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:  SUBS(S, PARAMS, VALS) replaces all the variables PARAMS in
%               the symbolic expression S with values VALS.
%
% CALL:        obj = subs(obj, params, vals)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function o = subs(o, params, vals)
  if ischar(params)
    params = {params};
  end
  if isnumeric(vals)
    vals = {vals};
  end
  if numel(vals) ~= numel(params)
    error('### Please specify one value per parameter');
  end
  for kk=1:numel(params)
    o.s = regexprep(o.s, ['\<' params{kk} '\>'], mat2str(vals{kk}));
  end
end
