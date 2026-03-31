% CHAR convert a plotinfo object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a plotinfo object into a string.
%
% CALL:        string = char(obj)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  objs = [varargin{:}];

  pstr = '';
  for ii = 1:numel(objs)
    obj = objs(ii);
    pstr = sprintf('%s[Style: %s, includeInLegend: %d, showErrors: %d, figure: %s, axes: %s], ', ...
      pstr, char(obj.style.toString()), obj.includeInLegend, obj.showErrors, mat2str(obj.figure), mat2str(obj.axes));
  end

  % remove last ', '
  if length(pstr)>1
    pstr = pstr(1:end-2);
  end

  %%% Prepare output
  varargout{1} = pstr;
end

