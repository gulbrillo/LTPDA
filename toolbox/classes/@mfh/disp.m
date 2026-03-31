% DISP overloads display functionality for mfh objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for mfh objects.
%
% CALL:        txt = disp(f)
%
% INPUT:       f  - mfh object
%
% OUTPUT:      txt - cell array with strings to display the timespan object
%
% <a href="matlab:utils.helper.displayMethodInfo('mfh', 'disp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect all mfh objects
  objs = utils.helper.collect_objects(varargin(:), 'mfh');
  
  txt = {};
  
  % Print emtpy object
  if isempty(objs)
    hdr = sprintf('------ %s -------', class(objs));
    ftr(1:length(hdr)) = '-';
    txt = [txt; {hdr}];
    txt = [txt; sprintf('empty-object [%d,%d]',size(objs))];
    txt = [txt; {ftr}];
  end
  
  for kk=1:numel(objs)
    
    banner = sprintf('------ mfh %d -------', kk);
    txt{end+1} = banner;
    txt{end+1} = ' ';
    txt{end+1} = char(objs(kk));
    txt{end+1} = ' ';
    txt{end+1} = sprintf('       name: %s', objs(kk).name');
    txt{end+1} = sprintf('       func: %s', objs(kk).funcDef);
    txt{end+1} = sprintf('     params: %s', char(objs(kk).paramsDef));
    txt{end+1} = ' ';
    
    % Display the sub-functions
    subStr = getSubFuncStr(objs(kk));
    txt{end+1} = sprintf('   subfuncs: %s', subStr{1});
    for ss=2:numel(subStr)
      txt{end+1} = sprintf('             %s', subStr{ss});
    end
    
    % Display the input and the input object if they exist
    inputStr = getStrFromField(objs(kk), 'inputs', 'inputObjects');
    txt{end+1} = sprintf('     inputs: %s', inputStr{1});
    for ii=2:numel(inputStr)
      txt{end+1} = sprintf('             %s', inputStr{ii});
    end
    
    % Display the constants and the constant object if they exist
    constStr = getStrFromField(objs(kk), 'constants', 'constObjects');
    txt{end+1} = sprintf('  constants: %s', constStr{1});
    for ii=2:numel(constStr)
      txt{end+1} = sprintf('             %s', constStr{ii});
    end
    
    txt{end+1} = sprintf('    numeric: %d', objs(kk).numeric);
    txt{end+1} = sprintf('description: %s', objs(kk).description);
    txt{end+1} = sprintf('       UUID; %s', objs(kk).UUID);
    banner_end(1:length(banner)) = '-';
    txt{end+1} = banner_end;
  end
  
  if nargout == 0
    for ii=1:length(txt)
      disp(txt{ii});
    end
  else
    varargout{1} = txt;
  end
  
end

function s = getSubFuncStr(obj)
  if isempty(obj.subfuncs)
    s = {''};
  else
    firstPart = cell(size(obj.subfuncs));
    for ii=1:numel(obj.subfuncs)
      subObj = obj.subfuncs(ii);
      if ~isempty(subObj.inputs)
        inputStr = sprintf('%s, ', subObj.inputs{:});
      else
        inputStr = '  '; % Fill with two dummy blanks because we remove the last two.
      end
      firstPart{ii} = sprintf('@%s(%s)', subObj.name, inputStr(1:end-2));
    end
    maxFirstPartLen = max(cellfun(@length, firstPart));
    for ii=1:numel(firstPart)
      firstPart{ii} = sprintf('%1$-*2$s: %3$s', firstPart{ii}, maxFirstPartLen, obj.subfuncs(ii).func);
    end
    s = firstPart;
  end
end

function sOut = getStrFromField(obj, field, fieldObj)
  if isempty(obj.(field))
    sOut = {''};
  else
    sOut = {};
  end
  for ii=1:numel(obj.(field))
    maxInputLen = max(cellfun(@length, obj.(field)));
    s = sprintf('%1$*2$s', sprintf('''%s''', char(obj.(field){ii})), maxInputLen-2);
    if numel(obj.(fieldObj)) >= ii
      if isstruct(obj.(fieldObj){ii})
        nn = fieldnames(obj.(fieldObj){ii});
        s = sprintf('%s, structure with fields %s <= ', s);
        for kk = 1:numel(nn)
          s = [s, '<= ', nn{kk}, ' '];
        end
      else
        val = obj.(fieldObj){ii};
        s = sprintf('%s <= %s', s, utils.helper.val2str(val));
      end
    else
      %       s = sprintf('%s not defined', s);
    end
    sOut{end+1} = s;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  ii.setModifier(false);
  ii.setOutmin(0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end

