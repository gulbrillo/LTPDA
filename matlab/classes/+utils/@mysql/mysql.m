classdef mysql
% UTILS.MYSQL  MySQL database utilities.

  methods (Static)

    conn = connect(hostname, database, username, password);
    varargout = execute(conn, query, varargin);

  end % static methods

end
