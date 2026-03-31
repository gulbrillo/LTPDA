% DISP display a parameter value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP display a parameter value
%              Is called for the parameter value object when the semicolon is not used.
%
% CALL:        paramValue(1, {pi}, 0)
%              txt = disp(paramValue(1, {pi}, 0));
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
  objs = [varargin{:}];
  
  txt      = {};
  MAX_DISP = 60;
  
  for ii = 1:numel(objs)
    banner = sprintf('---- paramValue %d ----', ii);
    txt{end+1} = banner;
    
    %%%%%%%%%%%%%%%%%%%%   Add Property 'key'   %%%%%%%%%%%%%%%%%%%%
    if (objs(ii).valIndex >= 1)
      txt{end+1} = sprintf('used value: %s', utils.helper.val2str(objs(ii).getVal, 60));
      txt{end+1} = ' ';
    end
    
    options = utils.helper.val2str(objs(ii).options, MAX_DISP);
    
    txt{end+1} = sprintf(' val index: %s', mat2str(objs(ii).valIndex));
    txt{end+1} = sprintf('   options: %s', options);
    txt{end+1} = sprintf(' selection: %s', paramValue.getSelectionMode(objs(ii).selection));
    
    names = fieldnames(objs(ii).property);
    for nn = 1:numel(names)
      txt{end+1} = sprintf('%10s: %s', names{nn}, utils.helper.val2str(objs(ii).property.(names{nn})));
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

