% DISP display a parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP display a parameter
%              Is called for the parameter object when the semicolon is not used.
%
% CALL:        param('a', 1)
%              txt = disp(param('a', 1));
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
  objs = [varargin{:}];
  
  txt = {};
  
  for ii = 1:numel(objs)
    banner = sprintf('---- param %d ----', ii);
    txt{end+1} = banner;
    
    % get key and value
    name = objs(ii).key;
    v    = objs(ii).getVal;
    desc = objs(ii).desc;
    props = objs(ii).getProperties;
    
    %%%%%%%%%%%%%%%%%%%%   Add Property 'key'   %%%%%%%%%%%%%%%%%%%%
    if ischar(name)
      txt{end+1} = ['key:    ' name];
    elseif iscellstr(name)
      if isempty(name)
        altNames = '';
      else
        altNames = name{1};
        for nn=2:numel(name)
          altNames = sprintf('%s, %s', altNames, name{nn});
        end
      end
      txt{end+1} = ['key:    ' altNames];
    else
      error('### The key is not a string or a cell of strings');
    end
    
    %%%%%%%%%%%%%%%%%%%%   Add Property 'val'   %%%%%%%%%%%%%%%%%%%%
    
    if isstruct(v)
      %%%%%%%%%%   Special case: structures
      txt{end+1} = 'val:  structure';
      nv = numel(v);
      for ss = 1:nv
        if nv > 1, txt{end+1} = sprintf('       --- struct %02d ---', ss); end
        vs = v(ss);
        fields = fieldnames(vs);
        for kk=1:length(fields)
          field = fields{kk};
          val   = vs.(field);
          txt{end+1} = ['       ' field ':  ' utils.helper.val2str(val, 60)];
        end
      end
    else
      %%%%%%%%%%   All other cases
      txt{end+1} = sprintf('val:    %s', utils.helper.val2str(v, 60));
    end
    
    %%%%%%%%%%%%%%%%%%%%   Add property 'description'   %%%%%%%%%%%%%%%%%%%%
    %%% Display the description only if it is not empty
    if ~isempty(desc)
      
      if iscell(desc)
        txt{end+1} = ['desc:   ' desc(1,:)];
        for kk = 2:size(desc,1)
          txt{end+1} = ['       ' desc(kk,:)];
        end
      else
        txt{end+1} = ['desc:   ' desc];
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%   Add property 'origin'   %%%%%%%%%%%%%%%%%%%%
      
    txt{end+1} = ['origin: ' objs(ii).origin];
    
    
    %%%%%%%%%%%%%%%%%%%%   Add possible properties   %%%%%%%%%%%%%%%%%%%%
    %%% Display the 'properties' only if it is not empty
    if ~isempty(props)
      fns     = fieldnames(props);
      propStr = sprintf('%s=%s', fns{1}, utils.helper.val2str(props.(fns{1})));
      for pp = 2: numel(fns)
        propStr = sprintf('%s, %s=%s', propStr, fns{pp}, utils.helper.val2str(props.(fns{pp})));
      end
      txt{end+1} = ['props: ' propStr];
    end
    
    banner_end(1:length(banner)) = '-';
    txt{end+1} = banner_end;
    
  end
  
  %%% Prepare output
  if nargout == 0
    for ii=1:length(txt)
      disp(sprintf(txt{ii}));
    end
  elseif nargout == 1
    varargout{1} = txt;
  end
  
end


