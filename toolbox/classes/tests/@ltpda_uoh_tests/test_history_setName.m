% Tests on the history field when doing an operation like setName.
function res = test_history_setName(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    % empty constructor
    obj = feval(utp.className);
    aName = 'my object';
    obj.setName(aName);
    
    h   = obj.hist;

    % minfo
    ii = h.methodInfo;
    assert(strcmp(ii.mname, 'setName'), 'The method name in methodInfo was not %s', 'setName');
    assert(strcmp(ii.mclass, 'ltpda_uo'), 'The class in methodInfo was not %s', 'ltpda_uo');
    
    % plist
    pl = h.plistUsed;
    assert(strcmp(pl.find('name'), aName), 'The name in plistUsed was not %s', aName);
    
    res = sprintf('%s history works when calling setName', class(obj));
  end
    
end