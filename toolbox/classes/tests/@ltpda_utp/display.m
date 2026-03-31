% DISPLAY overloads display functionality for ltpda_utp objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISPLAY overloads display functionality for ltpda_utp objects.
%
% CALL:        txt     = display(obj)
%
% INPUT:       obj - ltpda_utp object
%
% OUTPUT:      txt     - cell array with strings to display the ltpda_utp object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = display(varargin)

  % Get specwin objects
  objs = utils.helper.collect_objects(varargin(:), 'ltpda_utp');

  % get display text
  txt = utils.helper.objdisp(objs);

  if nargout == 0
    for ii=1:length(txt)
      disp(txt{ii});
    end
  else
    varargout{1} = txt;
  end

end

