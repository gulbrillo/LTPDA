function [username, userid] = getUser(conn)
% GETUSER  Return username and userid of the current database user.
%
% CALL:
%
%   [username, userid] = utils.repository.getUser(conn)
%

  % current database user
  rows = utils.mysql.execute(conn, 'SELECT SUBSTRING_INDEX(USER(),''@'',1)');
  username = rows{1};

  % userid
  rows = utils.mysql.execute(conn, 'SELECT id FROM users WHERE username = ?', username);
  if isempty(rows)
    error('### could not determine user id');
  end
  userid = rows{1};

end
