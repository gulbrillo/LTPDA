% ISSTABLE tells if ssm is numerically stable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISSTABLE tells if ssm is numerically stable
%
%              val = sys.isStable
%
% <a href="matlab:utils.helper.displayMethodInfo('ssm', 'isStable')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = isStable(varargin)
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  objs = utils.helper.collect_objects(varargin(:), 'ssm', in_names);
  pl = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Combine plists
  pl = parse(pl, getDefaultPlist);
  
  dbg = find(pl,'debug');
  if dbg
  utils.helper.msg(utils.const.msg.MNAME, ['running ', mfilename]);
  end
  
  for i=1:numel(objs)
    if ~objs(i).isnumerical  % checking system is numeric
      error(['error in double : system named ' objs(i).name ' is not numeric']);
    end
    A = ssm.blockMatFusion(objs(i).amats, objs(i).sssizes, objs(i).sssizes);
    Ts = objs(i).timestep;
    if Ts == 0
      vp = eig(A);
      f = find(real(vp)>5e-15);
      f2 = find(real(vp)>0);
      if dbg
        display((vp(f)));
      end
    else
      try
        vp = eig(A^1024);
      catch ME
        vp = eig(A);
      end
      f = find(abs(vp)>1+5e-12);
      f2 = find(abs(vp)>1);
      if dbg
        display((vp(f)));
      end
    end
    ninst = numel(f);
    ninst2 = numel(f2);
    isst(i) = ninst==0;
    if ninst>0;
      if dbg
        display(['warning, system named "' objs(i).name '" is not stable'])
      end
    elseif ninst2>0;
      if dbg
        display(['warning, system named "' objs(i).name '" might be numerically unstable'])
      end
    else
      if dbg
        display(['System named "' objs(i).name '" is stable'])
      end
    end
  end
  varargout ={isst};
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
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function pl = buildplist()
  pl = plist();
  
  % debug info
  p = param({'debug','Set to TRUE to display warning messages. '}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end

