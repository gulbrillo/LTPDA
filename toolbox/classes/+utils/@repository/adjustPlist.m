function adjustPlist(conn, pl)
% ADJUSTPLIST(CONN, PL) Removes CONN, USERNAME, PASSWORD parameters
% from plist PL, and adds or or substitutes HOSTNAME and DATABASE
% parameters with the ones used to establish connection CONN.
%
% The resulting plist may be used to set object history.

  % check parameters
  if ~isa(conn, 'java.sql.Connection')
    error('### invalid call');
  end
  if ~isa(pl, 'plist')
    error('### invalid call');
  end

  % get connection parameters
  r = '^jdbc:mysql://(?<hostname>.+)/(?<database>.+)$';
  c = regexp(char(conn.getMetaData().getURL()), r, 'names');

  % remove unwanted parameters
  prem(pl, 'conn');
  prem(pl, 'username');
  prem(pl, 'password');

  % add essentials connections parameters
  pset(pl, 'hostname', c.hostname);
  pset(pl, 'database', c.database);

end


function prem(pl, key)
% PREM Remove parameter KEY if present in plist PL.
  if isparam(pl, key)
    remove(pl, key);
  end
end
