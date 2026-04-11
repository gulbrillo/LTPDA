% Test the copy() method works for AOs.
function res = test_copy(varargin)
  
  utp = varargin{1};
  
  % Make a complicated test AO
  a = ao(plist('tsfcn', 't', 'fs', 1.3, 'nsecs', 10,...
    'name', 'test ao', ...
    'description', 'description of this ao', ...
    'xunits', 'm', ...
    'yunits', 'N'));
    
  a.setPlotinfo(plotinfo(plist('color', 'r')));
  a.setProcinfo(plist('test', 123));

  utp.testData = a;
  
  % Set the exceptions in the config plist
  utp.configPlist = plist('Exceptions', {'UUID'});

  % Call super
  res = test_copy@ltpda_uoh_tests(utp);
end