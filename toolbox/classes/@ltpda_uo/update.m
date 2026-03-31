% UPDATE Updates the given object in an LTPDA repository
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Update an LTPDA object in the repository with the given
% replacement object. The replacement object should be of the same kind of
% the object that will be updated.
%
% CALL:        update(OBJ, ID, PL)
%
% INPUTS:      OBJ   - replacement object
%              ID    - repository ID of the object to update
%              PL    - plist whih submission and repository informations
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uo', 'update')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = update(varargin)

  % check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  % collect all AOs
  obj   = utils.helper.collect_objects(varargin(:), '');
  objid = utils.helper.collect_objects(varargin(:), 'double');
  pls   = utils.helper.collect_objects(varargin(:), 'plist');
  sinfo = utils.helper.collect_objects(varargin(:), 'struct');

  % if the object to update is a plist it is possible we collected it along
  % the plist used to supply parameter to the update routine
  if isa(obj, 'plist')
    % identify plists which are only used for the submission process
    mask = false(numel(obj), 1);
    for ii = 1:numel(obj)
      if ~utils.helper.isSubmissionPlist(obj(ii))
        mask(ii) = true;
      end
    end
    obj = obj(mask);
    % keep all the other as parameters plist
    pls = [ pls combine(pls(~mask)) ];
  end

  if isempty(obj)
    error('### please input an LTPDA user object as the first argument');
  end

  if isempty(objid)
    error('### please provide the repository ID for the object which should be updated');
  end

  % combine plists
  dpl = getDefaultPlist();
  pls = applyDefaults(dpl.pset('HOSTNAME', ''), pls);

  % for backwards compatibility convert any user supplied sinfo-structure into a plist
  pls = ltpda_uo.convertSinfo2Plist(pls, sinfo);

  % check if the user wants to update the submission informations
  if changeSinfo(pls)
    sinfo = ltpda_uo.submitDialog(pls);
    if isempty(sinfo)
      [varargout{1}, varargout{2}] = userCanceled();
      return
    end
  else
    sinfo = [];
  end
  
  % decide if to update the transactions table or not
  update_transactions = getappdata(0, 'LTPDA_WRITE_TRANSACTION_TABLE_IN');
  if isempty(update_transactions)
    update_transactions = true;
  end
  
  % database connection
  c = LTPDADatabaseConnectionManager().connect(pls);

  % register cleanup handler to close the database connection
  if isempty(find_core(pls, 'conn'))
    oncleanup = onCleanup(@()c.close());
  end

  % look-up user id
  [username, userid] = utils.repository.getUser(c);

  % author of the data: let's take the username
  author = username;

  % date for the transaction.transdata and objmeta.submitted columns as UTC time string
  t     = time();
  tdate = format(t, 'yyyy-mm-dd HH:MM:SS', 'UTC');

  % machine details
  prov = provenance();

  % start a transaction. either we submit all objects or we roll back all changes
  c.setAutoCommit(false);

  utils.helper.msg(msg.PROC1, 'updating object %d with: %s / %s', objid, class(obj), obj.name);
  
  % Make sure that we are working with a copy of the input object so that
  % we don't modify the original
  obj = copy(obj, 1);

  % format object creation time as UTC time string
  if isa(obj, 'plist')
    % plist-objects stores creation time as millisecs since the epoch
    created = time().format('yyyy-mm-dd HH:MM:SS', 'UTC');
  else
    created = obj.created.format('yyyy-mm-dd HH:MM:SS', 'UTC');
  end

  % Set the UUID if it is empty. This should only happen for PLIST objects
  if isempty(obj.UUID)
    obj.UUID = char(java.util.UUID.randomUUID);
  end

  % create an XML representaion of the object
  if utils.prog.yes2true(pls.find_core('binary'));
    utils.helper.msg(msg.PROC2, 'binary submit');
    otxt = ['binary submit ' datestr(now)];
  else
    utils.helper.msg(msg.PROC2, 'xml submit');
    otxt = utils.prog.obj2xml(obj);
  end

  % create an MD5 hash of the xml representation
  md5hash = utils.prog.hash(otxt, 'MD5');

  % create a binary representaion of the object
  bobj = utils.prog.obj2binary(obj);
  if isempty(bobj)
    error('### failed to obtain a binary representation');
  end

  % update object in objs table
  stmt = c.prepareStatement(...
    'UPDATE objs SET xml=?, hash=?, uuid=? WHERE id=?');
  stmt.setObject(1, otxt);
  stmt.setObject(2, char(md5hash));
  stmt.setObject(3, obj.UUID);
  stmt.setObject(4, objid);
  stmt.executeUpdate();
  stmt.close();

  % update binary
  stmt = c.prepareStatement(...
    'UPDATE bobjs SET mat=? WHERE obj_id=?');
  stmt.setObject(1, bobj);
  stmt.setObject(2, objid);
  stmt.executeUpdate();
  stmt.close();

  % update object meta data
  if isempty(sinfo)
    stmt = c.prepareStatement(...
      [ 'UPDATE objmeta SET obj_type=?, name=?, created=?, version=?, ' ...
        'ip=?, hostname=?, os=?, submitted=?, author=? WHERE obj_id=?' ]);
    stmt.setObject( 1, java.lang.String(class(obj)));
    stmt.setObject( 2, java.lang.String(obj.name));
    stmt.setObject( 3, java.lang.String(created));
    stmt.setObject( 4, java.lang.String(getappdata(0, 'ltpda_version')));
    stmt.setObject( 5, java.lang.String(prov.ip));
    stmt.setObject( 6, java.lang.String(prov.hostname));
    stmt.setObject( 7, java.lang.String(prov.os));
    stmt.setObject( 8, java.lang.String(tdate));
    stmt.setObject( 9, java.lang.String(author));
    stmt.setObject(10, objid);
    stmt.executeUpdate();
      stmt.close();
  else

    % reference IDs are stored in a CSV string
    if ischar(sinfo.reference_ids)
      refids = sinfo.reference_ids;
    else
      refids = utils.prog.csv(sinfo.reference_ids);
    end

    stmt = c.prepareStatement(...
      [ 'UPDATE objmeta SET obj_type=?, name=?, created=?, version=?, ' ...
        'ip=?, hostname=?, os=?, submitted=?, experiment_title=?, experiment_desc=?, ' ...
        'reference_ids=?, additional_comments=?, additional_authors=?, keywords=?, ' ...
        'quantity=?, analysis_desc=?, author=? WHERE obj_id=?' ]);
    stmt.setObject( 1, java.lang.String(class(obj)));
    stmt.setObject( 2, java.lang.String(obj.name));
    stmt.setObject( 3, java.lang.String(created));
    stmt.setObject( 4, java.lang.String(getappdata(0, 'ltpda_version')));
    stmt.setObject( 5, java.lang.String(prov.ip));
    stmt.setObject( 6, java.lang.String(prov.hostname));
    stmt.setObject( 7, java.lang.String(prov.os));
    stmt.setObject( 8, java.lang.String(tdate));
    stmt.setObject( 9, java.lang.String(sinfo.experiment_title));
    stmt.setObject(10, java.lang.String(sinfo.experiment_description));
    stmt.setObject(11, java.lang.String(refids));
    stmt.setObject(12, java.lang.String(sinfo.additional_comments));
    stmt.setObject(13, java.lang.String(sinfo.additional_authors));
    stmt.setObject(14, java.lang.String(sinfo.keywords));
    stmt.setObject(15, java.lang.String(sinfo.quantity));
    stmt.setObject(16, java.lang.String(sinfo.analysis_description));
    stmt.setObject(17, java.lang.String(author));
    stmt.setObject(18, objid);
    stmt.executeUpdate();
    stmt.close();
  end

  % update other meta-data tables
  cols = utils.mysql.execute(c, 'SHOW COLUMNS FROM tsdata');
  if utils.helper.ismember('obj_id',  cols(:,1))
    % the tsdata table contains an obj id column. use the new database schema
    utils.repository.updateObjMetadata(c, obj, objid);
  else
    % otherwise use the old one
    utils.helper.msg(msg.PROC2, 'using back-compatibility code');
    utils.repository.updateObjMetadataV1(c, obj, objid);
  end

  % update transactions table
  if update_transactions
    stmt = c.prepareStatement(...
      'INSERT INTO transactions (obj_id, user_id, transdate, direction) VALUES (?, ?, ?, ?)');
    stmt.setObject(1, objid);
    stmt.setObject(2, userid);
    stmt.setObject(3, java.lang.String(tdate));
    stmt.setObject(4, java.lang.String('in'));
    stmt.execute();
    stmt.close();
  end
  
  % commit the transaction
  c.commit();

end


function result = changeSinfo(pl)
  % checks if a user wants to update the sinfo of an object
  result = ...
    ~isempty(pl.find_core('experiment_title'))       || ...
    ~isempty(pl.find_core('experiment title'))       || ...
    ~isempty(pl.find_core('experiment_description')) || ...
    ~isempty(pl.find_core('experiment description')) || ...
    ~isempty(pl.find_core('analysis_description'))   || ...
    ~isempty(pl.find_core('analysis description'))   || ...
    ~isempty(pl.find_core('quantity'))               || ...
    ~isempty(pl.find_core('keywords'))               || ...
    ~isempty(pl.find_core('reference_ids'))          || ...
    ~isempty(pl.find_core('reference ids'))          || ...
    ~isempty(pl.find_core('additional_comments'))    || ...
    ~isempty(pl.find_core('additional comments'))    || ...
    ~isempty(pl.find_core('additional_authors'))     || ...
    ~isempty(pl.find_core('additional authors'));
end


function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
  ii.setModifier(false);
end


function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function plo = buildplist()

  plo = copy(plist.TO_REPOSITORY_PLIST, 1);

  p = param({'binary', 'Update only binary version of the objects'}, paramValue.FALSE_TRUE);
  plo.append(p);
end

