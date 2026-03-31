function ao_class_test()
  
  % AO_CLASS_TEST Test analysis object class
  %
  % M Hewitson 01-02-07
  %
  % $Id$
  %
  
  %% Constructor 1
  a = ao()
  
  %% Constructor 2 - cdata
  
  a = ao(1)
  
  %% Constructor 3 - time-series data
  
  a = ao(1:10,1);
  
  close all
end


