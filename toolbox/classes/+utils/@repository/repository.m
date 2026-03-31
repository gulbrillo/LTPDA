classdef repository
% UTILS.REPOSITORY  Utility functions to operate with LTPDA Repositories

  methods (Static)

    adjustPlist(conn, pl);
    varargout = existObjectInDB(conn, name, ts, constraints, varargin);
    varargout = getObjectIdInTimespan(conn, ts, varargin);
    type      = getObjectType(conn, id);
    sinfo     = getObjectMetaData(conn, varargin);
    ids       = getCollectionIDs(conn, cid);
    cid       = createCollection(conn, ids);
    varargout = getUser(conn);

    varargout = insertObjMetadata(varargin);
    varargout = insertObjMetadataV1(varargin);

    varargout = updateObjMetadata(varargin);
    varargout = updateObjMetadataV1(varargin);
    
    varargout = getUUIDfromID(varargin);
    varargout = getIDfromUUID(varargin);
    
    varargout = findDuplicates(varargin);

    varargout = report(varargin);
    varargout = search(varargin);
    
    varargout = listDatabases(varargin);
    varargout = getLatestObject(varargin);
    
  end % static methods

end
