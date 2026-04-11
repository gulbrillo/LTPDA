%
% DESCRIPTION: Tests the 'tsdata' table of the database.
%
% CHECKS:      - Check that the 't0' contains the correct
%                t0 from the test data.
%

function varargout = test_tsdata_t0(varargin)
  
  utp = varargin{1};
  
  if ~utp.testRunner.skipRepoTests()
    
    dbTable    = 'tsdata';
    tableField = 't0';
    
    % Check that the metadata was set with a submit PLIST
    try
      for nn = 1:numel(utp.objIds)
        
        dbT0 = getTableEntry(utp, dbTable, tableField, utp.objIds(nn));
        
        % Check that we get only one result for the query
        assert(isequal(numel(dbT0), 1))
        
        % Check that the entry in the table is the same as the t0 of
        % the test data
        obj = utp.testData(nn);
        if utp.oldDB
          t0 = obj.t0;
        else
          t0  = obj.t0 + obj.toffset;
        end
        assert(isequal(double(dbT0{1}), floor(double(t0))), 'The T0 in the table tsdata and the t0 of the test object are not equal');
        
      end
    catch Me
      throw(Me);
    end
    
    varargout{1} = sprintf('Test the field ''%s'' of the database table ''%s'' with the database %s ', tableField, dbTable, utp.testRunner.repositoryPlist.find('database'));
  else
    varargout{1} = 'Skip database test';
  end
end
