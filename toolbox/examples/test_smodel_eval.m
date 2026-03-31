% test_smodel_eval tests the eval method of the SMODEL class.
%
% M Hueller 05-05-2011
%
% $Id$
%

function test_smodel_eval
  
  % Build the model
  s1 = smodel(plist('expression', 'a + b1*x1 + b2*x2','xvar',{'x1','x2'}));
  s1.setXvals({[1:100], [2:2:200]});
  s1.setYunits('N');
  s1.setXunits({'m', 'V'});
  s1.setParameters({'a','b1','b2'},{1,2,-3});
  s1.setName('test');
  
  % Eval the model: output x is tsdata ao
  a1 = ao(plist('xvals',[1:100],'yvals',[0.01:.01:1], 'type', 'tsdata', 'fs', 1));
  d1 = s1.eval(plist('output x', a1));
  assert(isequal(class(d1.data), class(a1.data)))
  assert(isequal(d1.yunits, s1.yunits))
  
  % Eval the model: output x is fsdata ao
  a1 = ao(plist('xvals',[1:100],'yvals',[0.01:.01:1], 'type', 'fsdata'));
  d1 = s1.eval(plist('output x', a1));
  assert(isequal(class(d1.data), class(a1.data)))
  assert(isequal(d1.yunits, s1.yunits))
  
  % Eval the model: output x is xydata ao
  a1 = ao(plist('xvals',[1:100],'yvals',[0.01:.01:1], 'type', 'xydata'));
  d1 = s1.eval(plist('output x', a1));
  assert(isequal(class(d1.data), class(a1.data)))
  assert(isequal(d1.yunits, s1.yunits))
  
  % Eval the model: output x is double array, no data type set
  a1 = [2:2:200];
  d1 = s1.eval(plist('output x', a1));
  assert(isequal(class(d1.data), 'tsdata'))
  assert(isequal(d1.yunits, s1.yunits))
  
  % Eval the model: output x is double array, data type set to 'tsdata'
  a1 = [2:2:200];
  d1 = s1.eval(plist('output x', a1, 'output type', 'tsdata'));
  assert(isequal(class(d1.data), 'tsdata'))
  assert(isequal(d1.yunits, s1.yunits))
  
  % Eval the model: output x is double array, data type set to 'fsdata'
  a1 = [2:2:200];
  d1 = s1.eval(plist('output x', a1, 'output type', 'fsdata'));
  assert(isequal(class(d1.data), 'fsdata'))
  assert(isequal(d1.yunits, s1.yunits))
  
  % Eval the model: output x is double array, data type set to 'xydata'
  a1 = [2:2:200];
  d1 = s1.eval(plist('output x', a1, 'output type', 'xydata'));
  assert(isequal(class(d1.data), 'xydata'))
  assert(isequal(d1.yunits, s1.yunits))
  
  % Eval the model: output x is double array, no data type set, output xunits set
  a1 = [2:2:200];
  d1 = s1.eval(plist('output x', a1, 'output xunits', 'ms'));
  assert(isequal(class(d1.data), 'tsdata'))
  assert(isequal(d1.yunits, s1.yunits))
  assert(isequal(d1.xunits, unit('ms')))
  
  % Eval the model: output x is double array, data type set to 'tsdata', output xunits set
  a1 = [2:2:200];
  d1 = s1.eval(plist('output x', a1, 'output type', 'tsdata', 'output xunits', 'ms'));
  assert(isequal(class(d1.data), 'tsdata'))
  assert(isequal(d1.yunits, s1.yunits))
  assert(isequal(d1.xunits, unit('ms')))
  
  % Eval the model: output x is double array, data type set to 'fsdata', output xunits set
  a1 = [2:2:200];
  d1 = s1.eval(plist('output x', a1, 'output type', 'fsdata', 'output xunits', 'ms'));
  assert(isequal(class(d1.data), 'fsdata'))
  assert(isequal(d1.yunits, s1.yunits))
  assert(isequal(d1.xunits, unit('ms')))
  
  % Eval the model: output x is double array, data type set to 'xydata', output xunits set
  a1 = [2:2:200];
  d1 = s1.eval(plist('output x', a1, 'output type', 'xydata', 'output xunits', 'ms'));
  assert(isequal(class(d1.data), 'xydata'))
  assert(isequal(d1.yunits, s1.yunits))
  assert(isequal(d1.xunits, unit('ms')))
  
  % Eval the model: output x is left empty, data type should be ignored and always cdata
  d1 = s1.eval();
  assert(isequal(class(d1.data), 'cdata'))
  assert(isequal(d1.yunits, s1.yunits))
  
  close all
end
