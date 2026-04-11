% ISEQUAL overloads the isequal operator for ltpda plotinfo objects.
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

function [result, outMessage] = isequal(obj1, obj2, varargin)
  
  import utils.const.*
  
  outMessage = 'Check the property ''plotinfo''';
  
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
    
    % compare these plotinfos
    
    % linestyle
    result = strcmp(char(obj1(objNo).style.getLinestyle), char(obj2(objNo).style.getLinestyle));
    if ~result
      utils.helper.msg(msg.PROC1, 'NOT EQUAL: The linestyles of the two plotinfo objects are different');
      return
    end
    
    % linewidth
    result = double(obj1(objNo).style.getLinewidth) == double(obj2(objNo).style.getLinewidth);
    if ~result
      utils.helper.msg(msg.PROC1, 'NOT EQUAL: The linewidths of the two plotinfo objects are different');
      return
    end
    
    % color
    result = isequal(double(obj1(objNo).style.getMATLABColor), double(obj2(objNo).style.getMATLABColor));
    if ~result
      utils.helper.msg(msg.PROC1, 'NOT EQUAL: The colors of the two plotinfo objects are different');
      return
    end
    
    % marker
    result = strcmp(char(obj1(objNo).style.getMarker), char(obj2(objNo).style.getMarker));
    if ~result
      utils.helper.msg(msg.PROC1, 'NOT EQUAL: The markers of the two plotinfo objects are different');
      return
    end
    
    % marker size
    result = double(obj1(objNo).style.getMarkersize) == double(obj2(objNo).style.getMarkersize);
    if ~result
      utils.helper.msg(msg.PROC1, 'NOT EQUAL: The marker sizes of the two plotinfo objects are different');
      return
    end
    
    % includeInLegend
    result = obj1(objNo).includeInLegend == obj2(objNo).includeInLegend;
    if ~result
      utils.helper.msg(msg.PROC1, 'NOT EQUAL: The includeInLegend flag of the two plotinfo objects is different');
      return
    end
    
    % showErrors
    result = obj1(objNo).showErrors == obj2(objNo).showErrors;
    if ~result
      utils.helper.msg(msg.PROC1, 'NOT EQUAL: The showErrors flag of the two plotinfo objects is different');
      return
    end
    
  end
  
end

