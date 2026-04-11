% DISP implement terminal display for fsdata object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP implement terminal display for fsdata object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
  fsdatas = [varargin{:}];
  
  txt = {};
  
  for i=1:numel(fsdatas)
    fsd = fsdatas(i);
    
    % Call super class
    txt = [txt disp@data2D(fsd)];
    
    if numel(fsd.enbw) == 1
      txt{end+1} = sprintf('  enbw:  %g', fsd.enbw);
    else
      txt{end+1} = sprintf('  enbw:  [%d %d], %s', size(fsd.enbw), class(fsd.enbw));
    end
    txt{end+1} = sprintf('    fs:  %g', fsd.fs);
    txt{end+1} = sprintf('    t0:  %s', char(fsd.t0));
    txt{end+1} = sprintf('  navs:  %g', fsd.navs);
    
    banner_end(1:length(txt{1})) = '-';
    txt{end+1} = banner_end;
    
    txt{end+1} = ' ';
  end
  
  %%% Prepare output
  if nargout == 0
    for ii = 1:length(txt)
      disp(txt{ii});
    end
  elseif nargout == 1
    varargout{1} = txt;
  end
  
end

