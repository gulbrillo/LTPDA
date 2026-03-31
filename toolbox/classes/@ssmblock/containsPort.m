% CONTAINSPORT returns true if the inputs block(s) contain the given port.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CONTAINSPORT returns true if the inputs block(s) contain
% contain the given port.
%
% CALL:            results = containsPort(ssmblocks, portname)
%                  results = containsPort(ssmblocks, portobject)
%                  results = containsPort(ssmblocks, plist('port', portname))
%                  results = containsPort(ssmblocks, plist('port', portobject))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = containsPort(varargin)
  error('This function is deprecated and will be deleted')

  [blocks, invars, rest] = utils.helper.collect_objects(varargin(:), 'ssmblock');
  [port, invars, rest] = utils.helper.collect_objects(rest, 'ssmport');
  [pl, invars, rest] = utils.helper.collect_objects(rest, 'plist');
  
  results = [];
  
  % the port name to check for
  pfind = '';
  
  % port in plist
  if isa(pl, 'plist')
    pfind = pl.find('port');
    if isa(pfind, 'ssmport')
      pfind = pfind.name;
    end
  end
  
  % port in input args overides plist
  if isa(port, 'ssmport')
    pfind = port.name;
  end
  
  % check for a port name in the 'rest' - overides plist and port object
  for kk=1:numel(rest)
    if ischar(rest{kk})
      pfind = rest{kk};
    end
  end
  
  % loop over blocks
  for kk=1:numel(blocks)
    results(kk) = false;
    block = blocks(kk);
    for ll=1:numel(block.ports)
      bp = block.ports(ll);
      % check this port
      if strcmpi(bp.name, pfind)
        results(kk) = true;
      end
    end
  end
  
  varargout{1} = results;
end
