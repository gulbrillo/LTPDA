%
% DESCRIPTION: Tests that the metadata 'submitted' of a database
%              works for a ltpda object.
%
% CHECKS:      - Check that we get only one connection from the used
%                repository PLIST
%              - Check that the metadata was set with a submit PLIST
%              - Check that the metadata was set with a submit structure
%

function varargout = test_objmeta_submitted(varargin)
  
  utp = varargin{1};
  
  if ~utp.testRunner.skipRepoTests()
    
    dbTable    = 'objmeta';
    tableField = 'submitted';
    nhour      = 1;
    
    % Check that the metadata was set with a submit PLIST
    try
      for nn = 1:numel(utp.objIds)
        
        % get 'submitted' from the objmeta table
        val = utp.getTableEntry(dbTable, tableField, utp.objIds(nn));
        
        % Check that we get only one result for the query
        assert(isequal(numel(val), 1))
        
        % Check that the difference betwen the submitted time and the
        % current time is not larger than n hours.
        sTime = val{1};
        cTime = time();
        dTime = cTime - sTime;
        assert(abs(dTime.utc_epoch_milli) <= nhour * 60 * 60 * 1000, sprintf('The time difference between submittion-time and checking time is larger than %d hour (%d)', nhour, double(dTime)))
      end
    catch Me
      throw(Me);
    end
    
    % Check that the metadata was set with a submit structure
    try
      for nn = 1:numel(utp.objIdsStruct)
        
        % get 'submitted' from the objmeta table
        val = utp.getTableEntry(dbTable, tableField, utp.objIdsStruct(nn));
        
        assert(isequal(numel(val), 1))
        
        % Check that the difference betwen the submitted time and the
        % current time is not larger than n hours. 
        sTime = val{1};
        cTime = time();
        dTime = cTime - sTime;
        assert(abs(dTime.utc_epoch_milli) <= nhour * 60 * 60 * 1000, sprintf('The time difference between submittion-time and checking time is larger than %d hour (%d)', nhour, double(dTime)))
      end
    catch Me
      throw(Me);
    end
    
    varargout{1} = sprintf('Test the field ''%s'' of the database table ''%s'' with the database %s ', tableField, dbTable, utp.testRunner.repositoryPlist.find('database'));
  else
    varargout{1} = 'Skip database test';
  end
end
