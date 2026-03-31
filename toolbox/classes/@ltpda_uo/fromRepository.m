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
function [objs, plhout, ii] = fromRepository(obj, pli)

  requested_class = class(obj);

  % get object info
  ii = obj.getInfo(class(obj), 'From Repository');

  % Add default values
  pl = applyDefaults(ii.plists, pli);
  
  % Get parameters
  ids      = find_core(pl, 'id');
  cids     = find_core(pl, 'cid');
  uuids    = find_core(pl, 'uuid');
  bin      = find_core(pl, 'binary');

  % Make sure that 'ids' or 'cids' are empty arrays if they are empty.
  % It might be that the GUI return an empty string.
  if isempty(ids)
    ids = [];
  end
  if isempty(cids)
    cids = [];
  end

  % Check if some ID is defined
  if isempty(ids) && isempty(cids) && isempty(uuids)
    error('### Please define at least one object ID, connection ID or UUID');
  end

  % check if using binary download
  bin = utils.prog.yes2true(bin);

  % database connection
  conn = LTPDADatabaseConnectionManager().connect(pl);

  % register cleanup handler to close the database connection
  if isempty(find_core(pl, 'conn'))
    oncleanup = onCleanup(@()conn.close());
  end
  
  % Get IDs from the collection IDs (CID)
  if ~isempty(cids)
    for kk = 1:numel(cids)
      cid = cids(kk);
      % get the ids from the cid
      ids = [ids utils.repository.getCollectionIDs(conn, cid)];
    end
  end
  
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

  objs = [];
  plhout = [];

  % don't retrieve the same object more than once.
  ids = unique(ids);
  
  for kk = 1:length(ids)

    %---- copy the input plist because each object should get an other plist
    plh = copy(pli, 1);

    %---- This id
    id = ids(kk);
    utils.helper.msg(utils.const.msg.OPROC2, 'retrieving ID %d', id);

    %---- call database constructor
    if bin
      obj = ltpda_uo.retrieve(conn, 'binary', id);
    else
      obj = ltpda_uo.retrieve(conn, id);
    end

    if ~strcmp(class(obj), requested_class)
      error(['### the constructor for class ''%s'' has been used ' ...
             'but object %d is of class ''%s'''], requested_class, id, class(obj));
    end

    %---- Set connection parameters in the plist
    utils.repository.adjustPlist(conn, plh);

    %---- Set only the ID of the current object to the plist
    plh.pset('id', id);

    %---- Add history-plist to output array
    plhout = [plhout plh];

    %---- Add to output array
    objs = [objs obj];

  end

end
