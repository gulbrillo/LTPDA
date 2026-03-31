% SAVE overloads save operator for ltpda objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SAVE overloads save operator for ltpda objects.
%
% CALL:        save(obj, 'blah.mat') Save an object obj as a .mat file.
%              obj.save('blah.mat')  Save an object obj as a .mat file.
%              obj.save(plist('filename', 'blah.mat'))
%              save(obj, plist('filename', 'blah.mat'))
%              save(a, 'blah.xml') Save an object as an XML file.
%              a.save(plist('filename', 'blah.xml'))
%
% The method accepts multiple input objects (in a list or in a vector),
% that will be save inside a single file or in multiple files according to the
% "INDIVIDUAL FILES" parameter (see the Parameters Description below)
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uo', 'save')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = save(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  persistent matlabVersion
  
  if isempty(matlabVersion)
    matlabVersion = ver('MATLAB');
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  %%% Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  [objsIn, objinvars, rest] = utils.helper.collect_objects(varargin(:), '', in_names);
  [pls,  invars, rest] = utils.helper.collect_objects(rest(:), 'plist', in_names);
  
  %%% REMARK: Special case for the plist-class because collect_objects collects
  %%%         ALL plist-objects even the plist which should set the property.
  %%%         In this case must be the plist which sets thte property
  %%%         at the last position.
  if isa(objsIn, 'plist')
    if nparams(objsIn(end)) == 1 && isparam(objsIn(end), 'filename')
      pls = [pls objsIn(end)];
      objsIn(end) = [];
    end
  end
  
  %%% Combine the plists
  pls = applyDefaults(getDefaultPlist(), pls);
  
  % Decide on a deep copy or a modify
  objsIn = copy(objsIn, nargout);

  %%%
  % 1. Use the filename from the PLIST
  % 2. Use the input string as the filename
  % 3. Use the object name and the current folder for the filename
  %    Must be defined for each object.
  % 4. If there are more than one input objects and the 'individual files'
  %    Switch is false then use the variable name.
  filename = '';
  if ~isempty(pls.find_core('filename'))
    filename = pls.find_core('filename');
  elseif ~isempty(rest) && numel(rest) == 1 
    if iscellstr(rest)
      filename = rest{1};
    elseif isobject(rest{1})
      % support any object which responds to char()
      filename = char(rest{1});
    else
      error('Unknown inputs.');
    end
    
    pls.pset('filename', filename);
  end
  
  %%% Make sure that the UUID is set for all objects. This should only
  %%% happen for PLISTs.
  %%% REMARK: This command will also change the plist in the workspace.
  for ii = 1:numel(objsIn)
    if isempty(objsIn(ii).UUID)
      objsIn(ii).UUID = char(java.util.UUID.randomUUID);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Save object   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Inspect filename
  [path, fname, ext] = fileparts(filename);
  
  % Save the objects as MAT files if the user doesn't specify a extension type
  if isempty(ext)
    ext = '.mat';
  end
  
  % Get pre-, and postfix from the input PLIST
  prefix  = pls.find_core('prefix');
  postfix = pls.find_core('postfix');
  
  individualFiles = pls.find_core('individual files');
  
  % ATTENTION: We keep the meaning of t0 for backwards compatibility.
  %            This means
  %              - before saving, t0 = t0 + toffset
  %              - after loading, t0 = t0 - toffset
  %            But be careful. For XML files it is done in the tsdata
  %            methods 'attachToDom' and 'fromDom' because for submitting
  %            we don't use this method.
  
  switch ext
    case '.mat'
      
      % ATTENTION: We moved the changing to the t0 to the MATLAB methods:
      % tsdata/loadobj and tsdata/saveobj.
      % NOTE: this copy is also needed so we can clear the axis and figure
      % handles below without affecting the user's objects.
      objs = copy(objsIn, 1);
      
      % clear the figure and axis handles before saving to MAT file.
      if isa(objs, 'ltpda_uoh')
        objs.setPlotAxes([]);
        objs.setPlotFigure([]);
      end
      
      if (individualFiles == true)
        
        %%%%% Save each object in individual file
        dummy = objs;
        for ii = 1:numel(dummy)
          objs = dummy(ii);
          % Define full filename
          if isempty(fname)
            useName = objs.name;
            if isempty(useName)
            end
            fullFilename = getFullFilename(objs.name);
          else
            postfix = sprintf('%s_%03d', pls.find_core('postfix'), ii);
            fullFilename = getFullFilename(fname);
          end
          utils.helper.msg(msg.PROC1, 'Saving to file: %s', fullFilename);
          save(fullFilename, 'objs');
        end
        
      else
        
        %%%%% Save all objects in one file
        if isempty(fname)
          fullFilename = getFullFilename(inputname(1));
          warning('!!! You have not specified any file name -> Using first variable name as file name.');
        else
          fullFilename = getFullFilename(fname);
        end
        
        utils.helper.msg(msg.PROC1, 'Saving to file: %s', fullFilename);
        save(fullFilename, 'objs', '-v7');
      end
      
    case '.xml'
      
      if (individualFiles == true)
        %%%%% Save each object in individual file
        
        for ii = 1:numel(objsIn)
          if isempty(fname)
            fullFilename = getFullFilename(objsIn(ii).name);
          else
            postfix = sprintf('%s_%03d', pls.find_core('postfix'), ii);
            fullFilename = getFullFilename(fname);
          end
          saveObjectAsXML(objsIn(ii), fullFilename);
        end
        
      else
        %%%%% Save all objects in one file
        if isempty(fname)
          fullFilename = getFullFilename(inputname(1));
          warning('!!! You have not specified any file name -> Using first variable name as file name.');
        else
          fullFilename = getFullFilename(fname);
        end
        
        saveObjectAsXML (objsIn, fullFilename);
      end
      
      
    otherwise
      error('### unknown file extension [%s].', ext);
  end
  
  varargout{1} = objsIn;
  
  %--------------------------------------------------------------------------
  % Return the full file name
  %--------------------------------------------------------------------------
  function fullFilename = getFullFilename(fname)
    
    if isempty(fname)
      error('Please specify a filename, or set a name to the objects you are trying to save.');
    end
    
    % concatenate the prefix, filename, postfix and the file extension.
    fname = strcat(prefix, fname, postfix, ext);
    
    % build full filename
    fullFilename = fullfile(path, fname);
    
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% save object as XML file
%--------------------------------------------------------------------------
function saveObjectAsXML (obj, fullFilename)
  
  import utils.const.*
  utils.helper.msg(msg.PROC1, 'Saving to file: %s', fullFilename);
  
  % clear the internal cache of history UUIDs from history/attachToDom
  clear history/attachToDom
  
  % Create DOM node
  dom = com.mathworks.xml.XMLUtils.createDocument('ltpda_object');
  parent = dom.getDocumentElement;
  
  % add Attribute 'ltpda_version' to the root node
  ltpda_version = getappdata(0, 'ltpda_version');
  parent.setAttribute('ltpda_version', ltpda_version);
  
  if  (utils.helper.ver2num(ltpda_version) > utils.helper.ver2num('2.3')) || ...
      (strcmp(strtok(ltpda_version), '2.3'))
    %%%%%%%%%%%%%%%%%%   saving of a new XML file   %%%%%%%%%%%%%%%%%%
    
    % Create history root node
    % The attachToDom methods will attach their histories to this node.
    historyRootNode = dom.createElement('historyRoot');
    parent.appendChild(historyRootNode);
    
    % Write objects    
    obj.attachToDom(dom, parent, []);
    
  else
    %%%%%%%%%%%%%%%%%%   saving of a old XML file   %%%%%%%%%%%%%%%%%%
    utils.xml.xmlwrite(obj, dom, parent, '');    % Save the XML document.
  end
  
  % Write to file
  
  % Ingo: I want to use our own XML write method because I miss on my
  %       machine the indent.
  if isempty(strfind(fullFilename, filesep))
    result = javax.xml.transform.stream.StreamResult(fullfile(pwd, fullFilename));
  else
    result = javax.xml.transform.stream.StreamResult(fullFilename);
  end
  mpipeline.utils.XMLUtils.serializeXML(dom, result, 'UTF-8')
  %   xmlwrite(fullFilename, dom);
  
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
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
  ii.setOutmin(0);
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
  % General plist for saving objects
  pl = plist.SAVE_OBJ_PLIST;
  
end

