function p = setFromEncodedInfo(p, info)
  
  s = regexp(info, '#', 'split');
  
  % info{1} is empty
  p.creator               = s{2};
  p.ip                    = s{3};
  p.hostname              = s{4};
  p.os                    = s{5};
  p.matlab_version        = s{6};
  p.sigproc_version       = s{7};
  p.symbolic_math_version = s{8};
  p.optimization_version  = s{9};
  p.database_version      = s{10};
  p.control_version       = s{11};
  p.ltpda_version         = s{12};
  % s{13}: version dummy. We have to keep it for backwards compatibility.

  % We can only trust objects that are stroed with the same or lower LTPDA
  % version as the current version.
  v = ver('LTPDA');
  if utils.helper.ver2num(v.Version) < utils.helper.ver2num(p.ltpda_version)
    warning('LTPDA:setFromEncodedInfo', '!!! The object was saved with a higher LTPDA version %s than you use. Please update your LTPDA version.', p.ltpda_version);
    fprintf(2, 'Can you trust the data?\n');
  end
  
end
