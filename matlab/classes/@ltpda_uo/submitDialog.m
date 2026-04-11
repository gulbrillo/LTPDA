% SUBMITDIALOG Creates a connection and the sinfo structure depending of the input variables.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SUBMITDIALOG Creates a connection and the sinfo structure
%              depending of the input variables.
%
% CALL:        sinfo = submitDialog(sinfo_in, pl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sinfo = submitDialog(pl)

  % Copy input plist
  pl = copy(pl, 1);

  %%% Show dialog or not
  noDialog = pl.find_core('no dialog');

  %%% Create/fill sinfo from the plist.
  sinfo = getDefaultStruct();

  %%% Check If we should the sinfo from a file
  if ~isempty(pl.find_core('sinfo filename'))
    pl.combine(utils.xml.read_sinfo_xml(pl.find_core('sinfo filename')));
  end

  %%% Set the fields from the plist to the struct
  sinfo = setField(sinfo, pl, 'experiment title');
  sinfo = setField(sinfo, pl, 'experiment description');
  sinfo = setField(sinfo, pl, 'analysis description');
  sinfo = setField(sinfo, pl, 'quantity');
  sinfo = setField(sinfo, pl, 'keywords');
  sinfo = setField(sinfo, pl, 'reference ids');
  sinfo = setField(sinfo, pl, 'additional comments');
  sinfo = setField(sinfo, pl, 'additional authors');

  %%% Return because we have all sinfo information
  if  (allFieldsFilled(sinfo)) || ...
      (allMandatoryFieldsFilled(sinfo) && noDialog)
    return
  end

  %%% Show uifigure dialog (blocks until user submits or cancels)
  sinfo = showSubmitDialog(sinfo);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sinfo = showSubmitDialog(sinfo)
% Build a blocking uifigure submission-info dialog.

  fields = { ...
    'experiment_title',       'Experiment title *',       true; ...
    'experiment_description', 'Experiment description *', true; ...
    'analysis_description',   'Analysis description *',   true; ...
    'quantity',               'Quantity',                 false; ...
    'keywords',               'Keywords',                 false; ...
    'reference_ids',          'Reference IDs',            false; ...
    'additional_comments',    'Additional comments',       false; ...
    'additional_authors',     'Additional authors',        false; ...
  };
  nf = size(fields, 1);

  labelW  = 200;
  editW   = 350;
  rowH    = 28;
  padY    = 10;
  figW    = labelW + editW + 40;
  figH    = nf * (rowH + padY) + 90;

  fig = uifigure('Name', 'Repository submission info', ...
                 'Position', [200 100 figW figH], ...
                 'Resize', 'off');
  try
    set(fig, 'Theme', 'light');
  catch
  end
  fig.UserData = struct('sinfo', [], 'cancelled', true);

  editHandles = cell(nf, 1);
  for ii = 1:nf
    yPos = figH - 55 - (ii-1) * (rowH + padY);
    lbl  = fields{ii, 2};
    val  = sinfo.(fields{ii, 1});

    uilabel(fig, 'Text', lbl, ...
      'Position', [15 yPos labelW 22], ...
      'FontWeight', 'normal');

    editHandles{ii} = uieditfield(fig, 'text', ...
      'Value', val, ...
      'Position', [labelW + 20, yPos, editW, 22]);
  end

  btnY = 12;
  uibutton(fig, 'Text', 'Load XML...', ...
    'Position', [15 btnY 100 28], ...
    'ButtonPushedFcn', @(~,~) cbLoad(fig, fields, editHandles));

  uibutton(fig, 'Text', 'Save XML...', ...
    'Position', [125 btnY 100 28], ...
    'ButtonPushedFcn', @(~,~) cbSave(fig, fields, editHandles));

  uibutton(fig, 'Text', 'Submit', ...
    'Position', [figW - 220 btnY 95 28], ...
    'ButtonPushedFcn', @(~,~) cbSubmit(fig, fields, editHandles));

  uibutton(fig, 'Text', 'Cancel', ...
    'Position', [figW - 115 btnY 95 28], ...
    'ButtonPushedFcn', @(~,~) uiresume(fig));

  uiwait(fig);

  if isvalid(fig)
    ud = fig.UserData;
    delete(fig);
    if ud.cancelled
      sinfo = [];
    else
      sinfo = ud.sinfo;
    end
  else
    sinfo = [];
  end
end


function cbSubmit(fig, fields, editHandles)
  s = getDefaultStruct();
  for ii = 1:size(fields, 1)
    s.(fields{ii,1}) = strtrim(editHandles{ii}.Value);
  end
  % Validate mandatory fields
  if isempty(s.experiment_title) || isempty(s.experiment_description) || isempty(s.analysis_description)
    uialert(fig, 'Please fill in all mandatory fields (marked with *).', 'Missing fields');
    return
  end
  fig.UserData = struct('sinfo', s, 'cancelled', false);
  uiresume(fig);
end


function cbLoad(fig, fields, editHandles)
  [fn, pn] = uigetfile('*.xml', 'Load submission info XML');
  if isequal(fn, 0), return; end
  try
    sinfoPl = utils.xml.read_sinfo_xml(fullfile(pn, fn));
    for ii = 1:size(fields, 1)
      key1 = strrep(fields{ii,1}, '_', ' ');
      key2 = fields{ii,1};
      val = sinfoPl.find_core(key1);
      if isempty(val), val = sinfoPl.find_core(key2); end
      if ischar(val) && ~isempty(val)
        editHandles{ii}.Value = val;
      end
    end
  catch ex
    uialert(fig, ex.message, 'Failed to load XML');
  end
end


function cbSave(fig, fields, editHandles)  %#ok<INUSL>
  [fn, pn] = uiputfile('*.xml', 'Save submission info XML');
  if isequal(fn, 0), return; end
  s = getDefaultStruct();
  for ii = 1:size(fields, 1)
    s.(fields{ii,1}) = strtrim(editHandles{ii}.Value);
  end
  try
    utils.xml.save_sinfo_xml(fullfile(pn, fn), s);
  catch ex
    uialert(fig, ex.message, 'Failed to save XML');
  end
end


function sinfo = getDefaultStruct()
  sinfo = struct(...
    'experiment_title',       '', ...
    'experiment_description', '', ...
    'analysis_description',   '', ...
    'quantity',               '', ...
    'keywords',               '', ...
    'reference_ids',          '', ...
    'additional_comments',    '', ...
    'additional_authors',     '');
end


function res = allMandatoryFieldsFilled(sinfo)
  res = false;
  if isstruct(sinfo)
    if  isfield(sinfo, 'experiment_title')       && ~isempty(sinfo.experiment_title)       && ...
        isfield(sinfo, 'experiment_description') && ~isempty(sinfo.experiment_description) && ...
        isfield(sinfo, 'analysis_description')   && ~isempty(sinfo.analysis_description)
      res = true;
    end
  end
end


function res = allFieldsFilled(sinfo)
  res = false;
  if isstruct(sinfo)
    if  isfield(sinfo, 'experiment_title')       && ~isempty(sinfo.experiment_title)       && ...
        isfield(sinfo, 'experiment_description') && ~isempty(sinfo.experiment_description) && ...
        isfield(sinfo, 'analysis_description')   && ~isempty(sinfo.analysis_description) && ...
        isfield(sinfo, 'quantity')               && ~isempty(sinfo.quantity) && ...
        isfield(sinfo, 'keywords')               && ~isempty(sinfo.keywords) && ...
        isfield(sinfo, 'reference_ids')          && ~isempty(sinfo.reference_ids) && ...
        isfield(sinfo, 'additional_comments')    && ~isempty(sinfo.additional_comments) && ...
        isfield(sinfo, 'additional_authors')     && ~isempty(sinfo.additional_authors)
      res = true;
    end
  end
end


function sinfo = setField(sinfo, pl, field)
  struct_field = strrep(field, ' ', '_');

  if ~isfield(sinfo, struct_field)
    sinfo.(struct_field) = '';
  end

  if ~isempty(pl.find_core(field))
    sinfo.(struct_field) = pl.find_core(field);
  end
  if ~isempty(pl.find_core(strrep(field, ' ', '_')))
    sinfo.(struct_field) = pl.find_core(strrep(field, ' ', '_'));
  end
end
