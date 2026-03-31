function sinfo = getsinfo(conn, varargin)
% GETSINFO  Retrieved objects metadata from the repository
%
% DEPRECATED!  Use utils.repository.getObjectMetaData() instead

  warning('LTPDA:deprecated', 'Deprecated! Use utils.repository.getObjectMetaData() instead');
  
  sinfo = utils.repository.getObjectMetaData(conn, varargin{:});
  
end
