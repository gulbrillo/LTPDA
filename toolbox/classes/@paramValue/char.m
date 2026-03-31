% CHAR convert a paramValue object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a paramValue object into a string.
%
% CALL:        string = char(obj)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  objs = [varargin{:}];

  pstr = '';
  for ii = 1:numel(objs)
    pstr = sprintf('%s%s, ', pstr, utils.helper.val2str(objs(ii).options{objs(ii).valIndex}));
  end

  % remove last ', '
  if length(pstr)>1
    pstr = pstr(1:end-2);
  end

  %%% Prepare output
  varargout{1} = pstr;
end

