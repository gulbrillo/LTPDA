%
% DESCRIPTION: Tests the 'ao' table of the database.
%
% CHECKS:      - Check that the 'description' contains the correct
%                description from the test data.
%

function varargout = test_ao_description(varargin)
  
  utp = varargin{1};
  
  if ~utp.testRunner.skipRepoTests()
    
    dbTable    = 'ao';
    tableField = 'description';
    
    % Check that the metadata was set with a submit PLIST
    try
      for nn = 1:numel(utp.objIds)
        
        % get 'description' from the ao table
        val = utp.getTableEntry(dbTable, tableField, utp.objIds(nn));
        
        % Check that we get only one result for the query
        assert(isequal(numel(val), 1))
        
        % Check that the entry in the table is the same as the description
        % of the test data
        assert(strcmp(val{1}, utp.testData(nn).description))
        
      end
    catch Me
      throw(Me);
    end
    
    varargout{1} = sprintf('Test the field ''%s'' of the database table ''%s'' with the database %s ', tableField, dbTable, utp.testRunner.repositoryPlist.find('database'));
  else
    varargout{1} = 'Skip database test';
  end
end
