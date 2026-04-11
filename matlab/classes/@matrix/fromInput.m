% Construct a matrix object from ltpda_uoh objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromInput
%
% DESCRIPTION: Construct a matrix object from ltpda_uoh objects.
%
% CALL:        matrix = matrix.fromInput(inobjs)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = fromInput(obj, pli, callerIsMethod)
  
  import utils.const.*
  
  if callerIsMethod
    % do nothing
  else
    % get AO info
    ii = matrix.getInfo('matrix', 'From Input');
  end
  
  % Combine input plist with default values
  if callerIsMethod
    pl        = pli;
  else
    % Combine input plist with default values
    pl = applyDefaults(ii.plists, pli);
  end
  
  shape = pl.find_core('shape');
  objs  = pl.find_core('objs');
  
  if iscell(objs)
    [inobjs, ~, rest] = utils.helper.collect_objects(objs(:), '');
    if ~isempty(rest)
      warning('LTPDA:MATRIX', '### The matrix constructor collects only all %s-objects but there are some %s-objects left.', class(inobjs), class(rest{1}));
    end
  else
    inobjs = objs;
  end
  
  % Make sure that wecopy the inside objects
  inobjs = copy(inobjs, 1);
  
  if ~isempty(shape)
    obj.objs = reshape(inobjs, shape);
  else
    obj.objs = inobjs;
  end
  
  if callerIsMethod
    % do less
  else
    pl.pset('shape', size(obj.objs));
    % Remove the input objects from the plist because we add the histories of
    % the input objects to the matrix object.
    pl.remove('objs');
    
    inhists = [];
    if ~isempty(inobjs)
      inhists = [inobjs(:).hist];
    end
    obj.addHistory(matrix.getInfo('matrix', 'None'), pl, [], inhists);
    
    % Set any remaining object properties which exist in the default plist
    obj.setObjectProperties(pl, {'shape', 'objs'});
  end
  
  % clear the history of the inside objects
  clearObjHistories(obj);
  
end
