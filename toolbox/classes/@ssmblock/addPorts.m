% ADDPORTS adds the given ssm ports to the list of ports.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ADDPORTS adds the given ssm ports to the list of ports.
%
% The given ports are added to the list of ports. No check is done to ensure
% the ports remain unique. Instead you should check with
% ssmblock.containsPort before adding the ports.
%
% CALL:            block = addPorts(ssmblocks, ports)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = addPorts(varargin)
  warning('This function is outdated and will be deleted')
  [blocks, invars, rest] = utils.helper.collect_objects(varargin(:), 'ssmblock');
  ports = utils.helper.collect_objects(rest, 'ssmport');
  
  % copy or modify
  outblocks = copy(blocks, nargout);
  
  % loop over blocks
  for kk=1:numel(blocks)
    block = blocks(kk);
    block.ports = [block.ports copy(ports,1)];
  end
  
  if nargout > 0
    varargout{1} = outblocks;
  end
end
