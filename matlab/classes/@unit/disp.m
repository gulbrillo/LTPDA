% DISP display an unit object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP display an unit object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  % Get unit objects
  objs = [varargin{:}];

  % get display text
  txt = utils.helper.objdisp(objs);

  % display the objects
  if nargout > 0
    varargout{1} = txt;
  elseif nargout == 0;
    for jj = 1:numel(txt)
      disp(txt{jj});
    end
  end
end

