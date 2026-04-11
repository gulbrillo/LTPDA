% GETPORTSWITHNAME get all ports with the matching name.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETPORTSWITHNAME get all ports with the matching name.
%
% CALL:            ports = getPortsWithName(ssmblocks, name)
%       [ports, indices] = getPortsWithName(ssmblocks, plist('name', aName))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getPortsWithName(varargin)
  error('This function is deprecated and will be deleted')
  
  [objs, in_vars, rest] = utils.helper.collect_objects(varargin(:), 'ssmblock');
  [pl, in_vars, rest] = utils.helper.collect_objects(rest, 'plist');
  
  ports   = [];
  indices = {};
  
  
  if isa(pl, 'plist')
    name = pl.find('name');
  end
  for kk=1:numel(rest)
    if ischar(rest{kk})
      name = rest{kk};
    end
  end
  
  for kk=1:numel(objs)
    idx = strcmpi(name, {objs(kk).ports.name});
    ports   = [ports objs(kk).ports(idx)];
    indices = [indices {find(idx)}];
  end
  
  if nargout == 1
    varargout{1} = ports;
  elseif nargout == 2
    varargout{1} = ports;
    varargout{2} = indices;
  end
  
end
