% DISP implement terminal display for analysis object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP implement terminal display for analysis object.
%
% CALL:        txt = disp(ao)
%              ao                     % without a semicolon
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'disp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
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
  
  % Loop over AOs
  txt = {};
  
  % Print emtpy object
  if isempty(as)
    hdr = sprintf('------ %s -------', class(as));
    ftr(1:length(hdr)) = '-';
    txt = [txt; {hdr}];
    txt = [txt; sprintf('empty-object [%d,%d]',size(as))];
    txt = [txt; {ftr}];
  end
  
  for jj = 1:numel(as)
    banner_start = sprintf('----------- ao %02d: %s -----------', jj, ao_invars{jj});
    
    txt{end+1} = banner_start;
    txt{end+1} = ' ';
    if isempty(as(jj).name)
      txt{end+1} = '       name: ''''';
    else
      txt{end+1} = sprintf('       name: %s', as(jj).name);
    end
    if isempty(as(jj).data)
      txt{end+1} = sprintf('       data: None');
    else
      dtxt = sprintf('       data:');
      if isa(as(jj).data, 'data3D')
        % do nothing
      else
        mi = min(5, numel(as(jj).data.getY));
        if ~isa(as(jj).data, 'cdata')
          for k = 1:mi
            dtxt = [dtxt sprintf(' (%s,%s)', mat2str(as(jj).data.getX(k)), mat2str(as(jj).data.getY(k)))];
          end
          if mi < length(as(jj).data.getY)
            dtxt = [dtxt ' ...'];
          end
        else
          mi = min(10, numel(as(jj).data.getY));
          for k = 1:mi
            dtxt = [dtxt sprintf(' %s', mat2str(as(jj).data.getY(k)))];
          end
          if mi < numel(as(jj).y)
            dtxt = [dtxt ' ...'];
          end
        end
      end
      txt{end+1} = dtxt;
      
      % Add some data info
      w = disp(as(jj).data);
      for k=1:numel(w)
        txt{end+1} =  sprintf('             %s', w{k});
      end
    end
    if isempty(as(jj).hist)
      txt{end+1} = sprintf('       hist: None');
    else
      info = as(jj).hist.methodInfo;
      txt{end+1} = sprintf('       hist: %s / %s / %s', info.mclass, info.mname, info.mversion);
    end
    desc = utils.prog.cutString(as(jj).description, 120);
    desc = strrep(desc, sprintf('\n'), sprintf('\n             '));
    txt{end+1} = sprintf('description: %s', desc);
    txt{end+1} = sprintf('   timespan: %s', char(as(jj).timespan));
    txt{end+1} = sprintf('       UUID: %s', as(jj).UUID);
    
    banner_end(1:length(banner_start)) = '-';
    txt{end+1} = banner_end;
    
    txt{end+1} = ' ';
    txt{end+1} = ' ';
  end
  
  if nargout == 0
    for ii = 1:length(txt)
      disp(txt{ii});
    end
  else
    varargout{1} = txt;
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
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end


