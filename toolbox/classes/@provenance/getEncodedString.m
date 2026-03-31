function info = getEncodedString(p)
  
  sep  = '#';
  info = '';
  
  info = [info sep p.creator];
  info = [info sep p.ip];
  info = [info sep p.hostname];
  info = [info sep p.os];
  info = [info sep p.matlab_version];
  info = [info sep p.sigproc_version];
  info = [info sep p.symbolic_math_version];
  info = [info sep p.optimization_version];
  info = [info sep p.database_version];
  info = [info sep p.control_version];
  info = [info sep p.ltpda_version];
  info = [info sep 'dummy']; % version dummy. We have to keep it for backwards compatibility.
  
end
