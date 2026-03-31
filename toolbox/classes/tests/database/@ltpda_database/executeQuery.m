%
% DESCRIPTION: Returns the result for a given query.
%
% DEPRECATED! Use utils.mysql.execute instead.
%

function val = executeQuery(utp, query)
  warning('!!! Deprecated! Use utils.mysql.execute instead');
  val = utils.mysql.execute(utp.conn, query);
end
