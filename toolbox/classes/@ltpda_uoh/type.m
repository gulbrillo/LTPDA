% TYPE converts the input objects to MATLAB functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TYPE converts the input objects to MATLAB functions that
%              reproduce the processing steps that led to the input objects.
%
% CALL:        type(as)
%              type(as, 'filename')
%              type(as, plist)
%
% INPUTS:      as  - array of ltpda_uoh objects
%              pl  - parameter list (see below)
%
% OUTPUTS:     none.
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uoh', 'type')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = type(varargin)

  import utils.const.*
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all objects and plists
  [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ltpda_uoh', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(rest, 'plist', in_names);

  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  filename = find_core(pl, 'filename');

  % Check for filename
  if isempty(filename)
    if ~isempty(rest)
      if strcmp(rest{1}(end-1:end), '.m')
        filename = rest{1};
      else
        filename = fullfile(rest{1}, '.m');
      end
    end
  end
    
  % Go through each input object
  for jj = 1:numel(as)  
    % convert to commands
    if isempty(as(jj).hist)
      fcn(jj).cmds{1} = ['a_out = ' class(as(jj)) ';'];
    else
      fcn(jj).cmds = hist2m(as(jj).hist, pl.find('stop_option'));
    end
  end % End object loop
  
  %----- Output to screen
  if isempty(filename)
    
    txts = {};
    for jj = 1:numel(fcn)
      txt = '';
      % Header
      LL = 25;
      txt = [txt utils.prog.strpad('', [LL LL], '-') sprintf('\n')];
      txt = [txt utils.prog.strpad(as(jj).name, [LL LL], '-') sprintf('\n')];
      txt = [txt utils.prog.strpad('', [LL LL], '-') sprintf('\n')];
      txt = [txt ' ' sprintf('\n')];
      
      % Print each command
      for kk=numel(fcn(jj).cmds):-1:1
        c = fcn(jj).cmds{kk};
        txt = [txt utils.prog.cutString(c, 25000) sprintf('\n')];
      end
      
      % Footer
      txt = [txt ' ' sprintf('\n')];
      txt = [txt utils.prog.strpad('', [LL LL], '-') sprintf('\n')];
      txt = [txt utils.prog.strpad(as(jj).name, [LL LL], '-') sprintf('\n')];
      txt = [txt utils.prog.strpad('', [LL LL], '-') sprintf('\n')];
      txt = [txt ' ' sprintf('\n')];
      txts = [txts txt];
    end
    
    if nargout == 0
      for kk = 1:numel(txts)
        disp(txts{kk})
      end
    else
      [varargout{1:nargout}] = txts{:};
    end
    
    return
    
  %----- Output to file  
  else
    
    % clear this m-file from memory
    clear(filename);
  
    % Open the file
    ii = getInfo;
    fd = fopen(filename, 'w+');
    [path, name, ext] = fileparts(filename);
    
    % Write help header
    fprintf(fd, '%% %s \n', upper(filename));
    fprintf(fd, '%% \n');
    fprintf(fd, '%% \n');
    fprintf(fd, '%% written by %s / %s\n', mfilename, ii.mversion);
    fprintf(fd, '%% \n');
    fprintf(fd, '%% \n');
    fprintf(fd, ' \n');
    fprintf(fd, ' \n');
    
    % write main fcn
    fprintf(fd, 'function out = %s\n\n', name);
    fprintf(fd, 'out = [];\n');
    for jj = 1:numel(as)
      fprintf(fd, 'out = [out obj%03d];\n', jj);
    end
    fprintf(fd, '\nend\n\n');
    
    % Write each sub function
    for kk = 1:numel(fcn)
      % header
      fprintf(fd, '%% sub-function for object %s\n', as(kk).name);
      fprintf(fd, 'function a_out = obj%03d\n\n', kk);
      % write command for this function
      for jj = numel(fcn(kk).cmds):-1:1
        fprintf(fd, '\t%s\n', fcn(kk).cmds{jj});
      end
      % Footer
      fprintf(fd, '\nend\n\n');
    end
    
    fprintf(fd, '\n\n%% END\n');
    
    % Close file
    fclose(fd);
    % This somehow forces the new file to be available to MATLAB
    cd ('.');
  end
  
  if nargout > 0
    varargout{1} = {};
  end
  
end


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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
  ii.setModifier(false);
  ii.setOutmin(0);
  ii.setOutmax(0);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist();

  p = param({'filename', 'specify the filename to write the commands in.'} , {1, {''}, paramValue.OPTIONAL});
  pl.append(p);

  pl.append(plist.HISTORY_TREE_PLIST);
  
end

