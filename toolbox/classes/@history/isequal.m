% ISEQUAL overloads the isequal operator for ltpda history objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISEQUAL overloads the isequal operator for ltpda history objects.
%
%              Two history objects are considered equal if the following
%              properties are the same:
%                methodInfo.mname
%                methodInfo.mclass
%                methodInfo.mpackage
%                methodInfo.mcategory
%                methodInfo.children
%                plistUsed
%                inhists
%                objectClass
%
% CALL:        result = isequal(h1,h2)
%
% INPUTS:      h1, h2 - Input objects
%
% OUTPUTS:     If the two objects are considered equal, result == true,
%              otherwise, result == false.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = isequal(obj1, obj2, varargin)
  
  import utils.const.*
  
  result      = true;
  dispMessage = '';
  outMessage  = '';
  
  % Get potential existing exception list
  exception_list = varargin;
  if ~isempty(varargin) && isa(varargin{1}, 'plist') && isparam(varargin{1}, 'exceptions')
    exception_list = find(varargin{1}, 'exceptions');
    if isempty(exception_list)
      exception_list = cell(0);
    end
    exception_list = cellstr(exception_list);
  end
  
  % Check if the history class is inside the exception list.
  if any(utils.helper.ismember({'hist', 'inhists', 'history'}, exception_list))
    varargout = setOutputs(nargout, result, outMessage, dispMessage);
    return
  end
  
  % Check class
  if ~strcmp(class(obj1), class(obj2))
    dispMessage = sprintf('NOT EQUAL: The objects are not from the same class. [%s] <-> [%s]', class(obj1), class(obj2));
    varargout = setOutputs(nargout, false, outMessage, dispMessage);
    return
  end
  
  % Check length of obj1 and obj2
  if numel(obj1) ~= numel(obj2)
    dispMessage = sprintf('NOT EQUAL: The size of the %s-object''s. [%dx%d] <-> [%dx%d]', class(obj1), size(obj1), size(obj2));
    varargout = setOutputs(nargout, false, outMessage, dispMessage);
    return
  end
  
  for objNo = 1:numel(obj1)
    
    uniqueHist1 = getAllUniqueHistories(obj1(objNo));
    uniqueHist2 = getAllUniqueHistories(obj2(objNo));
    
    % Check length of obj1 and obj2
    if numel(uniqueHist1) ~= numel(uniqueHist2)
      utils.helper.msg(msg.PROC1, 'NOT EQUAL: The number of unique history nodes are not the same. [%d] <-> [%d]', numel(uniqueHist1), numel(uniqueHist2));
      varargout = setOutputs(nargout, false, outMessage, dispMessage);
      return
    end
    
    for nn = 1:numel(uniqueHist1)
      h1 = uniqueHist1(nn);
      h2 = uniqueHist2(nn);
      
      % methodInfo
      if ~utils.helper.ismember('methodInfo', exception_list)
        if ~isempty(h1.methodInfo)
          [result, outMessage] = isequal(h1.methodInfo, h2.methodInfo, varargin{:});
          if ~result,
            dispMessage = display_msg(h1, nn, 'methodInfo');
            outMessage = strcat(sprintf('(%d).', nn), 'methodInfo', outMessage);
            break;
          end
        end
      end
      
      
      % ATTENTION: Here is it necessary to add the 'history' to the
      %            exception list because we have already collected the
      %            histories inside plistUsed with getAllUniqueHistories.
      %
      % plistUsed
      if ~utils.helper.ismember('plistUsed', exception_list)
        [result, outMessage] = ltpda_obj.isequalMain(h1.plistUsed, h2.plistUsed, 'history', exception_list{:});
        if ~result,
          dispMessage = display_msg(h1, nn, 'plistUsed');
          outMessage = strcat(sprintf('(%d).', nn), 'plistUsed', outMessage);
          break;
        end
      end
      
      % ATTENTION: It is not necessary to check all inhists because they
      %            are already collected by getAllUniqueHistories.
      %
      %  % inhists
      %  if ~utils.helper.ismember('inhists', exception_list)
      %    if ~isempty(h1.inhists)
      %      [result, outMessage] = isequal(h1.inhists, h2.inhists, varargin{:});
      %      if ~result,
      %        dispMessage = display_msg(h1, nn, 'inhists');
      %        outMessage = strcat(sprintf('(%d).', nn), 'inhists', outMessage);
      %        break;
      %      end
      %    end
      %  end
      
      % objectClass
      if ~utils.helper.ismember('objectClass', exception_list)
        [result, outMessage] = ltpda_obj.isequalMain(h1.objectClass, h2.objectClass, varargin{:});
        if ~result,
          dispMessage = display_msg(h1, nn, 'objectClass');
          outMessage = strcat(sprintf('(%d).', nn), 'objectClass', outMessage);
          break;
        end
      end
      
    end % Loop unique histories
    
  end % Loop input objects
  
  varargout = setOutputs(nargout, result, outMessage, dispMessage);
  
end

function out = setOutputs(nout, result, outMessage, dispMessage)
  import utils.const.*
  if ~result
    utils.helper.msg(msg.PROC3, dispMessage);
  end
  
  if nout == 0
    out = {result};
  elseif nout == 1
    out = {result};
  elseif nout == 2
    out = {result, outMessage};
  else
    error('Incorrect outputs for isequal()');
  end
end

function message = display_msg(obj, obj_no, field)
  import utils.const.*
  if numel(obj) > 1
    message = sprintf('NOT EQUAL: %s.%s (%d. object)', class(obj(obj_no)), field, obj_no);
  else
    message = sprintf('NOT EQUAL: %s.%s', class(obj(obj_no)), field);
  end
end

