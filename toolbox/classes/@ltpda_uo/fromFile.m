% Construct a ltpda_ob from a file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromFile
%
% DESCRIPTION: Construct a ltpda_ob from a file
%
% CALL:        obj = obj.fromFile(filename)
%              obj = obj.fromFile(pl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outObjs = fromFile(obj, pli)
  
  inputClass = class(obj);
  
  % Which file type are we dealing with?
  if ischar(pli) || iscell(pli)
    pli = plist('filename', pli);
  end
  
  outObjs = [];
  
  % Apply defaults to plist
  pli = combine(pli, getDefaultPlist);
  
  % get filename and path
  filenames = cellstr(find_core(pli, 'filename'));
  filenames = cellstr(filenames);
  
  % Check if the filenames have wild cards
  fnames = {};
  for ii = 1:numel(filenames)
    
    if ~isempty(strfind(filenames{ii}, '*'))
      
      % Get path from file
      [filepath, pureFilename, fileExt] = fileparts(filenames{ii});
      pureFilename = strcat(pureFilename, fileExt);
      pureFilename = strrep(pureFilename, '.', '\.');
      
      % Get all Files from the folder
      if ~isempty(filepath)
        f = dir(filepath);
      else
        f = dir();
      end
      fn = {f.name};
      fn = fn(~[f.isdir]);
      
      % Replace the wild cards
      match = regexp(fn, strrep(pureFilename, '*', '.*'), 'match');
      match = match(~cellfun(@isempty, match));
      for mm=1:numel(match)
        % Check that we have found a complete filename
        if any(strcmp(fn, match{mm}))
          % Make sure that we dont add duplicates
          fnames = addFilename(fnames, fullfile(filepath, match{mm}{1}));
        end
      end
      
    else
      % Make sure that we dont add duplicates
      fnames = addFilename(fnames, filenames{ii});
    end
  end
  
  if isempty(fnames)
    error('### Couldn''t find any file with the name %s', utils.helper.val2str(filenames));
  end
  
  for ff=1:numel(fnames)
    filename = fnames{ff};
    % Get the correct parameter set
    [~, name, ext] = fileparts(filename);
    
    % Load a MAT file if the file extension doesn't exist
    if isempty(ext)
      ext = '.mat';
      filename = strcat(filename, ext);
      pli.pset('filename', filename);
    end
    
    % Some display information
    import utils.const.*
    utils.helper.msg(msg.PROC1, 'load file: %s%s', name, ext);
    
    switch ext
      
      case '.fil'
        objs = obj.fromLISO(pli);
        
      case '.mat'
        % Load MAT-File
        objs = load(filename);
        
        fn = fieldnames(objs);
        
        if (numel(fn) == 1) && (isstruct(objs.(fn{1})))
          % If the read object have only one entry and the this entry is a
          % struct then we assume that the struct is a LTPDA object.
          
          objs = objs.(fn{1});
          
          scl = utils.helper.classFromStruct(objs);
          if isempty(scl)
            if isfield(objs, 'class')
              scl = objs.class;
            else
              error('### The structure does not match any LTPDA object.');
            end
          end
          if ~strcmp(class(obj), scl)
            error('### The structure does not match the chosen LTPDA object constructor. It seems to be a [%s] object.', scl)
          end
          fcn_name   = [class(obj) '.update_struct'];
          try
            % Use a try-catch command because we don't know if the
            % object-structure have the 'hist', 'plistUsed', ... fields
            % And it is easier to use a try-catch command instead to check
            % for all fields.
            struct_ver = sscanf(objs(1).hist.plistUsed.creator.ltpda_version, '%s.%s.%s');
          catch
            struct_ver = '1.0';
          end
          objs = feval(fcn_name, objs, struct_ver);
          objs = feval(class(obj), objs);
          
        elseif (numel(fn) == 1) && (isa(objs.(fn{1}), 'ltpda_obj'))
          % If the read object have only one entry and this entry is a LTPDA
          % object then return this LTPDA object.
          objs = objs.(fn{1});
          
        else
          objs = obj.fromDataInMAT(objs, pli);
        end
        
        % We can only trust objects that are stroed with the same or lower LTPDA
        % version as the current version.
        if ~isempty(objs) && isa(objs(1), 'ltpda_uoh') && ~isempty(objs(1).hist)
          vObj = objs(1).hist.creator.ltpda_version;
          v = ver('LTPDA');
          if utils.helper.ver2num(v.Version) < utils.helper.ver2num(vObj)
            warning('LTPDA:setFromEncodedInfo', '!!! The object was saved with a higher LTPDA version %s than you use. Please update your LTPDA version.', vObj);
            fprintf(2, 'Can you trust the data?\n');
          end
        end
        
      case '.xml'
        root_node = xmlread(filename);
        objs = utils.xml.xmlread(root_node, class(obj));
        
      otherwise
        % we load an ascii file
        if pli.isparam_core('complex_type')
          objs = obj.fromComplexDatafile(pli);
        else
          objs = obj.fromDatafile(pli);
        end
        
    end % SWITCH ext
    
    if isempty(outObjs)
      % We don'T want to reshape the objects if we have only one filename
      outObjs = objs;
    else
      outObjs = [reshape(outObjs, 1, []), reshape(objs, 1, [])];
    end
    
  end % FOR
  
  % Check the input class matches the class of the object we just loaded.
  loadedClass = class(objs);
  if ~strcmp(inputClass, loadedClass)
    error('You tried to load objects of class [%s] from %s, but that file contains objects of class [%s]', inputClass, filename, loadedClass);
  end
  
end

function fnames = addFilename(fnames, filename)
  % Don't add duplicates
  % The MATLAB method unique is not so nice because this method sorts the
  % result.
  if ~any(strcmp(fnames, filename))
    fnames = [fnames {filename}];
  end
  
end

function pl = getDefaultPlist()
  
  pl = plist();
  
  % filename, filenames
  p = param({'filename', 'The name of the file'}, paramValue.STRING_VALUE(''));
  p.addAlternativeKey('filenames');
  pl.append(p);
  
end
