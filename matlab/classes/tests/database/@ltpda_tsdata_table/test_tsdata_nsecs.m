%
% DESCRIPTION: Tests the 'tsdata' table of the database.
%
% CHECKS:      - Check that the 'nsecs' contains the correct
%                number od seconds as the test data.
%

function varargout = test_tsdata_nsecs(varargin)
  
  utp = varargin{1};
  
  if ~utp.testRunner.skipRepoTests()
    
    dbTable    = 'tsdata';
    tableField = 'nsecs';
    
    % Check that the metadata was set with a submit PLIST
    try
      for nn = 1:numel(utp.objIds)
        
        val = getTableEntry(utp, dbTable, tableField, utp.objIds(nn));
        
        % Check that we get only one result for the query
        assert(isequal(numel(val), 1))
        
        % Check that the entry in the table is the same as the nsecs of
        % the test data
        assert(abs(val{1} - utp.testData(nn).nsecs) < 1e-12)
        
      end
    catch Me
      throw(Me);
    end
    
    varargout{1} = sprintf('Test the field ''%s'' of the database table ''%s'' with the database %s ', tableField, dbTable, utp.testRunner.repositoryPlist.find('database'));
  else
    varargout{1} = 'Skip database test';
  end
end
