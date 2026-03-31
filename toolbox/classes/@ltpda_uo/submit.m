% SUBMIT Submits the given collection of objects to an LTPDA repository
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Submits the given collection of objects to an LTPDA
%              repository. If multiple objects are submitted together a
%              corresponding collection entry will be made.
%
% If not explicitly disabled the user will be prompt for entering submission
% metadata and for chosing the database where to submit the objects.
%
% CALL:        OUT      = submit(O1, PL)
%              OUT      = submit(O1, O2, PL)
%
% INPUTS:      O1, O2, ... - objects to be submitted
%              PL          - plist whih submission and repository informations
%
% OUTPUTS:     OUT     - a plist object with fields:
%                   IDS         - IDs assigned to the submitted objects
%                   CID         - ID of the collection entry
%                   UUIDS       - UUIDs of the submitted objects
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uo', 'submit')">Parameters Description</a>
%
% METADATA:
%
%   'experiment title'       - title for the submission (required >4 characters)
%   'experiment description' - description of this submission (required >10 characters)
%   'analysis description'   - description of the analysis performed (required >10 characters)
%   'quantity'               - the physical quantity represented by the data
%   'keywords'               - comma-delimited list of keywords
%   'reference ids'          - comma-delimited list object IDs
%   'additional comments'    - additional comments
%   'additional authors'     - additional author names
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Notes on submission
%
% We can check ask the database for a list of allowed modules. This needs a
% new table in the database. Then this list is passed to validate so that
% if the 'validate' plist option (which needs to be added) is set to true,
% then we call validate on the object before submitting. If validate is
% true, then we set the validated flag in the database after submission if
% it passes.
%
%


