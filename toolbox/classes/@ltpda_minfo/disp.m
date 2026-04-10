% DISP display an ltpda_minfo object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP display an ltpda_minfo object.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  % Get ltpda_minfo objects
  objs = utils.helper.collect_objects(varargin(:), 'ltpda_minfo');

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

