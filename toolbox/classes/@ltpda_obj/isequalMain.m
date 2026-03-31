% ISEQUALMAIN checks if the inputs objects are equal or not.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISEQUALMAIN checks if the inputs objects are equal or not.
%
%              All fields are checked.
%
% CALL:        result = isequalMain(obj1,obj2)
%              result = isequalMain(obj1,obj2,  exc_list)
%              result = isequalMain(obj1,obj2, 'property1', 'property2')
%              result = isequalMain(obj1,obj2, '<class>/property', '<class>/property')
%
%              With a PLIST
%
%              r = isequalMain(obj1, obj2, plist('Exceptions', {'prop1', 'prop2'}))
%              r = isequalMain(obj1, obj2, plist('Tol', eps(1)))
%              r = isequalMain(obj1, obj2, plist('Exceptions', 'prop', 'Tol', 1e-14))
%
% EXAMPLES:    result = isequalMain(obj1,obj2, 'name', 'created')
%              result = isequalMain(obj1,obj2, '<class>/name')
%
% INPUTS:      obj1, obj2 - Input objects
%              exc_list   - Exception list
%                           List of properties which are not checked.
%
% OUTPUTS:     If the two objects are considered equal, result == true,
%              otherwise, result == false.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'ltpda_obj.isequalMain')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = isequalMain(objs1, objs2, varargin)
  
  % Check if this is a call for parameters
  hh = [{objs1}, {objs2}, varargin];
  if utils.helper.isinfocall(hh{:})
    varargout{1} = getInfo(varargin{1});
    return
  end
  
  import utils.const.*
  
  outMessage  = '';
  dispMessage = '';
  
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
    end
    exception_list = cellstr(exception_list);
  end
  
  result = true;
  
  % For simple data it is not necessary to use a loop
  if isnumeric(objs1)
    %%%%%%%%%%   single, double   %%%%%%%%%%
    %%%%%%%%%%   int8,   uint8    %%%%%%%%%%
    %%%%%%%%%%   int16   uint16   %%%%%%%%%%
    %%%%%%%%%%   int32   uint32   %%%%%%%%%%
    %%%%%%%%%%   int64   uint64   %%%%%%%%%%
    dispMessage = 'NOT EQUAL: Numeric value';
    
    %%%%% Get the tolerance from a potential existing plist
    if ~isempty(plin) && plin.isparam('tol')
      tol = plin.find('tol');
      result = utils.math.isequal(objs1, objs2, tol);
    else
      result = isequaln(objs1, objs2);
    end
    
  elseif islogical(objs1)
    %%%%%%%%%%   boolean   %%%%%%%%%%
    dispMessage = 'NOT EQUAL: Boolean';
    result = utils.math.isequal(objs1, objs2);
    
  elseif ischar(objs1)
    %%%%%%%%%%   string   %%%%%%%%%%
    dispMessage = 'NOT EQUAL: String';
    result = strcmp(objs1, objs2);
    
  elseif iscellstr(objs1)
    %%%%%%%%%%   string   %%%%%%%%%%
    dispMessage = 'NOT EQUAL: Cell-String';
    result = isequal(objs1, objs2);
    
  elseif isa(objs1, 'sym')
    %%%%%%%%%%    symbolic object   %%%%%%%%%%
    dispMessage = 'NOT EQUAL: Symbolic Object';
    result = isequal(objs1, objs2);
    
  elseif isjava(objs1)
    %%%%%%%%%%    java object   %%%%%%%%%%
    dispMessage = 'NOT EQUAL: Java Object';
    result = isequal(objs1, objs2);
    
  else
    % For complex objects it is necessary to loop over the elements
    for nn=1:numel(objs1)
      
      obj1 = objs1(nn);
      obj2 = objs2(nn);
      
      if isa(obj1, 'handle') || isstruct(obj1)
        %%%%%%%%%%   ltpda objects   %%%%%%%%%%
        %%%%%%%%%%     structures    %%%%%%%%%%
        
        if isstruct(obj1)
          fieldsA = fieldnames(obj1);
          fieldsB = fieldnames(obj2);
        else
          mCl   = metaclass(obj1);
          mProp = mCl.PropertyList;
          idxTrans = [mProp.Transient];
          idxPubl  = strcmp({mProp.GetAccess}, 'public');
          idxDep   = [mProp.Dependent];
          idxConst = [mProp.Constant];
          idxAll = ~idxTrans & idxPubl & ~idxDep & ~idxConst;
          allNames = {mProp.Name};
          fieldsA = allNames(idxAll);
          fieldsB = fieldsA;
        end
        
        % These checks are only for structures
        if isstruct(obj1)
          % Check number of the fields
          if numel(fieldsA) ~= numel(fieldsB)
            dispMessage = sprintf('NOT EQUAL: The number of fields of the %s-object''s. [%d] <-> [%d]', class(obj1), numel(obj1), numel(obj2));
            varargout = setOutputs(nargout, false, outMessage, dispMessage);
            return
          end
          % Check that the fieldnames are the same
          if ~all(utils.helper.ismember(fieldsA, fieldsB))
            dispMessage = sprintf('NOT EQUAL: The fieldnames of the %s-object''s. [%s] <-> [%s]', class(obj1), utils.helper.val2str(obj1), utils.helper.val2str(obj2));
            varargout = setOutputs(nargout, false, outMessage, dispMessage);
            return
          end
        end
        
        % Ckeck each property/field
        for pp = 1:numel(fieldsA)
          field = fieldsA{pp};
          
          %%%%% Creates exception list for the current field.
          ck_field = field;
          
          % Special case (for the ao- and history-class):
          % Is the field = 'hist', 'inhists' then add 'history' to the exception list.
          %%%%% For example: {'history', 'ao/history'}
          if utils.helper.ismember(field, {'hist', 'inhists'})
            ck_field = {ck_field, 'history'};
          elseif strcmp(field, 'val')
            ck_field = {ck_field, 'value'};
          end
          
          %%%%% Check field if it is not in the exception list
          if ~(any(utils.helper.ismember(ck_field, exception_list)))
            if isa(obj1.(field), 'ltpda_obj')
              
              if ~isa(obj1.(field), 'ao') && ~isempty(obj1.(field)) && all(size(obj1.(field)) == size(obj2.(field)))
                % This uses the built-in eq() method from the handle class
                % and checks the pointers.
                result = eq(obj1.(field), obj2.(field));
                if result
                  continue
                end
              end
              [result, outMessage] = isequal(obj1.(field), obj2.(field), varargin{:});
            else
              [result, outMessage] = ltpda_obj.isequalMain(obj1.(field), obj2.(field), varargin{:});
            end
            
            if ~result
              dispMessage = display_msg(objs1, nn, field);
              outMessage = strcat(sprintf('(%d).', nn), field, outMessage);
              varargout = setOutputs(nargout, result, outMessage, dispMessage);
              return;
            end
          end
        end % FOR all fields
        
      elseif iscell(obj1)
        %%%%%%%%%%   cell objects   %%%%%%%%%%
        c1 = objs1{nn};
        c2 = objs2{nn};
        if isa(c1, 'ltpda_obj')
          [result, outMessage] = isequal(c1, c2, varargin{:});
        else
          [result, outMessage] = ltpda_obj.isequalMain(c1, c2, varargin{:});
        end
        
        if ~result
          dispMessage = display_msg(objs1, nn, 'cell-object');
          outMessage = strcat(sprintf('{%d}', nn), outMessage);
          varargout = setOutputs(nargout, result, outMessage, dispMessage);
          return
        end
        
      elseif isa(obj1, 'handle') && ismethod(obj1, 'isequal')
        %%%%%%%%%%   non LTPDA objects   %%%%%%%%%%
        [result, outMessage] = isequal(obj1, obj2, varargin{:});
        
        if ~result
          varargout = setOutputs(nargout, result, outMessage, outMessage);
          return
        end
        
      else
        warning('!!! Unknown data type %s', class(obj1));
      end
      
    end % FOR number of objects
    
  end % ELSE complex objects
  
  varargout = setOutputs(nargout, result, outMessage, dispMessage);
  
end % ltpda_obj.isequalMain()

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
    message = sprintf('NOT EQUAL: %s(%d).%s', class(obj(obj_no)), obj_no, field);
  else
    message = sprintf('NOT EQUAL: %s.%s', class(obj(obj_no)), field);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, 'ltpda_obj', 'ltpda', utils.const.categories.relop, '', sets, pl);
  ii.setModifier(false);
  ii.setArgsmin(2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function plo = buildplist()
  plo = plist();
  
  % Exceptions
  p = param({'Exceptions', 'Test the objects without the given property names'}, paramValue.EMPTY_CELL);
  plo.append(p);
  
  % Tolerance
  p = param({'Tol', 'Test double values with the given tolerance'}, paramValue.DOUBLE_VALUE(eps(1)));
  plo.append(p);
  
end

