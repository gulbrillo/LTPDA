%
% DESCRIPTION: Tests the 'ao' table of the database.
%
% CHECKS:      - Check that the 'mfilename' isempty.
%

function varargout = test_ao_mfilename(varargin)
  
  utp = varargin{1};
  
  if ~utp.testRunner.skipRepoTests()
    
    dbTable    = 'ao';
    tableField = 'mfilename';
    
    if utp.oldDB
      % Check that the metadata was set with a submit PLIST
      try
        for nn = 1:numel(utp.objIds)
          
          % get 'mfilename' from the ao table
          val = utp.getTableEntry(dbTable, tableField, utp.objIds(nn));
          
          % Check that we get only one result for the query
          assert(isequal(numel(val), 1))
          
          % Check that the entry in the table is the same as the desrciption
          % of the test data
          assert(isempty(val{1}))
          
        end
      catch Me
        throw(Me);
      end
      varargout{1} = sprintf('Test the field ''%s'' of the database table ''%s'' with the database %s ', tableField, dbTable, utp.testRunner.repositoryPlist.find('database'));
      
    else
      varargout{1} = sprintf('This test is obsolete because the new database structure doesn''t have the field [%s.%s]', dbTable, tableField);
    end
    
  else
    varargout{1} = 'Skip database test';
  end
end
