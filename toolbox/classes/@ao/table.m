% TABLE display the data from the AO in a table.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:   TABLE display the data from the AO in a table.
%
% CALL:          table(ao)
%                table(ao, plist)
%
% DOCUMENTATION: - The table shows only one x-axis if all x values of all
%                  input AOs are the same.
%                - You have to select the value if you want to export the
%                  data.
%                - You can use a PLIST with the parameter singleTable = false
%                  if you want that each AO get its own table.
% 
% NOTE: this does not support xyzdata objects.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'table')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = table(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all AOs
  [as, ao_invars, rest] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl = utils.helper.collect_objects(rest(:), 'plist');
  
  pl = applyDefaults(getDefaultPlist(), pl);
  
  singleTable = pl.find_core('singleTable');
  
  x = java.util.ArrayList();
  y = java.util.ArrayList();
  xt = java.util.ArrayList();
  yt = java.util.ArrayList();
  
  % Loop over AOs
  for jj = 1:numel(as)
    
    if isa(as(jj).data, 'xyzdata')
      % The table doesn'T work for xyzdata
      error('### The table doesn''t work for AOs with xyz-data');
    elseif isa(as(jj).data, 'cdata')
      for kk = 1:size(as(jj).y, 2)
        data = as(jj).y;
        y.add(data(:,kk));
        x.add([]);
        yt.add('const');
        xt.add([]);
      end
    else
      x.add(as(jj).x);
      y.add(as(jj).y);
      xt.add(sprintf('%s: x %s', ao_invars{jj}, char(as(jj).xunits)));
      yt.add(sprintf('%s: y %s', ao_invars{jj}, char(as(jj).yunits)));
    end
    
    if ~singleTable
      d = datatable.TableForm(x,y,xt,yt);
      d.setVisible(true);
      d.setTitle(as(jj).name);
      x.clear();
      y.clear();
      xt.clear();
      yt.clear();
    end
  end
  if singleTable
    d = datatable.TableForm(x,y,xt,yt);
    d.setVisible(true);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
  ii.setModifier(false);
  ii.setOutmin(0);
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
  
  p = param({'singleTable','Display the AOs in a single talbe.'}, paramValue.TRUE_FALSE);
  pl.append(p);
  
end


