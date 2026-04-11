function sinfo = getObjectMetaData(conn, varargin)
% GETOBJECTMETADATA Retrieved objects metadata from the repository
%
% CALL:
%
%   sinfo = utils.repository.getObjectMetaData(conn, id, id)
%
% INPUTS:
%
%    conn - repository connection implementing java.sql.Connection
%      id - object ID
%
% OUTPUTS:
%
%   sinfo - array of sinfo structures containing fields
%
%    - name
%    - experiment_title
%    - experiment_desc
%    - analysis_desc
%    - quantity
%    - additional_authors
%    - additional_comments
%    - keywords
%    - reference_ids
%

  if ~isa(conn, 'java.sql.Connection')
    error('### first argument should be a java.sql.Connection object');
  end

  sinfo = [];
  
  q = ['SELECT name, experiment_title, experiment_desc, analysis_desc, ' ...
       'quantity, additional_authors, additional_comments, keywords, ' ...
       'reference_ids FROM objmeta WHERE obj_id = ?'];
  
  for kk = 1:length(varargin)
    info = utils.mysql.execute(conn, q, varargin{kk});
    if isempty(info)
      error('### object %d not found', varargin{kk});
    end

    s.conn                    = conn;
    s.name                    = info{1};
    s.experiment_title        = info{2};
    s.experiment_description  = info{3};
    s.analysis_description    = info{4};
    s.quantity                = info{5};
    s.additional_authors      = info{6};
    s.additional_comments     = info{7};
    s.keywords                = info{8};
    s.reference_ids           = info{9};

    sinfo = [sinfo s];
  end

end
