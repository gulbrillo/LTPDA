%
% DESCRIPTION: Tests that the metadata 'obj_type' of a database
%              works for a ltpda object.
%
% CHECKS:      - Check that we get only one connection from the used
%                repository PLIST
%              - Check that the metadata was set with a submit PLIST
%              - Check that the metadata was set with a submit structure
%

function varargout = test_objmeta_obj_type(varargin)
  
  utp = varargin{1};
  
  if ~utp.testRunner.skipRepoTests()
    
    dbTable    = 'objmeta';
    tableField = 'obj_type';
    
    % Check that the metadata was set with a submit PLIST
    try
      for nn = 1:numel(utp.objIds)
        
        % get 'obj_type' from the objmeta table
        val = utp.getTableEntry(dbTable, tableField, utp.objIds(nn));
        
        % Check that we get only one result for the query
        assert(isequal(numel(val), 1))
        
        % Check that object type in the meta data table is the same as the
        % class of the test data.
        assert(strcmp(val{1}, class(utp.testData)))
      end
    catch Me
      throw(Me);
    end
    
    % Check that the metadata was set with a submit structure
    try
      for nn = 1:numel(utp.objIdsStruct)
        
        % get 'obj_type' from the objmeta table
        val = utp.getTableEntry(dbTable, tableField, utp.objIdsStruct(nn));
        
        % Check that we get only one result for the query
        assert(isequal(numel(val), 1))
        
        % Check that object type in the meta data table is the same as the
        % class of the test data.
        assert(strcmp(val{1}, class(utp.testData)))
      end
    catch Me
      throw(Me);
    end
    
    varargout{1} = sprintf('Test the field ''%s'' of the database table ''%s'' with the database %s ', tableField, dbTable, utp.testRunner.repositoryPlist.find('database'));
  else
    varargout{1} = 'Skip database test';
  end
end
