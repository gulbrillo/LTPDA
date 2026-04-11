% GETPORTSATINDICES get all ports at the given indices.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETPORTSATINDICES get all ports at the given indices.
%
% CALL:            ports = getPort(ssmblocks, indices)
%                  ports = getPort(ssmblocks, plist('indices', someIndices))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getPortsAtIndices(varargin)
  error('This function is deprecated and will be deleted')
  
  [objs, in_vars, rest] = utils.helper.collect_objects(varargin(:), 'ssmblock');
  [pl, in_vars, rest] = utils.helper.collect_objects(rest, 'plist');
  
  ports   = [];
  indices = [];
  
  if isa(pl, 'plist')
    indices = pl.find('indices');
  end
  for kk=1:numel(rest)
    if isnumeric(rest{kk})
      indices = rest{kk};
    end
  end
  
  for kk=1:numel(objs)
    ports   = [ports objs(kk).ports(indices(indices<=numel(objs(kk).ports)))];
  end
  
  varargout{1} = ports;
  
end
