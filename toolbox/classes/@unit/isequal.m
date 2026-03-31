% ISEQUAL overloads the isequal operator for ltpda unit objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISEQUAL overloads the isequal operator for ltpda unit objects.
%
%              Two units are considered equal if each has the same unit
%              components with the same exponents and prefixes. The order
%              of the units doesn't matter.
%
% CALL:        result = isequal(u1,u2)
%
% INPUTS:      u1, u2     - Input objects
%
% OUTPUTS:     If the two objects are considered equal, result == true,
%              otherwise, result == false.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [result, message] = isequal(obj1, obj2, varargin)
  
  import utils.const.*
  
  message = '';
  result  = true;
  
  % Check class
  if ~strcmp(class(obj1), class(obj2))
    utils.helper.msg(msg.PROC1, 'NOT EQUAL: The objects are not from the same class. [%s] <-> [%s]', class(obj1), class(obj2));
    result = false;
    return
  end
  
  % Check length of obj1 and obj2
  if numel(obj1) ~= numel(obj2)
    utils.helper.msg(msg.PROC1, 'NOT EQUAL: The size of the %s-object''s. [%d] <-> [%d]', class(obj1), numel(obj1), numel(obj2));
    result = false;
    return
  end
  
  for objNo = 1:numel(obj1)
    
    % compare these two units
    result = compare_units(obj1(objNo),obj2(objNo));
    
    % If they are not equal, we simplify and check again
    % - simplify() is expensive, so only do if necessary
    if ~result
      % and make sure we get copies so we don't modify the user's inputs
      c1 = obj1(objNo).simplify();
      c2 = obj2(objNo).simplify();      
      result = compare_units(c1,c2);
    end
    
    if ~result
      return
    end
    
  end
  
end


function result = compare_units(u1,u2)
  
  % simplify the input objects
  matches = false(size(u1.strs));
  
  % same length?
  if numel(u1.strs) ~= numel(u2.strs)
    result = false;
    return
  end
  
  % Check all match
  for oo = 1:numel(u1.strs)
    for ii = 1:numel(u2.strs)
      % Check that the strings and the values are the same
      if strcmp(u1.strs{oo}, u2.strs{ii}) && u1.vals(oo) == u2.vals(ii)
        % Check that the exponent are the same
        % REMARK: It might be that there is a rounding problem. But then
        %         For example: 1/3 - ( 1 - 2/3 ) ~= 0
        %         In this example is the error equal the smalles error of (1/3)
        if u1.exps(oo) == u2.exps(ii) || abs(u1.exps(oo) - u2.exps(ii)) == eps(u1.exps(oo))
          matches(oo) = true;
        end
      end
    end
  end
  
  result = all(matches);
  
end
