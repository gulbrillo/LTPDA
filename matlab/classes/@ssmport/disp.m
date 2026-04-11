% DISP display an ssmport object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP display an ssmport object.
%
% CALL FOR PARAMETERS:
%
%              obj.disp('INFO') % Retrieve method information
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
    for j=1:numel(txt)
      disp(txt{j});
    end
  end
end

