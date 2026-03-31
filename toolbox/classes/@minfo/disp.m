% DISP display an minfo object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP display an minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  % Get minfo objects
  objs = utils.helper.collect_objects(varargin(:), 'minfo');

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

