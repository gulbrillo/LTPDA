% SORT the values in the AO.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SORT sorts the values in the input data.
%
% CALL: ao_out = sort(ao_in);
%       ao_out = sort(ao1, pl1, ao_vector, ao_matrix, pl2);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'sort')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = sort (varargin)
  
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
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  pl              = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);
  
  % Get parameters
  sdir = find_core(pl, 'dir');
  dim  = find_core(pl, 'dim');
  
  %% go through analysis objects
  for jj = 1:numel(bs)
    % Sort values
    switch lower(dim)
      case 'x'
        if isa(bs(jj).data, 'cdata')
          error('### Sort to the x-axis of an AO with cdata is not possible');
        end
        [mx, idx] = sort(bs(jj).data.getX, 1, sdir);
        my = bs(jj).data.y(idx);
      case 'y'
        [my, idx] = sort(bs(jj).y, 1, sdir);
        if ~isa(bs(jj).data, 'cdata')
          mx = bs(jj).data.getX(idx);
        end
      otherwise
        error('### can''t sort along dimension ''%s''.', dim);
    end
    
    % Sort the error dx and dy and enbw
    if isprop(bs(jj).data, 'dx')
      if numel(bs(jj).data.dx) > 1
        mdx = bs(jj).data.dx(idx);
      else
        mdx = bs(jj).data.dx;
      end
    else
      mdx = [];
    end
    if numel(bs(jj).data.dy) > 1
      mdy = bs(jj).data.dy(idx);
    else
      mdy = bs(jj).data.dy;
    end
    if isprop(bs(jj).data, 'enbw')
      if numel(bs(jj).data.enbw) > 1
        menbw = bs(jj).data.enbw(idx);
      else
        menbw = bs(jj).data.enbw;
      end
    else
      menbw = [];
    end
    
    % set new data
    if ~isa(bs(jj).data, 'cdata')
      bs(jj).data.setXY(mx,my);
    else
      bs(jj).data.setY(my);
    end
    
    % set new error
    if ~isempty(mdx)
      bs(jj).data.setDx(mdx);
    end
    if ~isempty(mdy)
      bs(jj).data.setDy(mdy);
    end
    if ~isempty(menbw)
      bs(jj).data.setEnbw(menbw);
    end
    
    % set data name
    bs(jj).name = sprintf('sort(%s)', ao_invars{jj});
    % Add history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), bs(jj).hist);
  end
  
  % Set output
  varargout = utils.helper.setoutputs(nargout, bs);
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.op, '', sets, pl);
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
  
  % Dim
  p = param({'dim', 'Sort on the specified axis.'}, {2, {'x', 'y'}, paramValue.SINGLE});
  pl.append(p);
  
  % Dir
  p = param({'dir', 'Direction of sort.'}, {1, {'ascend', 'descend'}, paramValue.SINGLE});
  pl.append(p);
end
% END

