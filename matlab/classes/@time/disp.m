% DISP display functionality for time objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Display functionality for time objects.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = disp(obj)

  out = {};
  for ii = 1:numel(obj)
    out{ii} = format(obj(ii));
  end
  out = reshape(out, size(obj));

  if nargout == 0
    disp(out);
  end

end
