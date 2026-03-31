% identifyInsideObjs Static method which identify the inside objects and configuration PLISTs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: identifyInsideObjs Static method which identify the inside
%              objects and configuration PLISTs. The input must be a
%              cell-array.
%
% CALL:        [objs, plConfig] = identifyInsideObjs(inputs)
%
% INPUT:       inputs - cell-array, for example varargin
%
% OUTPUTS:     objs:     Objects which should go into the collection
%              plConfig: Configuration PLIST.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = identifyInsideObjs(varargin)
  
  plConfig = plist();
  objs  = {};
  namesFound = {};
  
  % Loop over all inputs
  for oo = 1:nargin
    
    obj = varargin{oo};
    
    if isa(obj, 'plist')
      % PLISTS with the key 'ignore' and the value true are NO configuration
      % PLISTS
      for ii = 1:numel(obj)
        if shouldIgnore(obj(ii))
          %%% This is not a configuration PLIST. Put it to the inside objects.
          objs = [objs, {obj(ii)}];
        else
          %%% This is a configuration PLIST.
          objsInPlist = obj(ii).find_core('objs');
          
          if ~isempty(objsInPlist)
            % Found objects for the collection inside the PLIST. Add this
            % objects to the collection objects.
            
            if iscell(objsInPlist)
              for pp=1:numel(objsInPlist)
                objs = [objs, reshape(num2cell(objsInPlist{pp}), 1, [])];
              end
            else
              % NOTE: num2cell is not the same as {...} - each object in
              % the input plist 'objs' value should go into its own cell of
              % the output.
              objs = [objs, num2cell(reshape(objsInPlist, 1, []))];
            end
            
          end
          
          names = obj(ii).find_core('names');
          if ~isempty(names)
            % add the names
            namesFound = [namesFound names];
          end
          
          plConfig = combine(obj(ii), plConfig);
        end
        
      end
    elseif isa(obj, 'ltpda_uo')
      if numel(obj) == 1
        objs = [objs, {obj}];
      else
        % This workaround shouldn't be necessary anymore. Because the
        % mfh class (the reason why we have created this workaround)
        % evaluates a bracket command (e.g. f(9)) only if the object is a
        % single mfh object.
        % That means indexing of an array of mfh-objects works.
        c = cell(1, numel(obj));
        s.type = '()';
        s.subs = {1};
        for i=1:numel(obj)
          s.subs = {i};
          c{i} = builtin('subsref', obj, s);
        end
        objs = [objs, c];
      end
    elseif iscell(obj)
      [cellObjs, cellPl] = collection.identifyInsideObjs(obj{:});
      objs = [objs, cellObjs];
      namesFound = [namesFound cellPl.find_core('names')];
    elseif ischar(obj)
      namesFound = [namesFound {obj}];
    else
      error('Unsupported input of type %s', class(obj));
    end
    
  end % for
  
  if ~isempty(namesFound) && numel(namesFound) ~= numel(objs)
    error('Please specify one name per input object');
  end
  
  if isempty(namesFound)
    % create a new name for each object
    for kk=1:numel(objs)
      namesFound{kk} = sprintf('obj%d', kk);
    end
  end
  
  % Remove the key 'objs' from the configuration PLIST
  if plConfig.isparam_core('objs')
    plConfig.remove('objs');
  end
  
  % set the names in the configuration plist
  plConfig.pset('names', namesFound);
  
  if nargout > 0
    varargout{1} = objs;
  end
  if nargout > 1
    varargout{2} = plConfig;
  end
  
end






