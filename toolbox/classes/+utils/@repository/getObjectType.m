% GETOBJECTTYPE  Return the type of the object.
%
% CALL:
%
%   otype = utils.repository.getObjectType(conn, id)
%   otype = utils.repository.getObjectType(conn, uuid)
%
% PARAMETERS:
%
%   CONN   database connection implementing java.sql.Connection
%   ID     object id
%   UUID   object uuid
% 
% OUTPUTS:
%   otype  a string with the objects type (A cell array with the results 
%          for the case of more than 1 id input)
%
function otype = getObjectType(conn, id)
  
  % check if the user passed a uuid
  if ischar(id)
    q = 'SELECT objs.ID FROM objs WHERE objs.uuid LIKE ?';
    uuid = id;
    id = cell2mat(utils.mysql.execute(conn, q, uuid));
    if numel(id) > 1
      warning('I found for some reason multiple IDs [%s] for the given UUID [%s]', utils.helper.val2str(id), uuid);
    end
  end
  
  rows = utils.mysql.execute(conn, sprintf('SELECT obj_type FROM objmeta WHERE obj_id in (%s)', utils.prog.csv(id)));
  if isempty(rows)
    error('### object %d not found', utils.prog.csv(id));
  end
  
  % Ensure back-compatibility
  if  numel(id) == 1
    otype = rows{1};
  else
    otype = rows;
  end
  
end
