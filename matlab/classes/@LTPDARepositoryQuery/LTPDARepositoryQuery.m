% LTPDARepositoryQuery — graphical query interface for the LTPDA repository.
%
% CALL: LTPDARepositoryQuery
%
% Opens a uifigure that allows the user to run SQL queries against a
% connected LTPDA repository and retrieve selected objects to the workspace.
%

classdef LTPDARepositoryQuery < handle

  properties
    gui = [];   % handle to uifigure
  end

  methods

    function obj = LTPDARepositoryQuery(varargin)

      % Get a connection from the database connection manager
      conn = LTPDADatabaseConnectionManager().connect();

      obj.gui = buildQueryGUI(conn);

    end % End constructor

    function display(varargin) %#ok<VANUS>
    end

  end % methods

  methods (Access = protected)

    cb_guiClosed(varargin)
    cb_executeQuery(varargin)

  end

end


% =========================================================================
% Local GUI builder
% =========================================================================

function fig = buildQueryGUI(conn)

  fig = uifigure('Name', 'LTPDA Repository Query', ...
                 'Position', [150 150 900 600]);
  try
    set(fig, 'Theme', 'light');
  catch
  end

  % --- SQL input area ---
  uilabel(fig, 'Text', 'SQL query:', ...
    'Position', [10 565 80 20]);

  sqlField = uitextarea(fig, ...
    'Position', [10 490 880 70], ...
    'Value', 'SELECT obj_id, name, description, username, date FROM ltpda_objects LIMIT 100');

  % --- Results table ---
  uilabel(fig, 'Text', 'Results:', ...
    'Position', [10 465 80 20]);

  tbl = uitable(fig, ...
    'Position', [10 90 880 370], ...
    'ColumnSortable', true, ...
    'Multiselect', true, ...
    'RowStriping', 'on');

  % --- Status label ---
  statusLbl = uilabel(fig, 'Text', 'Ready.', ...
    'Position', [10 68 700 20], ...
    'FontColor', [0.4 0.4 0.4]);

  % --- Buttons ---
  uibutton(fig, 'Text', 'Execute query', ...
    'Position', [10 12 130 40], ...
    'ButtonPushedFcn', @(~,~) cbExecute(conn, sqlField, tbl, statusLbl, fig));

  uibutton(fig, 'Text', 'Retrieve selected to workspace', ...
    'Position', [155 12 230 40], ...
    'ButtonPushedFcn', @(~,~) cbRetrieve(tbl, conn, statusLbl, fig));

  uibutton(fig, 'Text', 'Close', ...
    'Position', [800 12 90 40], ...
    'ButtonPushedFcn', @(~,~) cbClose(conn, fig));

end


function cbExecute(conn, sqlField, tbl, statusLbl, fig)
  sql = strjoin(sqlField.Value, ' ');
  sql = strtrim(sql);
  if isempty(sql)
    statusLbl.Text = 'No query entered.';
    return
  end
  try
    stmt    = conn.createStatement();
    rs      = stmt.executeQuery(sql);
    meta    = rs.getMetaData();
    nCols   = meta.getColumnCount();

    % Read column names
    colNames = cell(1, nCols);
    for cc = 1:nCols
      colNames{cc} = char(meta.getColumnName(cc));
    end

    % Read rows
    rows = {};
    while rs.next()
      row = cell(1, nCols);
      for cc = 1:nCols
        val = rs.getObject(cc);
        if isempty(val)
          row{cc} = '';
        else
          row{cc} = char(val.toString());
        end
      end
      rows(end+1, :) = row; %#ok<AGROW>
    end
    rs.close();
    stmt.close();

    if isempty(rows)
      rows = repmat({''}, 1, nCols);
    end

    tbl.ColumnName = colNames;
    tbl.Data       = rows;
    statusLbl.Text = sprintf('Query returned %d row(s).', size(rows, 1));

  catch ex
    statusLbl.Text = ['Error: ' ex.message];
    uialert(fig, ex.message, 'Query failed');
  end
end


function cbRetrieve(tbl, conn, statusLbl, fig)
  rows = tbl.Data;
  if isempty(rows)
    uialert(fig, 'No results to retrieve.', 'Retrieve');
    return
  end

  % Find obj_id column
  colNames = tbl.ColumnName;
  objIdCol = find(strcmpi(colNames, 'obj_id'), 1);
  if isempty(objIdCol)
    uialert(fig, 'Results must contain an ''obj_id'' column to retrieve objects.', 'Retrieve');
    return
  end

  % Determine which rows are selected
  sel = tbl.Selection;
  if isempty(sel)
    uialert(fig, 'Select one or more rows first.', 'Retrieve');
    return
  end
  selRows = unique(sel(:, 1));

  % Get connection parameters from the JDBC URL
  meta     = conn.getMetaData();
  jdbcUrl  = char(meta.getURL());
  % Parse jdbc:mysql://hostname:port/database
  tok = regexp(jdbcUrl, 'jdbc:mysql://([^:/]+)(?::\d+)?/([^?]+)', 'tokens', 'once');
  if isempty(tok)
    uialert(fig, 'Cannot parse database URL from connection metadata.', 'Retrieve');
    return
  end
  hostname = tok{1};
  database = tok{2};

  statusLbl.Text = sprintf('Retrieving %d object(s)...', numel(selRows));
  drawnow;

  for kk = 1:numel(selRows)
    objIdStr = rows{selRows(kk), objIdCol};
    try
      objId = str2double(objIdStr);
      % Retrieve using the ao constructor with obj_id
      pl = plist('hostname', hostname, 'database', database, 'obj_id', objId);
      obj = ao(pl);
      varName = sprintf('obj_%d', round(objId));
      assignin('base', varName, obj);
      fprintf('Retrieved object %d -> workspace variable ''%s''\n', round(objId), varName);
    catch ex
      fprintf('Failed to retrieve obj_id %s: %s\n', objIdStr, ex.message);
    end
  end
  statusLbl.Text = sprintf('Retrieved %d object(s) to workspace.', numel(selRows));
end


function cbClose(conn, fig)
  try
    conn.close();
  catch
  end
  delete(fig);
end
