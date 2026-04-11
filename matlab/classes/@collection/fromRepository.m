% Retrieve a ltpda_uo from a repository
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromRepository
%
% DESCRIPTION: Retrieve a ltpda_uo from a repository
%
% CALL:        obj = fromRepository(pl)
%
% PARAMETER:   pl: Parameter list object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function colls = fromRepository(coll, pli)
  
  % get object info
  mi = coll.getInfo(class(coll), 'From Repository');
  
  % Add default values
  pl = applyDefaults(mi.plists, pli);
  
  % Get parameters
  ids      = find_core(pl, 'id');
  uuids    = find_core(pl, 'uuid');
  cids     = find_core(pl, 'cid');
  bin      = find_core(pl, 'binary');
  
  % check if using binary download
  bin = utils.prog.yes2true(bin);
  
  % database connection
  conn = LTPDADatabaseConnectionManager().connect(pl);
  
  % register cleanup handler to close the database connection
  if isempty(find_core(pl, 'conn'))
    oncleanup = onCleanup(@()conn.close());
  end
  
  % New behaviour:
  % - With a collection ID (cid) do we retrieve the collected objects and
  %   put them into a collection object.
  % - With an ID do we assume to retrieve collection objects otherwise we
  %   throw an error
  %
  colls = [];
  
  % Get IDs from the UUIDs
  if ~isempty(uuids)
    uuids = cellstr(uuids);
    for kk = 1:numel(uuids)
      q = 'SELECT objs.ID FROM objs WHERE objs.uuid LIKE ?';
      uuidID = cell2mat(utils.mysql.execute(conn, q, uuids{kk}));
      if numel(uuidID) > 1
        warning('Found more than 1 ID %s for the uuid [%s]. Retrieving the first.', mat2str(uuidID), uuids{kk});
      end
      if numel(uuidID) == 0
        error('Found no ID for the uuid [%s].', uuids{kk});
      end
      
      ids = [ids uuidID(1)];
    end
  end
  
  % don't retrieve the same objects more than once
  [unique_ids, IA, ~] = unique(ids, 'stable');  
  if length(IA) ~= length(ids)
    warning('Some duplicate objects were specified and will not be downloaded multiple times. Duplicate IDs: %s', mat2str(ids(setdiff(1:length(ids), IA))));
  end  
  ids = unique_ids;  
  
  % handle the ID(s)
  for kk = 1:numel(ids)
    
    %---- copy the input plist because each object should get an other plist
    plh = copy(pl, 1);
    
    %---- This id
    id = ids(kk);
    utils.helper.msg(utils.const.msg.OPROC2, 'retrieving ID %d', id);
    
    %---- call database constructor
    if bin
      coll = ltpda_uo.retrieve(conn, 'binary', id);
    else
      coll = ltpda_uo.retrieve(conn, id);
    end
    
    if ~isa(coll, 'collection')
      error('### the constructor for class ''collection'' has been used but object %d is of class ''%s''', id, class(coll));
    end
    
    %---- Set connection parameters in the plist
    utils.repository.adjustPlist(conn, plh);
    
    %---- Set only the ID of the current object to the plist
    plh.pset('id', id);
    
    %---- Add history
    coll.addHistoryWoChangingUUID(mi, plh, {}, coll.hist);
    
    % Set properties from the plist
    coll.setObjectProperties(pli);
    
    %---- Add to output array
    colls = [colls coll];
    
  end
  
  % handle the CID(s)
  for kk = 1:numel(cids)
    
    %---- copy the input plist because each object should get an other plist
    plh = copy(pl, 1);
    
    %---- This id
    cid = cids(kk);
    utils.helper.msg(utils.const.msg.OPROC2, 'retrieving ID %d', cid);
    
    % get the ids from the cid
    ids = utils.repository.getCollectionIDs(conn, cid);
    
    %---- call database constructor
    if bin
      objs = ltpda_uo.retrieve(conn, 'binary', ids);
    else
      objs = ltpda_uo.retrieve(conn, cid);
    end
    
    % Create a collection object from the retrieved objects.
    coll = collection(objs);
    
    %---- Set connection parameters in the plist
    utils.repository.adjustPlist(conn, plh);
    
    %---- Set only the ID of the current object to the plist
    plh.pset('cid', cid);
    
    %---- Add history
    if strcmp(coll.hist.methodInfo.mname, 'collection')
      % I use the coll.hist.inhists here to skip the history
      useHist = coll.hist.inhists;
    else
      useHist = coll.hist;
    end
    coll.addHistoryWoChangingUUID(mi, plh, {}, useHist);
    
    % Set properties from the plist
    coll.setObjectProperties(pli);
    
    %---- Add to output array
    colls = [colls coll];
    
  end
  
end


