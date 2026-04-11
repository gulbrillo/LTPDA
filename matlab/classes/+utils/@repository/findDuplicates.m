% findDuplicates returns the IDs of duplicated objects for given database.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: findDuplicates returns the IDs of duplicated objects for given database.
%
% CALL:        check               = utils.repository.findDuplicates(pl)
%              [check, IDs]        = utils.repository.findDuplicates(pl)
%              [check, IDs, UUIDs] = utils.repository.findDuplicates(pl)
%
%
% INPUTS:      pl - Parameter-List Object (PLIST) with the keys:
%
%                hostname - Database server hostname.
%                database - Database name.
%                username - User name to use when connecting to the database. Leave blank to be prompted.
%                password - Password to use when connecting to the database. Leave blank to be prompted.
%
% OUTPUTS:
%              check    - a boolean value with
%                       false: no duplicated found
%                       true:  some duplicated found
%              IDs      - a cell array, where each element is a vector of IDs
%                         corresponding to the same UUID
%              UUIDs    - a cell array, where each element is the repeated UUID
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = findDuplicates(plIn)
  
  switch nargout
    case 1
      hard = false;
    case {2, 3}
      hard = true;
    otherwise
      error('Incorrect number of outputs!');
  end
  
  % Get a connection to the database.
  conn = LTPDADatabaseConnectionManager().connect(plIn);
  oncleanup = onCleanup(@()conn.close());
  
  % Query for all UUIDs
  q = 'SELECT objs.UUID FROM objs';
  UUIDs = utils.mysql.execute(conn, q);
  
  % Now search for duplicated UUIDs
  [nUUIDs, iu, ir] = unique(UUIDs, 'stable');
  
  check = isequal(nUUIDs, UUIDs);
  
  % Identify repetitions
  dup_UUIDs = {};
  dup_IDs   = {};
  
  varargout{1} = ~check;
  
  if hard && ~check
    % Query for all IDs
    q = 'SELECT objs.ID FROM objs';
    IDs = utils.mysql.execute(conn, q);
    
    for kk = 1:numel(nUUIDs)
      % Compare with the others
      % There must be a cleverer way to do that ...
      idx = strcmp(nUUIDs{kk}, UUIDs);
      
      % Extract the repeated ones:
      if sum(idx) > 1
        dup_UUIDs = [dup_UUIDs; nUUIDs{kk}];
        dup_IDs   = [dup_IDs; IDs(idx)];
      end
      
    end
    
  end
  
  % Output
  if hard varargout{2} = dup_IDs;
    if nargout == 3
      varargout{3} = dup_UUIDs;
    end
  end
  
end
