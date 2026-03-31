%
% DESCRIPTION: Returns
%

function val = getTableIdFromTestObj(utp, dbTable, objID)
  
  if utp.oldDB
    %%% old database layout
    if strcmp(dbTable, 'ao')
      q = sprintf('SELECT id FROM ao WHERE ao.obj_id = ?');
    elseif utils.helper.ismember(dbTable, {'cdata', 'xydata', 'tsdata', 'fsdata'})
      q = sprintf('SELECT data_id FROM ao WHERE ao.obj_id = ?');
    elseif strcmp(dbTable, 'objmeta')
      q = sprintf('SELECT id FROM objmeta WHERE objmeta.obj_id = ?');
    else
      error('### Please code me up');
    end
    val = utils.mysql.execute(utp.conn, q, objID);
    val = [val{:}];
    
  else
    %%% new database layout
    val = objID;
  end
end
