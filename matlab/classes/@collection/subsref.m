% SUBSREF overloads the referencing behaviour for collection objects.
% 
% The following new behaviour is defined:
% 
%     c = collection('a', ao(1), 'b', ao(2));
% 
%     a = c.a;  - returns the object referred to by the field name 'a'
% 
% All other behaviour is default MATLAB behaviour.
% 

function varargout = subsref(obj, stct)
  
  % Process the first instance in the 'stack': case where we access the names
  if strcmp(stct(1).type, '.')
    use_built_in = true;
    out = {};
    for kk = 1:numel(obj)
      if ismember(stct(1).subs, obj(kk).names)
        if nargout
          out = [out {obj(kk).getObjectAtIndex(find(strcmp(stct(1).subs, obj(kk).names)))}];
        else
          out = [out {obj(kk).objs{find(strcmp(stct(1).subs, obj(kk).names))}}];
        end
        use_built_in = false;
      end
    end
    
    % Process the following instances in the 'stack'
    if numel(stct) > 1
      if ~isempty(out)
        if nargout == 0
          for kk=1:numel(out)
            disp(out{kk});
          end
        else
          [varargout{1:nargout}] = subsref(out{:}, stct(2:end));
          return
        end
      end
      
    else
      if ~use_built_in
        if nargout == 0
          for kk=1:numel(out)
            disp(out{kk});
          end
        else
          [varargout{1:nargout}] = out{1:nargout};
        end
        return
      end
    end
  end
  
  % if we didn't return already, call the built-in MATLAB subsref
  % WARNING: this usage of varargout is essential. DO NOT CHANGE IT.
  
  % Try to forward the input variable name to the next method.
  % For example:
  %   out = c.split(pl);
  %
  % The following commands try to forward 'c' to the split method and not 'obj'
  [varargout{1:nargout}] = builtin('subsref', obj, stct);
  
end


