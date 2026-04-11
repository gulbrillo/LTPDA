%
% DESCRIPTION: Tests the 'ao' table of the database.
%
% ATTENTION:   This test assumes that we have committed only one AO with
%              each data-type.
%
% CHECKS:      - Check that the 'data_id' contains the correct ID from the
%                data table. --> check that the data_id of the 'ao' table
%                is the same as the last entry in the data table
%                (e.g. fsdata table).
%

function varargout = test_ao_data_id(varargin)
  
  utp = varargin{1};
  
  if ~utp.testRunner.skipRepoTests()
    
    
    if utp.oldDB
      % For this UTP it is necessary that we just commit the object befor we
      % can check the ID.
      utp.init();
      
      dbTable    = 'ao';
      tableField = 'data_id';
      
      % Check that the metadata was set with a submit PLIST
      try
        for nn = 1:numel(utp.objIds)
          
          dataID1 = getTableEntry(utp, 'ao', 'data_id', utp.objIds(nn));
          
          % Create query to get the field 'id' from the data table (e.g. 'fsdata')
          query = sprintf('SELECT id FROM %s ORDER BY id DESC LIMIT 0,1', class(utp.testData(nn).data));
          dataID2 = utils.mysql.execute(utp.conn, query);
          
          % ATTENTION: This test assumes that we have committed only one AO
          %            with each data-type.
          % Check that we got the same IDs
          assert(isequal(dataID1{1}, dataID2{1}))
          
        end
      catch Me
        rethrow(Me);
      end
      varargout{1} = sprintf('Test the field ''%s'' of the database table ''%s'' with the database %s ', tableField, dbTable, utp.testRunner.repositoryPlist.find('database'));
      
    else
      varargout{1} = sprintf('This test is obsolete because the new database structure doesn''t have the field [%s.%s]', 'ao', 'dataid');
    end
    
  else
    varargout{1} = 'Skip database test';
  end
end
