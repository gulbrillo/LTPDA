% DISP display a pz object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP a pz object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  % Get pz objects
  objs = utils.helper.collect_objects(varargin(:), 'pz');

  % get display text
  txt = utils.helper.objdisp(objs);

  % display the objects
  if nargout > 0
    varargout{1} = txt;
  elseif nargout == 0;
    for j=1:numel(txt)
      disp(txt{j});
    end
  end
end

