% DISP overloads display functionality for smodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for smodel objects.
%
% CALL:        txt    = disp(smodel)
%
% INPUT:       smodel - ltpda model object
%
% OUTPUT:      txt    - cell array with strings to display the model object
%
% <a href="matlab:utils.helper.displayMethodInfo('smodel', 'disp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  objs = utils.helper.collect_objects(varargin(:), 'smodel');
  
  txt = {};
  
  % Print emtpy object
  if isempty(objs)
    hdr = sprintf('------ %s -------', class(objs));
    ftr(1:length(hdr)) = '-';
    txt = [txt; {hdr}];
    txt = [txt; sprintf('empty-object [%d,%d]',size(objs))];
    txt = [txt; {ftr}];
  end
  
  for ii=1:numel(objs)
    banner = sprintf('---- symbolic model %d ----', ii);
    txt{end+1} = banner;
    
    % get key and value
    name  = objs(ii).name;
    
    % display name
    txt{end+1} = ['       name: ' name];
    
    % display expression
    if isnumeric(objs(ii).expr)
      if numel(objs(ii).expr) > 30
        svals = [mat2str(objs(ii).expr(1:30))];
        svals = [svals(1:end-1) ' ...]'];
      else
        svals = mat2str(objs(ii).expr);
      end
      txt{end+1} = ['       expr: ' svals];
    else
      expr = char(objs(ii).expr);
      if numel(expr) > 100
        expr = expr(1:100);
      end
      txt{end+1} = ['       expr: ' expr];
    end
    
    % display params
    txt{end+1} = ['     params: ' utils.prog.cell2str(objs(ii).params)];    
    pstr = '{';
    for kk=1:numel(objs(ii).values)
      valstr = mat2str(objs(ii).values{kk});
      if length(valstr) > 30
        valstr = [valstr(1:30) '...]'];
      end
      if kk > 1
        pstr = [pstr ', ' valstr];
      else
        pstr = [pstr  valstr];
      end
    end
    pstr = [pstr '}'];
    
    % display values
    txt{end+1} = ['     values: ' pstr];
    
    % display xvar
    switch class(objs(ii).xvar)
      case 'char'
        sxvar = objs(ii).xvar;        
      case 'cell'
        sxvar = '{';
        for kk=1:numel(objs(ii).xvar)
          valstr = objs(ii).xvar{kk};          
          if kk > 1
            sxvar = [sxvar ', ' valstr];
          else
            sxvar = [sxvar  valstr];
          end
        end
        sxvar = [sxvar '}'];
      otherwise
        error(['### Wrong class ' class(objs(ii).xvals) ' for the property ''xvar''']);
    end
    txt{end+1} = ['       xvar: ' sxvar];
    
    % display trans
    switch class(objs(ii).trans)
      case 'char'
        strans = objs(ii).trans;
      case 'cell'
        strans = '{';
        for kk = 1:numel(objs(ii).trans)
          valstr = objs(ii).trans{kk};
          if kk > 1
            strans = [strans ', ' valstr];
          else
            strans = [strans  valstr];
          end
        end
        strans = [strans '}'];
      otherwise
        error(['### Wrong class ' class(objs(ii).trans) ' for the property ''trans''']);
    end
    txt{end+1} = ['      trans: ' strans];
    
    % display xvals
    switch class(objs(ii).xvals)
      case 'double'
        if numel(objs(ii).xvals) > 30
          svals = [mat2str(objs(ii).xvals(1:30))];
          svals = [svals(1:end-1) ' ...]'];
        else
          svals = mat2str(objs(ii).xvals);
        end
      case 'cell'
        svals = '{';
        for kk=1:numel(objs(ii).xvals)
          if isa(objs(ii).xvals{kk}, 'ao')
            valstr = ['[' class(objs(ii).xvals{kk}.data) ' ao]'];
          else
            valstr = mat2str(objs(ii).xvals{kk});
            if length(valstr) > 50
              valstr = [valstr(1:50) '...]'];
            end
          end
          if kk > 1
            svals = [svals ', ' valstr];
          else
            svals = [svals  valstr];
          end
        end
        svals = [svals '}'];
      case 'ao'
        svals = ['[' class(objs(ii).xvals.data) ' ao]'];
      otherwise
        error(['### Wrong class ' class(objs(ii).xvals) ' for the property ''xvals''']);
    end    
    txt{end+1} = ['      xvals: ' svals];
    
    % display xunits    
    txt{end+1} = sprintf('     xunits: %s', strtrim(char(objs(ii).xunits)));
    
    % display yunits
    txt{end+1} = sprintf('     yunits: %s', strtrim(char(objs(ii).yunits)));
    
    % display aliasNames
    txt{end+1} = sprintf(' aliasNames: %s', utils.helper.val2str(objs(ii).aliasNames));
    
    % display aliasValues
    txt{end+1} = sprintf('aliasValues: %s', utils.helper.val2str(objs(ii).aliasValues));
    
    % display description
    txt{end+1} = sprintf('description: %s', utils.prog.cutString(objs(ii).description, 120));
    
    % display UUID
    txt{end+1} = sprintf('       UUID: %s', objs(ii).UUID);
    
    banner_end(1:length(banner)) = '-';
    txt{end+1} = banner_end;
  end
    
  if nargout == 0
    for ii = 1:length(txt)
      disp(txt{ii});
    end
  else
    varargout{1} = txt;
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end