function varargout = submit(varargin)
  
  % check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % collect all AOs
  [pls, ~, rest] = utils.helper.collect_objects(varargin(:), 'plist');
  [userSinfo, ~, objs] = utils.helper.collect_objects(rest(:), 'struct');
  
  % identify plists which are only used for the submission process
  mask = false(numel(pls), 1);
  for ii = 1:numel(pls)
    if ~utils.helper.isSubmissionPlist(pls(ii))
      mask(ii) = true;
    end
  end
  % add all plist that do not look to contain parameters for the
  % submission to the list of objects submitted to the repository
  if sum(mask)
    objs = [objs, {pls(mask)}];
    pls  = pls(~mask);
  end
  % keep all the other as parameters plist
  if ~isempty(pls)
    pls = combine(pls);
  end
  
  % rearrange nested objects lists into a single cell array
  objs = flatten(objs);
  
  if isempty(objs)
    error('### input at least one object to submit to the repository');
  end
  
  % combine user plist with default
  pls = fixPlist(pls);
  dpl = getDefaultPlist();
  pls = applyDefaults(dpl.pset('HOSTNAME', ''), pls);
  
  % for backwards compatibility convert any user supplied sinfo-structure into a plist
  pls = ltpda_uo.convertSinfo2Plist(pls, userSinfo);
  
  % read XML submission informations file
  filename = pls.find_core('sinfo filename');
  if ~isempty(filename)
    try
      pl = fixPlist(utils.xml.read_sinfo_xml(filename));
      pls = combine(pl, pls);
    catch err
      error('### unable to read specified file: %s', filename);
    end
  end
  
  % collect additional informations
  userSinfo = ltpda_uo.submitDialog(pls);
  if isempty(userSinfo)
    varargout{1} = userCanceled();
    return
  end
  
  % check completeness of user supplied informations
  userSinfo = checkSinfo(userSinfo);
  
  % decide if to update the transactions table or not
  update_transactions = getappdata(0, 'LTPDA_WRITE_TRANSACTION_TABLE_IN');
  if isempty(update_transactions)
    update_transactions = true;
  end
  
  % database connection
  conn = LTPDADatabaseConnectionManager().connect(pls);
  
  % register cleanup handler to close the database connection
  if isempty(find_core(pls, 'conn'))
    oncleanup = onCleanup(@()conn.close());
  end
  
  submit_url = regexp(char(conn.getMetaData().getURL()), 'jdbc:mysql://', 'split');
  submit_string = submit_url{2};
  idx = strfind(submit_string, '/');
  submit_database = submit_string(idx+1:end);
  submit_hostname = submit_string(1:idx-1);
  
  utils.helper.msg(msg.PROC1, 'submitting %d objects to %s', ...
    numel(objs), submit_string);
  
  try
    % get username and userid
    [username, userid] = utils.repository.getUser(conn);
    
    % author of the data: let's take the username
    author = username;
    
    % date for the transaction.transdata and objmeta.submitted columns as UTC time string
    t     = time();
    tdate = format(t, 'yyyy-mm-dd HH:MM:SS', 'UTC');
    
    % machine details
    prov = provenance();
    
    % start a transaction. either we submit all objects or we roll back all changes
    conn.setAutoCommit(false);
    
    % process each object and collect id numbers
    ids = zeros(1, numel(objs));
    cid = [];
    uuids = {};
    
    for kk = 1:numel(objs)
      
      % this object
      obj = objs{kk};
      
      utils.helper.msg(msg.PROC1, 'submitting object: %s / %s', class(obj), obj.name);
      
      % format object creation time as UTC time string
      if isa(obj, 'ltpda_uoh')
        % ltpda_uoh-objects stores creation time as millisecs since the
        % epoch in the history.
        created = obj.created.format('yyyy-mm-dd HH:MM:SS', 'UTC');
      elseif isa(obj, 'ltpda_uo')
        % ltpda_uo-objects doesn't have history so that we store the
        % current time in the database.
        created = time().format('yyyy-mm-dd HH:MM:SS', 'UTC');
      else
        error('Please define the created time for the following object [%s]', class(obj));
      end
      
      % Set the UUID if it is empty. This should only happen for PLIST
      % objects.
      if isempty(obj.UUID)
        obj.UUID = char(java.util.UUID.randomUUID);
      end
      
      % It is necessary to copy the input object to make sure that we
      % dopn't modify the input. Only for the case that the input is
      % a PLIST do we want to change it because PLISTs don't get a UUID
      % when we create them. This new UUID should go also into the original
      % input PLIST.
      obj = copy(obj, 1);
      
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
      
      % submit object to objs table
      stmt = conn.prepareStatement('INSERT INTO objs (xml, hash, uuid) VALUES (?, ?, ?)');
      stmt.setObject(1, otxt);
      stmt.setObject(2, md5hash);
      stmt.setObject(3, obj.UUID);
      stmt.executeUpdate();
      
      % obtain object id
      rs = stmt.getGeneratedKeys();
      if rs.next()
        objid = rs.getInt(1);
      else
        objid = [];
      end
      rs.close();
      stmt.close();
      
      % insert binary representation
      stmt = conn.prepareStatement('INSERT INTO bobjs (obj_id, mat) VALUES (?,?)');
      stmt.setObject(1, objid);
      stmt.setObject(2, bobj);
      stmt.execute();
      stmt.close();
      
      % reference IDs are stored in a CSV string
      if ischar(userSinfo.reference_ids)
        % Do nothing
      else
        userSinfo.reference_ids = utils.prog.csv(userSinfo.reference_ids);
      end
      
      % Modify the submission structure individually for each object.
      % At the moment it is used in the ltpda_uoh- and eo-class.
      sinfo = obj.prepareSinfoForSubmit(userSinfo);
      
      % insert object meta data
      stmt = conn.prepareStatement(...
        [ 'INSERT INTO objmeta (obj_id, obj_type, name, created, version, ' ...
        'ip, hostname, os, submitted, experiment_title, experiment_desc, ' ...
        'reference_ids, additional_comments, additional_authors, keywords, ' ...
        'quantity, analysis_desc, author) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)' ]);
      stmt.setObject( 1, objid);
      stmt.setObject( 2, java.lang.String(class(obj)));
      stmt.setObject( 3, java.lang.String(obj.name));
      stmt.setObject( 4, java.lang.String(created));
      stmt.setObject( 5, java.lang.String(getappdata(0, 'ltpda_version')));
      stmt.setObject( 6, java.lang.String(prov.ip));
      stmt.setObject( 7, java.lang.String(prov.hostname));
      stmt.setObject( 8, java.lang.String(prov.os));
      stmt.setObject( 9, java.lang.String(tdate));
      stmt.setObject(10, java.lang.String(sinfo.experiment_title));
      stmt.setObject(11, java.lang.String(sinfo.experiment_description));
      stmt.setObject(12, java.lang.String(sinfo.reference_ids));
      stmt.setObject(13, java.lang.String(sinfo.additional_comments));
      stmt.setObject(14, java.lang.String(sinfo.additional_authors));
      stmt.setObject(15, java.lang.String(sinfo.keywords));
      stmt.setObject(16, java.lang.String(sinfo.quantity));
      stmt.setObject(17, java.lang.String(sinfo.analysis_description));
      stmt.setObject(18, java.lang.String(author));
      stmt.execute();
      stmt.close();
      
      % update other meta-data tables
      cols = utils.mysql.execute(conn, 'SHOW COLUMNS FROM tsdata');
      if utils.helper.ismember('obj_id',  cols(:,1))
        % the tsdata table contains an obj id column. use the new database schema
        utils.repository.insertObjMetadata(conn, obj, objid);
      else
        % otherwise use the old one
        utils.helper.msg(msg.PROC2, 'using back-compatibility code');
        utils.repository.insertObjMetadataV1(conn, obj, objid);
      end
      
      % update transactions table
      if update_transactions
        stmt = conn.prepareStatement(...
          'INSERT INTO transactions (obj_id, user_id, transdate, direction) VALUES (?, ?, ?, ?)');
        stmt.setObject(1, objid);
        stmt.setObject(2, userid);
        stmt.setObject(3, java.lang.String(tdate));
        stmt.setObject(4, java.lang.String('in'));
        stmt.execute();
        stmt.close();
      end
      
      % collect the ID of the submitted object
      ids(kk) = objid;
      
      % collect the UUID of the submitted object
      uuids{kk} = obj.UUID;
      
    end
    
    % make collection entry
    if numel(ids~=0) > 1
      cid = utils.repository.createCollection(conn, ids);
    end
    
  catch ex
    utils.helper.msg(msg.IMPORTANT, 'submission error. no object submitted')
    rethrow(ex)
  end
  
  % commit the transaction
  conn.commit();
  
  % report IDs of the inserted objects
  for kk = 1:numel(objs)
    utils.helper.msg(msg.IMPORTANT, 'submitted %s object with ID: %d UUID: %s name: %s', ...
      class(objs{kk}), ids(kk), objs{kk}.UUID, objs{kk}.name);
  end
  if ~isempty(cid)
    utils.helper.msg(msg.IMPORTANT, 'made collection entry with ID: %d', cid);
  end
  
  % pass back outputs
  subpl = copy(plist.TO_REPOSITORY_PLIST);
  subpl.pset('hostname', submit_hostname);
  subpl.addAlternativeKeys('hostname', 'submit_hostname');
  subpl.pset('database', submit_database);
  subpl.addAlternativeKeys('database', 'submit_database');
  subpl.pset('ids', ids);
  subpl.pset('cid', cid);
  subpl.pset('uuids', uuids);
  subpl.pset('EXPERIMENT TITLE', userSinfo.experiment_title);
  subpl.pset('EXPERIMENT DESCRIPTION', userSinfo.experiment_description);
  subpl.pset('ANALYSIS DESCRIPTION', userSinfo.analysis_description);
  subpl.pset('QUANTITY', userSinfo.quantity);
  subpl.pset('KEYWORDS', userSinfo.keywords);
  subpl.pset('REFERENCE IDS', userSinfo.reference_ids);
  subpl.pset('ADDITIONAL COMMENTS', userSinfo.additional_comments);
  subpl.pset('ADDITIONAL AUTHORS', userSinfo.additional_authors);
  subpl.pset('NO DIALOG', true);
  
  varargout{1} = subpl;
