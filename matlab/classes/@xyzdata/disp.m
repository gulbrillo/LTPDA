% DISP overloads display functionality for xyzdata objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for xyzdata objects.
%
% CALL:        txt    = disp(xyzdata)
%
% INPUT:       xyzdata - an xyz data object
%
% OUTPUT:      txt    - cell array with strings to display the xyzdata object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  xyzdatas = utils.helper.collect_objects(varargin(:), 'xyzdata');

  txt = {};

  for ii = 1:numel(xyzdatas)
    xyz = xyzdatas(ii);

    % Call super class
    txt = [txt disp@data3D(xyz)];
    
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

