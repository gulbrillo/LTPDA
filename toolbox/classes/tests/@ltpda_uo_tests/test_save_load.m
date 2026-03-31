% Test the save and load methods work.
function res = test_save_load(varargin)
  
  res = '';
  utp = varargin{1};
  
  if ~isempty(utp.className)
    % Test object
    obj = utp.getTestData;
    % Test MAT
    fname = [tempname '.mat'];
    save(obj, fname);
    new = feval(utp.className, fname);
    delete(fname);
    assert(isequal(new, obj));
    % Test XML
    fname = [tempname '.xml'];
    save(obj, fname);
    new = feval(utp.className, fname);
    delete(fname);
    assert(isequal(new, obj));
    res = sprintf('Saving and loading objects of class %s works', class(obj));    
  end
    
end
