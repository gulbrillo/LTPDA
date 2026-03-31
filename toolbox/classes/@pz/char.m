% CHAR convert a pz object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a pz object into a string.
%
% CALL:        string = char(obj)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  objs = utils.helper.collect_objects(varargin(:), 'pz');

  pstr = '';
  for ii = 1:numel(objs)
    pp   = objs(ii);
    % f and Q
    pstr = [pstr  sprintf('(f=%g Hz, Q=%g, ri=%s), ', pp.f, pp.q, mat2str(pp.ri(1), 4))];
  end

  %%% Prepare output
  varargout{1} = pstr(1:end-2);
end

