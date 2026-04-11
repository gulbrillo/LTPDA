% ISEQUAL overloads the isequal operator for ltpda param objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISEQUAL overloads the isequal operator for ltpda param objects.
%
%              The order of the parameter objects doesn't matter.
%
% CALL:        result = isequal(u1,u2)
%
% INPUTS:      u1, u2     - Input objects
%
% OUTPUTS:     If the two objects are considered equal, result == true,
%              otherwise, result == false.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = isequal(objs1, objs2, varargin)
  
  % Check if this is a call for parameters
  hh = [{objs1}, {objs2}, varargin];
  if utils.helper.isinfocall(hh{:})
    varargout{1} = ltpda_obj.isequalMain(objs1, objs2, varargin{:});
    return
  end
  
  import utils.const.*
  
  dispMessage = '';
  outMessage  = '';
  
  %%%%% Check class
  if ~strcmp(class(objs1), class(objs2))
    dispMessage = sprintf('NOT EQUAL: The objects are not from the same class. [%s] <-> [%s]', class(objs1), class(objs2));
    varargout = setOutputs(nargout, false, outMessage, dispMessage);
    return
  end
  
  %%%%% Check length of obj1 and obj2
  if ~all(size(objs1) == size(objs2))
    dispMessage = sprintf('NOT EQUAL: The size of the %s-object''s. [%dx%d] <-> [%dx%d]', class(objs1), size(objs1), size(objs2));
    varargout = setOutputs(nargout, false, outMessage, dispMessage);
    return
  end
  
  plin = [];
  exception_list = varargin;
  if ~isempty(varargin) && isa(varargin{1}, 'plist')
    plin = varargin{1};
  end
  
  %%%%% Convert a potential existing plist into a exception
  if ~isempty(plin) && plin.isparam('exceptions')
    exception_list = find(plin, 'exceptions');
    if isempty(exception_list)
      exception_list = cell(0);
    elseif ~iscell(exception_list)
      exception_list = cellstr(exception_list);
    end
  end
  
  result = true;
  field  = '';
  
  for oo = 1:numel(objs1)
    
    found = false;
    for ii = 1:numel(objs2)
      
      if any(strcmp(objs1(oo).defaultKey, objs2(ii).defaultKey))
        allparts = true;
        fields = fieldnames(objs1(oo));
        for ff = 1:numel(fields)
          field = fields{ff};
          
          % skip these fields since we already checked key, and defaultKey
          % is a derived property which we don't want to check.
          if any(strcmp(field, {'key', 'defaultKey', 'origin'}))
            continue;
          end
          
          if ~(any(utils.helper.ismember(field, exception_list)))
            
            %%% Special case for the values
            if strcmp(field, 'val')
              %%% Compare only the current value
              val1 = objs1(oo).getVal();
              val2 = objs2(ii).getVal();
              
              if isa(val1, 'ltpda_obj')
                [result, outMessage] = isequal(val1, val2, varargin{:});
                allparts = allparts && result;
              else
                [result, outMessage] = ltpda_obj.isequalMain(val1, val2, varargin{:});
                allparts = allparts && result;
              end
              
              %%% Check the properties of the paramValue Object
              if or(isa(objs1(oo).val, 'paramValue') && ~isempty(objs1(oo).val.property), isa(objs2(ii).val, 'paramValue') && ~isempty(objs2(ii).val.property))
                try
                  [result, outMessage] = ltpda_obj.isequalMain(objs1(oo).val.property, objs2(ii).val.property, varargin{:});
                  allparts = allparts && result;
                catch
                  % In this case have one param object a property BUT not the other one
                  allparts = false;
                end
              end
              
               if ~allparts
                 if isa(objs1(oo).val, 'paramValue')
                   outMessage = strcat(sprintf('.val.options{%d}', objs1(oo).val.valIndex), outMessage);
                 else
                   outMessage = strcat('.val', outMessage);
                 end
                 break; 
               end
            else
              % All other fields
              [result, outMessage] = ltpda_obj.isequalMain(objs1(oo).(field), objs2(ii).(field), varargin{:});
              allparts = allparts && result;
            end
            
            % This speed up the code because it is not necessary to check the
            % other fields when one already failed.
            if ~allparts, break; end
            
          end % IF exception list
          
          % This speed up the code because it is not necessary to check the
          % other fields when one already failed.
          if ~allparts, break; end
          
        end
        if allparts
          found = true;
        end
      else
        % Just to define the output
        field = 'Key doesn''t exist.';
      end
      
    end % inner-loop (objs2)
    
    if ~found
      dispMessage = display_msg(objs1, oo, sprintf('%s (key:%s)', field, objs1(oo).defaultKey));
      outMessage = strcat(sprintf('(%d)', oo), outMessage);
      varargout = setOutputs(nargout, false, outMessage, dispMessage);
      return
    end
    
  end % outer-loop (objs1)
  
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
