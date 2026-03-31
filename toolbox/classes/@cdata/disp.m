% DISP implement terminal display for cdata object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP implement terminal display for cdata object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
  argin = [varargin{:}];
  
  txt = {};
  
  for i=1:numel(argin)
    
    obj = argin(i);
    yname    = 'N-DEF';
    sydata   = [inf inf];
    syddata  = [inf inf];
    clydata  = '--- OBJECT NOT DEFINED ---';
    clyddata = '--- OBJECT NOT DEFINED ---';
    yunits   = '';
    if ~isempty(obj.yaxis)
      yname = obj.yaxis.name;
      sydata   = size(obj.yaxis.data);
      syddata  = size(obj.yaxis.ddata);
      clydata  = class(obj.yaxis.data);
      clyddata = class(obj.yaxis.ddata);
      yunits   = char(obj.yunits);
    end
    
    banner = sprintf('-------- cdata [%s] ------------', yname);
    txt{end+1} = banner;
    
    txt{end+1} = sprintf('     y:  [%dx%d], %s', sydata,  clydata);
    txt{end+1} = sprintf('    dy:  [%dx%d], %s', syddata, clyddata);
    txt{end+1} = sprintf('yunits:  %s', yunits);
    
    banner_end(1:length(banner)) = '-';
    txt{end+1} = banner_end;
    
    txt{end+1} = ' ';
  end
  
  if nargout == 0
    for ii = 1:length(txt)
      disp(txt{ii});
    end
  end
  
  varargout{1} = txt;
end

