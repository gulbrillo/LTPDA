% ISEQUAL overloads the isequal operator for ltpda minfo objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISEQUAL overloads the isequal operator for ltpda minfo objects.
%
%              Two minfo objects are considered equal if the following
%              properties are the same:
%                mname
%                mclass
%                mpackage
%                mcategory
%                children
%
% CALL:        result = isequal(mi1,mi2)
%
% INPUTS:      mi1, mi2 - Input objects
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
  
  % Get potential existing exception list
  exception_list = varargin;
  if ~isempty(varargin) && isa(varargin{1}, 'plist') && isparam(varargin{1}, 'exceptions')
    exception_list = find(varargin{1}, 'exceptions');
    if isempty(exception_list)
      exception_list = cell(0);
    end
    exception_list = cellstr(exception_list);
  end
  
  for objNo = 1:numel(obj1)
    
    % methodInfo.mname
    if ~utils.helper.ismember('mname', exception_list)
      [result, message] = ltpda_obj.isequalMain(obj1(objNo).mname, obj2(objNo).mname, varargin{:});
    end
    
    % methodInfo.mclass
    if ~utils.helper.ismember('mclass', exception_list)
      [result, message] = ltpda_obj.isequalMain(obj1(objNo).mclass, obj2(objNo).mclass, varargin{:});
    end
    
    % methodInfo.mpackage
    if ~utils.helper.ismember('mpackage', exception_list)
      [result, message] = ltpda_obj.isequalMain(obj1(objNo).mpackage, obj2(objNo).mpackage, varargin{:});
    end
    
    % methodInfo.mcategory
    if ~utils.helper.ismember('mcategory', exception_list)
      [result, message] = ltpda_obj.isequalMain(obj1(objNo).mcategory, obj2(objNo).mcategory, varargin{:});
    end
    
    % methodInfo.mcategory
    if ~utils.helper.ismember('children', exception_list)
      if isa(obj1(objNo).children, 'ltpda_obj')
        [result, message] = isequal(obj1(objNo).children, obj2(objNo).children, varargin{:});
      else
        [result, message] = ltpda_obj.isequalMain(obj1(objNo).children, obj2(objNo).children, varargin{:});
      end
    end
    
    % Return if the objects are not the same.
    if ~result, return; end
    
  end
  
end

