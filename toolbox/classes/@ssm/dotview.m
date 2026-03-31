% DOTVIEW  view an ssm object via the DOT interpreter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DOTVIEW view an ssm object via the DOT interpreter. 
% 
% The ssm object is converted to a dot file (www.graphviz.org) then: 
% 1) rendered to the format specified inside the user's LTPDA Toolbox Preferences
% (accessible via the dedicated GUI or typing "LTPDAprefs" on the Matlb terminal) 
% 2) opened with the chosen viewer. 
% 3) The graphic file is kept.
%
% CALL:        dotview(s, pl);
%              dotview(s, 'my_filename');
%              dotview(s);                % Displays only the diagram
%
% INPUTS:      h   - ssm object
%              pl  - plist of options
% 
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'dotview')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = dotview(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % get global variables
  prefs = getappdata(0, 'LTPDApreferences');
  DOT    = char(prefs.getExternalPrefs.getDotBinaryPath);
  FEXT   = char(prefs.getExternalPrefs.getDotOutputFormat);
  
  %%% Set inputs
  objs = utils.helper.collect_objects(varargin(:), 'ssm');
  pl   = utils.helper.collect_objects(varargin(:), 'plist');
  fn   = utils.helper.collect_objects(varargin(:), 'char');
  
  pl = combine(pl, getDefaultPlist);
  
  view     = find(pl, 'view');
  iformat  = find(pl, 'format');
  if ~isempty(fn)
    filename = fn;
  else
    filename = find(pl, 'filename');
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
    ssm2dot(objs(jj), plist('filename', dotfile));
    
    % Write to graphics file
    cmd = sprintf('%s -T%s -o %s %s', DOT, FEXT, outfile, dotfile);
    system(cmd);
    
    % View graphics file
    if view
      if any(strcmpi(FEXT, {'gif', 'ico', 'jpg', 'jpeg', 'jpe', 'png', 'tiff'}))
        image(imread(outfile));
      else
        open(outfile);
      end
    end
    
    % Delete tmp dotfile
    delete(dotfile);
    
  end
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
  ii.setOutmin(0);
  ii.setOutmax(0);
end


%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plo = getDefaultPlist()
  
  % Use the "factory" plist
  plo = plist.DOTVIEW_PLIST;
  
end
