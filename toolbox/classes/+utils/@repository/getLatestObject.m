function objInfo = getLatestObject(varargin)
% GETLATESTOBJECT Performs a mySQL query on a LTPDA repository and returns
% the ID corresponding to the tsdata ao with the requested name which has
% the most recent time sample. Optional output includes a table of all
% tsdata objects with that name, their start times, and durations.
%
% CALL:
%
%   objInfo = utils.repository.getLatestObject(conn, name)
%   objInfo = utils.repository.getLatestObject(conn, name, showAll)
%
% INPUTS:
%
%    conn - repository connection implementing java.sql.Connection
%    name - name or LTPDANamedItem (will use preferredAliasName)
%    showAll - option to include all tsdata objects with corresponding name
%              in the output, not just the latest one.
%
% OUTPUTS:
%
%   objInfo - structure array containing the following info for each object
%
%    - id
%    - UUID
%    - t0
%    - nsecs
%    - tfinal (derived)
%


% parse inputs
conn = varargin{1};
  if ~isa(conn, 'java.sql.Connection')
    error('### first argument should be a java.sql.Connection object');
  end

  if isa(varargin{2},'char')
    name = varargin{2};
  elseif isa(varargin{2},'LTPDANamedItem')
    name = varargin{2}.preferredAliasName;
  else
    error('### second argument should be a char or object of type LTPDANamedItem');
end
  
if nargin > 2
  showAll = varargin{3};
else
  showAll = false;
end

% build query string
  
  q = sprintf([...
    'SELECT objmeta.obj_id, objs.uuid, tsdata.t0, tsdata.nsecs ' ...
    'FROM objmeta,objs,ao,tsdata WHERE objmeta.name = ''%s'' ' ...
    ' AND ao.data_type = ''tsdata'''...
    ' AND objmeta.obj_id = ao.obj_id',...
    ' AND tsdata.obj_id = objmeta.obj_id' ...
    ' AND objs.id = objmeta.obj_id;'],name);
    
 % perform query
 res = utils.mysql.execute(conn,q);
  
 % check if empty
 if isempty(res)
   warning('### no objects found with name %s',name);
   objInfo = [];
   return
 end
 
 % compute final times
 for ii = 1:size(res,1), res{ii,5} = res{ii,3}+res{ii,4}; end
 
 % sort
 [~,idx] = sort(double([res{:,5}]),'descend');
 
 res = res(idx,:);
 
 % put into structure
 for ii = 1:size(res,1)
   objInfo(ii).id = res{ii,1};
   objInfo(ii).uuid = res{ii,2};
   objInfo(ii).t0 = res{ii,3};
   objInfo(ii).nsecs = res{ii,4};
   objInfo(ii).tfinal = res{ii,5};
 end
 
end
