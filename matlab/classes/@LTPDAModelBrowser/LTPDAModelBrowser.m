% LTPDAModelBrowser — graphical browser for LTPDA built-in models.
%
% CALL: LTPDAModelBrowser
%
% Opens a uifigure listing all built-in models grouped by class.
% Select a model to view its description and documentation, or press
% "View documentation" to open the full help page.
%

classdef LTPDAModelBrowser < handle

  properties
    gui = [];   % handle to uifigure
  end

  methods

    function obj = LTPDAModelBrowser(varargin) %#ok<VANUS>

      % Collect model data as plain MATLAB structs
      modelData = LTPDAModelBrowser.generateModelData();

      % Build uifigure
      obj.gui = buildBrowserGUI(modelData);

    end % End constructor

  end % public methods


  methods (Access = private, Static = true)

    function modelData = generateModelData()
    % Returns a struct array: modelData(ii).class, .model, .fullname, .describe, .doc

      classes    = utils.helper.ltpda_userclasses;
      modelData  = struct('class', {}, 'model', {}, 'fullname', {}, 'describe', {}, 'doc', {});

      for kk = 1:numel(classes)
        cl = classes{kk};
        if strcmp(cl, 'time'), continue; end

        try
          mdls = eval([cl '.getBuiltInModels()']);
          mdls = mdls(:, 1)';
        catch
          continue
        end

        for jj = 1:numel(mdls)
          model      = mdls{jj};
          model_name = [cl '_model_' model];
          try
            descr = eval([model_name '(''describe'')']);
            doc   = eval([model_name '(''doc'')']);
          catch
            descr = '(no description)';
            doc   = '';
          end
          entry.class    = cl;
          entry.model    = model;
          entry.fullname = [cl '/' model];
          entry.describe = descr;
          entry.doc      = doc;
          modelData(end+1) = entry; %#ok<AGROW>
        end
      end
    end

  end % private static methods

end


% =========================================================================
% Local GUI builder
% =========================================================================

function fig = buildBrowserGUI(modelData)

  fig = uifigure('Name', 'LTPDA Model Browser', ...
                 'Position', [100 100 900 600]);
  try
    set(fig, 'Theme', 'light');
  catch
  end

  if isempty(modelData)
    uilabel(fig, 'Text', 'No built-in models found.', ...
      'Position', [20 280 400 30], 'FontSize', 14);
    return
  end

  % Build list labels "class / model"
  labels = cellfun(@(c, m) [c '  /  ' m], ...
    {modelData.class}, {modelData.model}, 'UniformOutput', false);

  % --- Left: model list ---
  uilabel(fig, 'Text', 'Models:', 'Position', [10 570 200 22]);
  lb = uilistbox(fig, ...
    'Items', labels, ...
    'Position', [10 50 310 515]);

  % --- Right: description / doc panel ---
  uilabel(fig, 'Text', 'Documentation:', 'Position', [330 570 200 22]);
  docArea = uitextarea(fig, ...
    'Position', [330 50 560 515], ...
    'Editable', 'off', ...
    'Value', 'Select a model on the left.');

  % Wire selection callback now that docArea is defined
  lb.ValueChangedFcn = @(src, ~) cbSelect(src, modelData, docArea, fig);

  % --- Bottom button ---
  uibutton(fig, 'Text', 'View documentation', ...
    'Position', [330 10 180 32], ...
    'ButtonPushedFcn', @(~, ~) cbViewDoc(lb, modelData));

  uibutton(fig, 'Text', 'Close', ...
    'Position', [800 10 90 32], ...
    'ButtonPushedFcn', @(~, ~) delete(fig));
end


function cbSelect(lb, modelData, docArea, fig) %#ok<INUSL>
  idx = find(strcmp({modelData.fullname}, strrep(lb.Value, '  /  ', '/')), 1);
  if isempty(idx), return; end
  md  = modelData(idx);
  txt = {['Class:  ' md.class], ['Model:  ' md.model], '', md.describe, '', md.doc};
  docArea.Value = txt;
end


function cbViewDoc(lb, modelData)
  idx = find(strcmp({modelData.fullname}, strrep(lb.Value, '  /  ', '/')), 1);
  if isempty(idx), return; end
  try
    utils.models.displayModelOverview(modelData(idx).fullname);
  catch ex
    fprintf('Could not display model overview: %s\n', ex.message);
  end
end
