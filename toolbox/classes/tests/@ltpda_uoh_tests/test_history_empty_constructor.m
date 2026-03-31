% Tests on the history field.
function res = test_history_empty_constructor(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    % empty constructor
    obj = feval(utp.className);
    h   = obj.hist;
    assert(isa(h, 'history'));
    assert(isempty(h.inhists));
    assert(isempty(h.methodInvars));
    assert(strcmp(h.objectClass, utp.className));
    assert(~isempty(h.proctime));
    
    % minfo
    ii = h.methodInfo;
    assert(isa(ii, 'minfo'));
    assert(strcmp(ii.mname, utp.className));
    assert(strcmp(ii.mclass, utp.className));
    assert(strcmp(ii.mcategory, 'Constructor'));
    
    % plist
    pl = h.plistUsed;
    assert(isa(pl, 'plist'));
    assert(pl.nparams == 5);
    
    res = sprintf('%s history works', class(obj));
  end
    
end