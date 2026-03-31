% Test the save and load methods work for the AO class.
function res = test_save_load(varargin)

  utp = varargin{1};
  
  % Make a complicated test AO
  a = ao(plist('tsfcn', 't', 'fs', 1.3, 'nsecs', 10,...
    'name', 'test ao', ...
    'description', 'description of this ao', ...
    'xunits', 'm', ...
    'yunits', 'N'));
    
  a.setPlotinfo(plotinfo(plist('color', 'r')));
  a.setProcinfo(plist('test', 123));
  
  % set test data
  utp.testData = a;
  
  % call super
  res = test_save_load@ltpda_uo_tests(utp);
    
end