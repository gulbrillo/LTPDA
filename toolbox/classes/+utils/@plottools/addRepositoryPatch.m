% ADDPLOTPROVENANCE adds a discrete text label to a figure with details of
% the LTPDA version, and the calling function from which the plot was made.
%
function addRepositoryPatch(fh, subpl)
  
  if ~ishghandle(fh)
    error('First input should be a graphics handle');
  end
  
  
  % ensure the figure is current
  figure(fh);
  
  % check if an annotation object is already present
  annoString = 'LTPDA_REPO_ANNOTATION';
  hAxis = getAnnoObject(fh, annoString);
  
  xoff = 0.5;
  yoff = 0.95;
  
  if isempty(hAxis)
    % Create annotation message
    msg = createAnnoMsg(subpl);
    
    hAxis = axes('units', 'normalized', 'pos', [0 0 1 1], 'visible', 'off', 'handlevisibility', 'on');
    set(hAxis, 'Tag', annoString);
    th = text(0,1, utils.prog.strjoin(msg, ', '), 'parent', hAxis);
    set(th, 'Units', 'normalized');
    set(th, 'HorizontalAlignment', 'center');
    set(th, 'FontSize', 10);
    set(th, 'Color', [0.6 0.6 0.8]);
    set(th, 'Tag', annoString);
    uistack(hAxis,'bottom');
    
    extent = get(th, 'Extent');
    pos = [xoff    1-extent(4)/2-yoff    0];
    set(th, 'position', pos);
  else
    % set the text
    th = getAnnoObject(hAxis, annoString);
    msg = createAnnoMsg(subpl);
    set(th, 'String', utils.prog.strjoin(msg, ', '));
    extent = get(th, 'Extent');
    pos = [xoff extent(4)+yoff 0];
    set(th, 'position', pos);
    uistack(hAxis,'bottom');
  end
  
  % make draft
  utils.plottools.makeDraft(fh, false);
  
end

function h = getAnnoObject(fh, annoString)
  
  h = [];
  children = get(fh, 'children');
  for kk=1:numel(children)
    tag = get(children(kk), 'Tag');
    if strcmp(tag, annoString)
      h = children(kk);
      break;
    end
  end
end

function msg = createAnnoMsg(pl)
  uuidStr = getUUIDFromPl(pl);
  idStr  = getIDFromPl(pl);
  msg{1}     = sprintf('hostname: %s', pl.mfind('submit_hostname', 'hostname'));
  msg{end+1} = sprintf('database: %s', pl.mfind('submit_database', 'database'));
  msg{end+1} = sprintf('ids: %s', idStr);
  msg{end+1} = sprintf('uuids: %s', uuidStr);
  
  msg = strrep(msg, '_', '\_');
end

function uuidStr = getUUIDFromPl(pl)
  % Check if the PLIST have a 'UUIDS' key
  uuids = pl.find('uuids');
  if isempty(uuids)
    % Get UUID from the database
    uuids = utils.repository.getUUIDfromID(pl);
  end
  if ~isempty(uuids)
    uuids = cellstr(uuids); % Make sure that 'uuids' is a cell-array
    uuidStr = sprintf('%s, ', uuids{:});
    uuidStr = uuidStr(1:end-2);
  else
    uuidStr = 'unknown';
  end
end

function idStr = getIDFromPl(pl)
  id = pl.find('ids');
  if isempty(id)
    idStr = mat2str(utils.repository.getIDfromUUID(pl));
  else
    idStr = mat2str(pl.find('id'));
  end
end