end


function varargout = userCanceled()
  % signal that the user cancelled the submission
  import utils.const.*
  utils.helper.msg(msg.PROC1, 'user cancelled');
  varargout{1} = plist();
end


function sinfo = checkSinfo(sinfo)
  % check sinfo structure
  
  import utils.const.*
  
  % fieldnames
  mainfields = {'experiment_title', 'experiment_description', 'analysis_description'};
  extrafields = {'quantity', 'keywords', 'reference_ids', 'additional_comments', 'author', 'additional_authors'};
  
  % fieldnames of the input structure
  fnames = fieldnames(sinfo);
  
  % check mandatory fields
  for jj = 1:length(mainfields)
    if ~ismember(fnames, mainfields{jj})
      error('### the sinfo structure should contain a ''%s'' field', mainfields{jj});
    end
  end
  
  % check extra fields
  for jj = 1:length(extrafields)
    if ~ismember(fnames, extrafields{jj})
      utils.helper.msg(msg.PROC2, 'setting default for field %s', extrafields{jj});
      sinfo.(extrafields{jj}) = '';
    end
  end
  
  % additional checks
  if length(sinfo.experiment_title) < 5
    error('### ''experiment title'' should be at least 5 characters long');
  end
  if length(sinfo.experiment_description) < 10
    error('### ''experiment description'' should be at least 10 characters long');
  end
  if length(sinfo.analysis_description) < 10
    error('### ''analysis description'' should be at least 10 characters long');
  end
  
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
  
  p = param({'sinfo filename', 'Path to an XML file containing submission metadata'}, paramValue.EMPTY_STRING);
  plo.append(p);
  
  p = param({'binary', 'Submit only binary version of the objects'}, paramValue.FALSE_TRUE);
  plo.append(p);
end


function pl = fixPlist(pl)
  % accept parameters where words are separated either by spaces or underscore
  if ~isempty(pl)
    for ii = 1:pl.nparams
      pl.params(ii).setKey(strrep(pl.params(ii).key, '_', ' '));
    end
  end
end


function flat = flatten(objs)
  % flatten nested lists into a single cell array
  
  flat = {};
  
  while iscell(objs) && numel(objs) == 1
    objs = objs{1};
  end
  
  if numel(objs) == 1
    flat = {objs};
    return;
  end
  
  for jj = 1:numel(objs)
    obj = flatten(objs(jj));
    for kk = 1:numel(obj)
      flat = [ flat obj(kk) ];
    end
  end
  
end
