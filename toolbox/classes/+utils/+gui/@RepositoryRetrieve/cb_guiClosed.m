% cb_guiClosed callback for closing the QueryResultsTable GUI
%
% Parameters:
%       first  - QueryResultsTable object
%       second - Source object (here: RepositoryRetrieveDialog)
%       third  - Event Object  (here: WindowEvent)
%

function cb_guiClosed(varargin)
  mainGUI = varargin{1};
  
  if ~isempty(mainGUI) && isvalid(mainGUI)
    
    % Call super class
    cb_guiClosed@utils.gui.BaseGUI(varargin{:});
    
    % Register cleanup handle (Then is it possible to throw errors)
    oncleanup = onCleanup(@()local_cleanup(mainGUI));
    
    % Get object and/or collection IDs from the GUI
    obj_ids = mainGUI.gui.getObjectIDs();
    col_ids = mainGUI.gui.getCollectionIDs();
    
    % Return if the user has canceld the action
    if mainGUI.gui.isCancelled
      return
    end
    
    if isempty(obj_ids) && isempty(col_ids)
      utils.helper.errorDlg('Please enter either a object ID or a collection ID.');
      return
    end
    
    % object prefix
    obj_prefix = char(mainGUI.gui.getObjectPrefix);
    
    % append object type?
    appendObjectType = mainGUI.gui.appendObjectType;
    
    % binary retrieval?
    binaryRetrieval = mainGUI.gui.useBinaryRetrieval;
    
    % file extension
    fileext = mainGUI.gui.getSaveFileExtension;
    
    [objs, obj_names] = retrieveObjects(mainGUI.conn, obj_ids, col_ids, binaryRetrieval, obj_prefix, appendObjectType);
    
    if mainGUI.gui.isSaveObjects
      save_objects(objs, obj_names, fileext);
    else
      import_objects(objs, obj_names);
    end
  end
  
end

function save_objects(objs, obj_names, fileext)
  for j=1:length(objs)
    if isvarname(obj_names{j})
      save(objs{j}, [obj_names{j} char(fileext)]);
    else
      utils.helper.errorDlg('Can not save the object(s) because you used a not valid prefix name.');
    end
  end
end

function import_objects(objs, obj_names)
  for j=1:length(objs)
    if isvarname(obj_names{j})
      assignin('base', obj_names{j}, objs{j});
    else
      utils.helper.errorDlg('Can not import the object(s) because you used a not valid prefix name.');
    end
  end
end

function [objs, obj_names] = retrieveObjects(conn, ids, cids, retrieveBinary, prefix, appendObj)
  
  
  %---------------------------------------------------------------
  % Retrieve these ids
  objs = {};
  obj_names = {};
  for j=1:length(ids)
    disp(sprintf('+ retrieving object %d', ids(j)));
    
    % determine object type
    try
      tt = utils.repository.getObjectType(conn, ids(j));
    catch
      utils.helper.errorDlg('Object type is unknown. Does this object really exist?');
      return
    end
    
    objname = sprintf('%s%03d', prefix, ids(j));
    if appendObj
      objname = [objname '_' tt];
    end
    obj_names = [obj_names {objname}];
    
    % Retrieve object
    pl = plist('id', ids(j), 'conn', conn);
    if retrieveBinary
      pl.append('binary', 'yes');
    end
    obj = eval(sprintf('%s(pl);', tt));
    
    objs = [objs {obj}];
  end
  
  %---------------------------------------------------------------
  % Retrieve these Collections
  for k=1:length(cids)
    
    % get Ids from Cid
    ids = utils.repository.getCollectionIDs(conn, cids(k));
    if isempty(ids)
      error('### This collection doesn''t seem to exist.');
    end
    
    for j=1:length(ids)
      disp(sprintf('+ retrieving collection %d : %d', cids(k), ids(j)));
      tt = utils.repository.getObjectType(conn, ids(j));
      if ismember(tt, utils.helper.ltpda_userclasses)
        % Retrieve object
        pl = plist('id', ids(j), 'conn', conn);
        obj = eval(sprintf('%s(pl);', tt));
        
        objname = sprintf('%sC%03d_%03d', prefix, cids(k), ids(j));
        if appendObj
          objname = [objname '_' tt];
        end
        obj_names = [obj_names {objname}];
        objs = [objs {obj}];
      else
        warning('!!! Objects of type %s are no longer considered user objects and can not be retrieved.', tt);
      end
    end
  end
  
end

function local_cleanup(mainGUI)
  % Remove the connection
  mainGUI.conn = [];
  % Destroy the GUI with the destructor 'delete'
  delete(mainGUI);
end
