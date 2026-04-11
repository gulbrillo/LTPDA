% DISP overloads display functionality for specwin objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for specwin objects.
%
% CALL:        txt     = disp(specwin)
%
% INPUT:       specwin - spectral window object
%
% OUTPUT:      txt     - cell array with strings to display the spectral window object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  % Get specwin objects
  objs = [varargin{:}];

  % get display text
  txt = utils.helper.objdisp(objs);

  if nargout == 0
    for ii = 1:length(txt)
      disp(txt{ii});
    end
  else
    varargout{1} = txt;
  end

end

