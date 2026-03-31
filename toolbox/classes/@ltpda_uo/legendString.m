% LEGENDSTRING returns a string suitable for use in plot legends.
%
% The string returned is based on the name and description of the object.
% The LTPDA preference "Include object description" is respected when
% constructing the string.
%
% CALL:
%        str = obj.legendString();
%

function name = legendString(a)
  
  if numel(a) ~= 1
    error('legendString requires exactly one input object');
  end
  
  name = utils.plottools.label(a.name);
  desc = utils.plottools.label(a.description);
  
  if isempty(name)
    name = 'unknown';
  end
  
  if ~isempty(desc) && LTPDAprefs.includeDescription
    name = utils.prog.cutString(sprintf('%s\n%s', name , desc), 50);
  end
  
end
% END