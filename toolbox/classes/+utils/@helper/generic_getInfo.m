% GENERIC_GETINFO generic version of the getInfo function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GENERIC_GETINFO generic version of the getInfo function
%
% CALL:        ii = generic_getInfo(varargin{:}, 'class_name');
%
% INPUTS:      varargin:   Function inputs of the class version of getInfo
%              class_name: Class name which calls this function.
%
% OUTPUT:      minfo-class of the method
%
% EXAMPLES:    Constructor call to get all sets
%                specwin.getInfo()
%                specwin.getInfo('specwin')
%                specwin.getInfo('specwin', '')
%
%              Constructor call to get a specified set
%                specwin.getInfo('specwin', 'None')
%                specwin.getInfo('specwin', 'set')
%
%              Call for the methods in a class
%                specwin.getInfo('char')
%                specwin.getInfo('char', 'None')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = generic_getInfo(varargin)
  
  class_name = varargin{end};
  
  % Set verout to an empty string because the static methods
  % <CLASS_NAME>.VEROUT doesn't exist anymore
  verout = '';
  sets   = feval(sprintf('%s.SETS', class_name));
  
  if  nargin == 1 || ...
      (nargin == 2 && strcmp(varargin{1}, class_name)) || ...
      (nargin == 3 && strcmp(varargin{1}, class_name) && isempty(varargin{2}))
    
    %%%%%%%%%% Get the minfo-object for the Constructor
    %%% specwin.getInfo()
    %%% specwin.getInfo('specwin')
    %%% specwin.getInfo('specwin', '')
    if ~isempty(sets)
      pls(1:numel(sets)) = plist();
      for kk = 1:numel(sets)
        cmd = sprintf('%s.getDefaultPlist', class_name);
        pls(kk) = feval(cmd, sets{kk});
      end
    else
      pls = plist;
    end
    ii = minfo(class_name, class_name, 'ltpda', 'Constructor', verout, sets, pls);
    ii.setModifier(false);
    ii.setArgsmin(0);
    ii.setArgsmax(-1);
    ii.setOutmin(1);
    ii.setOutmax(1);
    
  elseif nargin == 3 && (strcmp(varargin{1}, class_name))
    
    %%%%%%%%%% Get the minfo-object for the Constructor with a specified set
    %%% specwin.getInfo('specwin', 'None')
    %%% specwin.getInfo('specwin', 'set')
    if strcmpi(varargin{2}, 'None')
      sets = {};
      pls  = [];
    else
      sets = cellstr(varargin{2});
      cmd = sprintf('%s.getDefaultPlist', class_name);
      pls  = feval(cmd, varargin{2});
    end
    
    ii = minfo(class_name, class_name, 'ltpda', 'Constructor', verout, sets, pls);
    ii.setModifier(false);
  else
    
    %%%%%%%%%% Get the minfo-object for the class methods
    %%% specwin.getInfo('char')
    %%% specwin.getInfo('char', 'None')
    if nargin == 2
      sets = '';
    elseif nargin == 3
      sets = varargin{2};
    end
    
    try
      % This will work for all LTPDA user classes
      fcn = sprintf('%s.initObjectWithSize', class_name);
      obj = feval(fcn, 0, 0);
    catch
      % We come here if the user uses a command like:
      %   ltpda_uoh.getInfo('type');
      cls = utils.helper.ltpda_classes;
      metaA = meta.class.fromName(class_name);
      
      for jj=1:numel(cls)
        cl    = cls{jj};
        metaB = meta.class.fromName(cl);
        
        % metaA > metaB: Use to determine if metaA is a strict superclass of metaB
        if metaA > metaB && ismethod(cl, varargin{1})
          try
            fcn = sprintf('%s.initObjectWithSize', cl);
            obj = feval(fcn, 0, 0);
            break
          end
        end
      end % FOR
      %       error('### From the abstract class [%s] it is only possible to get the minfo class from the constructor.', class_name);
    end
    ii = feval(varargin{1}, obj, 'INFO', sets);
  end
  
  % check we got an minfo object
  if ~isa(ii, 'minfo')
    error('### An minfo object was not retrieved.');
  end
end

function scls = getSuperClasses (scls, meta)
  
  if ~isempty(meta.SuperClasses)
    
    scl = [meta.SuperClasses{:}];
    scls = [scls, {scl(:).Name}];
    
    for ii = 1:numel(meta.SuperClasses)
      scls = getSuperClasses(scls, meta.SuperClasses{1});
    end
  end
  
end

