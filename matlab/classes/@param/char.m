% CHAR convert a param object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a param object into a string.
%
% CALL:        string = char(obj)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  objs = [varargin{:}];

  pstr = '';
  for ii = 1:numel(objs)
    key = objs(ii).defaultKey;
    val = utils.helper.val2str(objs(ii).getVal, 60);
    pstr = sprintf('%s%s=%s, ', pstr, key, val);
  end

  % remove last ', '
  if length(pstr)>1
    pstr = pstr(1:end-2);
  end

  %%% Prepare output
  varargout{1} = pstr;
end

