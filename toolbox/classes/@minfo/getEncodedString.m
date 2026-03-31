
function info = getEncodedString(obj)
  
  % Make some plausibility checks
  if numel(obj) > 1
    error('### It is not possible to encode more than one minfo objects.');
  end
%   if ~isempty(obj.children)
%     error('### It is not possible to encode an minfo object with children.');
%   end
  if ~isempty(obj.sets)
    warning('LTPDA:ENCODE_MINFO', '!!! Can not encode the sets of the minfo object (mname: %s)', obj.mname);
  end
  if ~isempty(obj.plists)
    warning('LTPDA:ENCODE_MINFO', '!!! Can not encode the plists of the minfo object (mname: %s)', obj.mname);
  end
  
  sep  = '#';
  info = '';
  
  info = [info sep obj.mname];
  info = [info sep obj.mclass];
  info = [info sep obj.mcategory];
  info = [info sep utils.xml.prepareVersionString(obj.mversion)];
  
  args = [obj.argsmin obj.argsmax obj.outmin obj.outmax];
  info = [info sep utils.xml.mat2str(args)];
  
  if (obj.modifier) 
    info = [info sep 'true'];
  else
    info = [info sep 'false'];
  end
  info = [info sep 'dummy']; % version dummy. We have to keep it for backwards compatibility.
  
  info = [info sep obj.description];
  
  info = [info sep obj.mpackage];
  
end
