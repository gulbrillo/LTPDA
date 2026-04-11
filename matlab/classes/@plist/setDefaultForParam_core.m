function setDefaultForParam_core(pl, key, option)
  
    if isa(option, 'paramValue')
      option = option.getVal;
    end
    
    idx = matchKeys_core(pl, key);
    pl.params(idx).setDefaultOption(option);
  
end