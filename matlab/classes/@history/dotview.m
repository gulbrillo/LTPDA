% DOTVIEW view history of an object via the DOT interpreter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DOTVIEW view history of an object via the DOT interpreter. 
% 
% The history is converted to a dot file (www.graphviz.org) then: 
% 1) rendered to the format specified inside the user's LTPDA Toolbox Preferences
% (accessible via the dedicated GUI or typing "LTPDAprefs" on the Matlb terminal) 
% 2) opened with the chosen viewer. 
% 3) The graphic file is kept.
%
% CALL:        dotview(h, pl);
%              dotview(h, 'my_filename');
%              dotview(h);                % Displays only the diagram
%
% INPUTS:      h   - history object
%              pl  - plist of options
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = dotview(varargin)

  % get global variables
  prefs = getappdata(0, 'LTPDApreferences');
  DOT    = char(prefs.getExternalPrefs.getDotBinaryPath);
  FEXT   = char(prefs.getExternalPrefs.getDotOutputFormat);

  %%% Set inputs
  objs = utils.helper.collect_objects(varargin(:), 'history');
  pl   = utils.helper.collect_objects(varargin(:), 'plist');
  fn   = utils.helper.collect_objects(varargin(:), 'char');

  pl = combine(pl, getDefaultPlist);

  view        = find_core(pl, 'view');
  iformat     = find_core(pl, 'format');
  if ~isempty(fn)
    filename = fn;
  else
    filename = find_core(pl, 'filename');
  end
  
  % Create tempoary filename 
  if isempty(filename)
    filename = fullfile(tempdir, 'ltpda_dotview.pdf');
  end
  if ~isempty(iformat)
    FEXT = iformat;
  end
  
  for jj=1:numel(objs)
    
    [path, name, ext] = fileparts(filename);

    % Convert ssm to a tmp dot file
    tname   = tempname;
    dotfile = [tname '.dot'];
    outfile = fullfile(path, [name '.' FEXT]);

    % Make DOT file
    hist2dot(objs(jj), dotfile, pl);

    % Write to graphics file
    cmd = sprintf('%s -T%s -o %s %s', DOT, FEXT, outfile, dotfile);
    system(cmd);

    % View graphics file
    if view
      if any(strcmpi(FEXT, {'gif', 'ico', 'jpg', 'jpeg', 'jpe', 'png', 'tiff'}))
        figure();
        image(imread(outfile));
        set(gca, 'Position', [0 0 1 1])
        set(gca, 'Visible', 'off')
      else
        open(outfile);
      end
    end
    
    % Delete tmp dotfile
    delete(dotfile);
  end  
 
end


%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plo = getDefaultPlist()
  
  % Use the "factory" plist
  plo = plist.DOTVIEW_PLIST;
  
end

