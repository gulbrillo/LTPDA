% CHAR convert a param object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a history object into a string.
%
% CALL:        string = char(hist)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)
  
  objs  = [varargin{:}];
  
  hstr = '';
  
  for ii = 1:numel(objs)
    cl = getObjectClass(objs(ii));
    if ~isempty(cl)
      str = sprintf('%s.hist', cl);
    else
      str = sprintf('empty-history');
    end
    hstr = [hstr str ' / '];
  end
  
  hstr = hstr(1:end-2);
  
  varargout{1} = hstr;
end

