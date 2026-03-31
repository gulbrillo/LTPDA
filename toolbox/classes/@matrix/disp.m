% DISP overloads display functionality for matrix objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for matrix objects.
%
% CALL:        txt    = disp(matrix)
%
% INPUT:       matrix - matrix object
%
% OUTPUT:      txt    - cell array with strings which displays the matrix object
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'disp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  objs = utils.helper.collect_objects(varargin(:), 'matrix');

  txt = {};

  % Print emtpy object
  if isempty(objs)
    hdr = sprintf('------ %s -------', class(objs));
    ftr(1:length(hdr)) = '-';
    txt = [txt; {hdr}];
    txt = [txt; sprintf('empty-object [%d,%d]',size(objs))];
    txt = [txt; {ftr}];
  end
  
  for ii = 1:numel(objs)
    banner = sprintf('---- matrix %d ----', ii);
    txt{end+1} = banner;

    % get key and value
    name  = objs(ii).name;

    % display
    txt{end+1} = ['       name: ' name];
    txt{end+1} = ['       size: ' num2str(size(objs(ii).objs, 1)) 'x' num2str(size(objs(ii).objs, 2))];
    for kk = 1:numel(objs(ii).objs)
      txt{end+1} = [sprintf('         %02d: %s | ', kk, class(objs(ii).objs(kk))) char(objs(ii).objs(kk))];
    end

    txt{end+1} = ['description: ' utils.prog.cutString(objs(ii).description, 120)];
    txt{end+1} = ['       UUID: ' objs(ii).UUID];
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

