function res = isparam_core(pls, key)
  
  res = zeros(size(pls));
  
  for ii = 1:numel(pls)
    res(ii) = any(matchKeys_core(pls(ii), key));
  end
  
end