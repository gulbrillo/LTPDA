% INIT initialize the unit test class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: INIT initialize the unit test class.
%              This method is called before the test methods.
%
% CALL:        init();
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = init(varargin)
  
  utp = varargin{1};
  
  % Call super class
  init@ltpda_utp(varargin{:});
  
  if ~utp.testRunner.skipRepoTests()
    
    % Get database connection
    conn = LTPDADatabaseConnectionManager().connect(utp.testRunner.repositoryPlist);

    % Store the connection
    utp.conn = conn;
    
    % Submit test data
    utp.submitTestData(varargin{2:end});
    
    % Check which kind of database layout we have
    cols = utils.mysql.execute(utp.conn, 'SHOW COLUMNS FROM tsdata');
    if utils.helper.ismember('obj_id',  cols(:,1))
      utp.oldDB   = false;
      utp.tableId = 'obj_id';
    else
      utp.oldDB = true;
      utp.tableId = 'id';
    end
    
  end
  
end

