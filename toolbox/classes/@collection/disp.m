% DISP overloads display functionality for collection objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for collection objects.
%
% CALL:        txt    = disp(collection)
%
% INPUT:       collection - collection object
%
% OUTPUT:      txt    - cell array with strings which displays the matrix object
%
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'disp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  colls = utils.helper.collect_objects(varargin(:), 'collection');

  txt = {};

  % Print emtpy object
  if isempty(colls)
    hdr = sprintf('------ %s -------', class(colls));
    ftr(1:length(hdr)) = '-';
    txt = [txt; {hdr}];
    txt = [txt; sprintf('empty-object [%d,%d]',size(colls))];
    txt = [txt; {ftr}];
  end
  
  for ii = 1:numel(colls)
    banner = sprintf('---- collection %d ----', ii);
    txt{end+1} = banner;

    % get key and value
    name  = colls(ii).name;

    % display
    txt{end+1} = ['       name: ' name];
    txt{end+1} = ['   num objs: ' num2str(numel(colls(ii).objs)) ];
    for kk=1:numel(colls(ii).objs)
      if isempty(colls(ii).objs{kk})
        txt{end+1} = [sprintf('         [%02d] %s: %s | ', kk, colls(ii).names{kk}, class(colls(ii).objs{kk})), 'empty-object'];
      else
        desc = utils.helper.val2str(colls(ii).objs{kk});
        Dlen = 1000;
        if length(desc) > Dlen
          desc = [desc(1:Dlen) '...'];
        end
        txt{end+1} = [sprintf('         [%02d] %s: %s | ', kk, colls(ii).names{kk}, class(colls(ii).objs{kk})) desc];
      end
    end

    txt{end+1} = ['description: ' utils.prog.cutString(colls(ii).description, 120)];
    txt{end+1} = ['       UUID: ' colls(ii).UUID];
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

