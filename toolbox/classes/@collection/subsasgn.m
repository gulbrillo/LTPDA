% SUBSASGN overloads the setting behaviour for collection objects.
% 
% The following new behaviour is defined:
% 
%     c = collection('a', ao(1), 'b', ao(2));
% 
%     c.a = ao(3)  - replaces the object referred to by the field name 'a'
%     c.d = ao(4)  - adds the object to the collection and assigns a
%                    fieldname 'd'
% 
% All other behaviour is default MATLAB behaviour.
% 

function varargout = subsasgn(obj, s, val)
  
  % Process the first instance in the 'stack': case where we access the names
  if strcmp(s(1).type, '.')
    if ismember(s.subs, obj.names)
      [varargout{1:nargout}] = obj.setObjectAtIndex(val, find(strcmp(s.subs, obj.names)));
      return
    else
      [varargout{1:nargout}] = obj.addObjects(val, s.subs);
      return
    end
  end
  
  % Process the first instance in the 'stack': case where we index the object
  if strcmp(s(1).type, '()')
    if numel(s) > 1
      for kk = 1:numel(obj)
        [varargout{1:nargout}] = subsasgn(obj(kk), s(2:end), val);
      end
      return
    end
  end
  
  % If we didn't return already, call the built-in MATLAB subsasgn
  if isempty(obj)
    % The buil-in command is:
    %   A = subsasgn(A, S, B);
    % Where 'A' is the input- AND output collection-object.
    % But if we use the command:
    %   c(1) = collection
    % then is 'c' pre-defined as an empty double.
    % In this case tries MATLAB to convert the 'B' (a collection-object)
    % into a double which doesn't work.
    % That means we have to initialise the empty 'A' with an empty
    % collection-object.
    obj = collection.newarray([0 1]);
  end
  [varargout{1:nargout}] = builtin('subsasgn', obj, s, val);
  
end
% END
