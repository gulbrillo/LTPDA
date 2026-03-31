%
% DESCRIPTION: Tests that the metadata 'version' of a database
%              works for a ltpda object
%
% CHECKS:      - Check that we get only one connection from the used
%                repository PLIST
%              - Check that the metadata was set with a submit PLIST
%              - Check that the metadata was set with a submit structure
%

function varargout = test_objmeta_version(varargin)
  
  utp = varargin{1};
  
  if ~utp.testRunner.skipRepoTests()
    
    dbTable    = 'objmeta';
    tableField = 'version';
    
    % Check that the metadata was set with a submit PLIST
    try
      for nn = 1:numel(utp.objIds)
        
        % get 'version' from the objmeta table
        val = utp.getTableEntry(dbTable, tableField, utp.objIds(nn));
        
        % Check that we get only one result for the query
        assert(isequal(numel(val), 1))
        
        % Check the query result with the current LTPDA version
        v = ver('LTPDA');
        assert(isequal(numel(v), 1), sprintf('I found more than one LTPDA toolbox. Versions (%s)', utils.helper.val2str({v(:).Version})))
        assert(any(strfind(val{1}, v.Version)), sprintf('The LTPDA version doesn''t match. Class val %s', class(val{1})))
        assert(any(strfind(val{1}, v.Release)), 'The LTPDA release doesn''t match')
      end
    catch Me
      throw(Me);
    end
    
    % Check that the metadata was set with a submit structure
    try
      for nn = 1:numel(utp.objIdsStruct)
        
        % get 'version' from the objmeta table
        val = utp.getTableEntry(dbTable, tableField, utp.objIdsStruct(nn));
        
        % Check that we get only one result for the query
        assert(isequal(numel(val), 1))
        
        % Check the query result with the current LTPDA version
        v = ver('LTPDA');
        
        assert(isequal(numel(v), 1), sprintf('I found more than one LTPDA toolbox. Versions (%s)', utils.helper.val2str({v(:).Version})))
        assert(any(strfind(val{1}, v.Version)), 'The LTPDA version doesn''t match')
        assert(any(strfind(val{1}, v.Release)), 'The LTPDA release doesn''t match')
      end
    catch Me
      throw(Me);
    end
    
    varargout{1} = sprintf('Test the field ''%s'' of the database table ''%s'' with the database %s ', tableField, dbTable, utp.testRunner.repositoryPlist.find('database'));
  else
    varargout{1} = 'Skip database test';
  end
end
