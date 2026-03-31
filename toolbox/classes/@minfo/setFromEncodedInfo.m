function p = setFromEncodedInfo(p, info)
  
  
  info = regexp(info, '#', 'split');
  
  % info{1} is empty
  
  p.mname     = info{2};
  p.mclass    = info{3};
  p.mcategory = info{4};
  p.mversion  = utils.xml.recoverVersionString(info{5});
  
  args = eval(info{6});
  p.argsmin   = args(1);
  p.argsmax   = args(2);
  p.outmin    = args(3);
  p.outmax    = args(4);
  
  
  mod  = info{7};
  p.modifier = strcmpi(mod, 'true');
  
  % info{8}: version dummy. We have to keep it for backwards compatibility.
  
  if numel(info) >= 9
    p.description = info{9};
  end
  
  if numel(info) >= 10
    p.mpackage = info{10};
  end
  
end
