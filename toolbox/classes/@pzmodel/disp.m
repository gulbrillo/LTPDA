% DISP overloads display functionality for pzmodel objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for pzmodel objects.
%
% CALL:        txt     = disp(pzmodel)
%
% INPUT:       pzmodel - pole/zero model object
%
% OUTPUT:      txt     - cell array with strings to display the pole/zero model object
%
% <a href="matlab:utils.helper.displayMethodInfo('pzmodel', 'disp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  objs = utils.helper.collect_objects(varargin(:), 'pzmodel');

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
    banner = sprintf('---- pzmodel %d ----', ii);
    txt{end+1} = banner;

    % get key and value
    name  = objs(ii).name;
    desc  = objs(ii).description;
    g     = objs(ii).gain;
    del   = objs(ii).delay;
    ps    = objs(ii).poles;
    zs    = objs(ii).zeros;
    np    = numel(ps);
    nz    = numel(zs);
    iunit = char(objs(ii).iunits);
    ounit = char(objs(ii).ounits);

    % display
    txt{end+1} = ['       name: ' name];
    txt{end+1} = ['       gain: ' num2str(g)];
    txt{end+1} = ['      delay: ' num2str(del)];
    txt{end+1} = ['     iunits: ' iunit];
    txt{end+1} = ['     ounits: ' ounit];
    txt{end+1} = ['description: ' utils.prog.cutString(desc, 120)];
    txt{end+1} = ['       UUID: ' objs(ii).UUID];

    for jj = 1:np
      txt{end+1} = [sprintf('pole %03d: ', jj) char(ps(jj)) ];
    end
    for jj = 1:nz
      txt{end+1} = [sprintf('zero %03d: ', jj) char(zs(jj)) ];
    end

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
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end

