%
% DESCRIPTION: Tests the 'xydata' table of the database.
%
% CHECKS:      - Check that the 'xunits' contains the correct
%                xunits from the test data.
%

function varargout = test_xydata_xunits(varargin)
  
  utp = varargin{1};
  
  if ~utp.testRunner.skipRepoTests()
    
    dbTable    = 'xydata';
    tableField = 'xunits';
    
    % Check that the metadata was set with a submit PLIST
    try
      for nn = 1:numel(utp.objIds)
        
        val = getTableEntry(utp, dbTable, tableField, utp.objIds(nn));
        
        % Check that we get only one result for the query
        assert(isequal(numel(val), 1))
        
        % Check that the 'xunits' contains the correct xunits from the test
        % data.
        assert(strcmp(val{1}, char(utp.testData(nn).xunits)))
        
      end
    catch Me
      throw(Me);
    end
    
    varargout{1} = sprintf('Test the field ''%s'' of the database table ''%s'' with the database %s ', tableField, dbTable, utp.testRunner.repositoryPlist.find('database'));
  else
    varargout{1} = 'Skip database test';
  end
end
