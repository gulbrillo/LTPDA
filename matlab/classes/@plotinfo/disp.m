% DISP display a plotinfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP display a plotinfo
%              Is called for the plotinfo object when the semicolon is not used.
%
% CALL:        
%              txt = disp(pi);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
  objs = [varargin{:}];
  
  txt = {};
  
  for ii = 1:numel(objs)
    
    obj = objs(ii);
    
    banner = sprintf('---- plotinfo %d ----', ii);
    txt{end+1} = banner;
    
    if ~isempty(obj.style)
      txt{end+1} = ['style: ' char(obj.style.toString())];
    else
      txt{end+1} = 'style: <none>';
    end
    txt{end+1} = sprintf('includeInLegend: %d', obj.includeInLegend);
    txt{end+1} = sprintf('showErrors: %d', obj.showErrors);
    txt{end+1} = sprintf('figure: %g', double(obj.figure));
    txt{end+1} = sprintf('axes: %g', double(obj.axes));
    
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


