%
% DESCRIPTION: Tests that the metadata 'created' of a database
%              works for a ltpda object.
%
% CHECKS:      - Check that we get only one connection from the used
%                repository PLIST
%              - Check that the metadata was set with a submit PLIST
%              - Check that the metadata was set with a submit structure
%

function varargout = test_objmeta_created(varargin)
  
  utp = varargin{1};
  
  if ~utp.testRunner.skipRepoTests()
    
    dbTable    = 'objmeta';
    tableField = 'created';
    
    % Check that the metadata was set with a submit PLIST
    try
      for nn = 1:numel(utp.objIds)
        
        % get 'created' from the objmeta table
        val = utp.getTableEntry(dbTable, tableField, utp.objIds(nn));
        
        % Check that we get only one result for the query
        assert(isequal(numel(val), 1))
        
        % Check that the return value is a time-object.
        assert(isa(val{1}, 'time'));
        
        % Check that the created of the meta table is the same as the
        % created time of the test objects
        qTime = val{1}.format('yyyy-mm-dd HH:MM:SS');
        cTime = utp.testData(nn).created.format('yyyy-mm-dd HH:MM:SS');
        assert(strcmp(qTime, cTime));
      end
    catch Me
      throw(Me);
    end
    
    % Check that the metadata was set with a submit structure
    try
      for nn = 1:numel(utp.objIdsStruct)
        
        % get 'created' from the objmeta table
        val = utp.getTableEntry(dbTable, tableField, utp.objIdsStruct(nn));
        
        % Check that we get only one result for the query
        assert(isequal(numel(val), 1))
        
        % Check that the return value is a time-object.
        assert(isa(val{1}, 'time'));
        
        % Check that the created of the meta table is the same as the
        % created time of the test objects
        qTime = val{1}.format('yyyy-mm-dd HH:MM:SS');
        cTime = utp.testData(nn).created.format('yyyy-mm-dd HH:MM:SS');
        assert(strcmp(qTime, cTime));
      end
    catch Me
      throw(Me);
    end
    
    varargout{1} = sprintf('Test the field ''%s'' of the database table ''%s'' with the database %s ', tableField, dbTable, utp.testRunner.repositoryPlist.find('database'));
  else
    varargout{1} = 'Skip database test';
  end
end
