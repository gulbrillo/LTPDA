% ISSUBCLASSOF determines if the one class is a subclass of another
%
% CALL:
%             res = isSubclassOf('class1', 'class2')
%             res = isSubclassOf(metaObject, 'class2');
%             res = isSubclassOf(metaObject1, metaObject2);
%

function res = isSubclassOf(varargin)
  
  if nargin ~= 2
    help(mfilename);
    error('Incorrect inputs');
  end
  
  mo1 = getMetaObject(varargin{1});
  mo2 = getMetaObject(varargin{2});
  
  if isempty(mo1) || isempty(mo2)
    error('### One of the inputs is not a meta class object/name');
  end
  
  res = lt(mo1, mo2);
  
end

function obj = getMetaObject(in)
  if ischar(in)
    obj = meta.class.fromName(in);
  elseif isa(in, 'meta.class')
    obj = in;
  else
    error('Unknown input format for object of class %s', class(in));
  end
end

function res = checkIsSubclass(mo1, mo2)
  
  res = false;
  
  % is the super class a user object subclass?
  if strcmp(mo1.Name, mo2.Name)
    res = true;
  else
    for kk=1:numel(mo1.SuperclassList)
      mo = mo1.SuperclassList(kk);
      
      res = checkIsSubclass(mo, mo2);
      if res
        return;
      else
        % keep searching...
      end
      
    end
  end
end
