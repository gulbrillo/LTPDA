% SEARCH searches for objects by name and timespan in a repository
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SEARCH searches for objects by name and timespan in a
%              repository.
%
% CALL:        result = utils.repository.search(pl)
%
% INPUTS:      pl - a valid repository plist
%              
%          Additional Keys:
%                   name - the name of the items to search for. Can be a
%                          regular expression.
%               timespan - an optional timespan to filter on.
%            HTMLsummary - A logical flag to determine if a HTML summary of
%                          the search should be generated and opened.
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function results = search(pl)
  
  if ~isa(pl, 'plist') || ~isRepositoryPlist(pl)
    error('Please specify a valid repository plist');
  end
  
  name = pl.find('name');
  if isempty(name)
    error('Please specify a name or search string to search for.');
  end
  
  tspan = pl.find('timespan');
  
  % Default behaviour is to generate and open a HTML summary of the search.
  htmlSummary = pl.find('HTMLsummary');
  if isempty(htmlSummary)
    htmlSummary = true;
  end
  
  % create connection
  conn = LTPDADatabaseConnectionManager().connect(pl);
  
  % Register cleanup handler to close the database connection
  oncleanup1 = onCleanup(@()conn.close());
  
  % query
  q = '';
  q = [q 'select objs.id, objs.uuid, objmeta.name, objmeta.experiment_title, objmeta.submitted, objmeta.keywords from '];
  q = [q 'objs left join objmeta on objmeta.obj_id = objs.id '];
  q = [q 'where objmeta.name like ?  '];
  
  if isa(tspan, 'timespan')
    
    q = [q 'AND(  (STR_TO_DATE(ExtractValue(objmeta.keywords,''/ltpda_uoh/timespan/start''), ''%Y-%m-%d %H:%i:%s'') >= ? ' ];
    q = [q '       AND STR_TO_DATE(ExtractValue(objmeta.keywords,''/ltpda_uoh/timespan/start''), ''%Y-%m-%d %H:%i:%s'') <= ?) ' ];
    q = [q '   OR (STR_TO_DATE(ExtractValue(objmeta.keywords,''/ltpda_uoh/timespan/stop''), ''%Y-%m-%d %H:%i:%s'') >= ? ' ];
    q = [q '       AND STR_TO_DATE(ExtractValue(objmeta.keywords,''/ltpda_uoh/timespan/stop''), ''%Y-%m-%d %H:%i:%s'') <= ? ) '];
    q = [q '   OR (STR_TO_DATE(ExtractValue(objmeta.keywords,''/ltpda_uoh/timespan/start''), ''%Y-%m-%d %H:%i:%s'') < ? ' ];
    q = [q '       AND STR_TO_DATE(ExtractValue(objmeta.keywords,''/ltpda_uoh/timespan/stop''), ''%Y-%m-%d %H:%i:%s'') > ?))'];
        
    % search
    s = tspan.startT;
    e = tspan.endT;
    results = utils.mysql.execute(conn, q, name, s, e, s, e, s, e);    
  else
    % search
    results = utils.mysql.execute(conn, q, name);
  end
    
  % clean up timespan column
  keywordsCol = 6;
  for kk=1:size(results, 1)
    
    xml = results{kk, keywordsCol};
    
    r = regexp(xml, '<start>(.*)</start', 'tokens');
    start = r{1}{1};
    
    r = regexp(xml, '<stop>(.*)</stop', 'tokens');
    stop = r{1}{1};
    
    results{kk, keywordsCol} = time(start);
    results{kk, keywordsCol+1} = time(stop);
    
  end
    
  % HTML
  if htmlSummary
    title = sprintf('%s/%s', pl.find('hostname'), pl.find('database'));
    html = 'text://';
    html = [html utils.html.pageHeader(title)];
    html = [html utils.html.beginBody('')];

    headers = {'ID', 'UUID', 'Name', 'Experiment Title', 'Submitted', 'Start', 'Stop'};
    html = [html utils.html.table(title, headers, results)];

    html = [html utils.html.endBody('')];
    html = [html utils.html.pageFooter()];

    web(html, '-new');
  end
  
end

% END