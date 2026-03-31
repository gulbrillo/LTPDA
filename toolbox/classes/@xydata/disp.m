% DISP overloads display functionality for xydata objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for xydata objects.
%
% CALL:        txt    = disp(xy)
%
% INPUT:       xy - xydata object
%
% OUTPUT:      txt    - cell array with strings to display the xydata object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)
  
  xydatas = [varargin{:}];
  
  txt = {};
  
  for i=1:numel(xydatas)
    xy = xydatas(i);
    
    % Call super class
    txt = [txt disp@data2D(xy)];
    
    banner_end(1:length(txt{1})) = '-';
    txt{end+1} = banner_end;
    
    txt{end+1} = ' ';
  end
  
  if nargout == 0
    for ii = 1:length(txt)
      disp(txt{ii});
    end
  elseif nargout == 1
    varargout{1} = txt;
  end
end


