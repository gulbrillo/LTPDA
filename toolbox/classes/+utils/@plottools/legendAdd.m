% LEGENDADD Add a string to the current legend.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LEGENDADD Add a string to the current legend.
%
% CALL:        legendAdd(fig, 'string')
%              plot (curr_axes_handle, history, arg)
%
% INPUT:       fig    = figure handle (gcf, for example)
%              string = string to add
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function legendAdd(varargin)

  if nargin ~=2
    error('usage: legendAdd(fig, ''strin'')');
  end

  fig = varargin{1};
  strin = varargin{2};

  if ~ischar(strin)
    error('arg 2 is not a string > usage: legendAdd(fig, ''strin'')');
  end
  % if ~isobject(fig)
  %   error('arg 1 is not an object > usage: legendAdd(fig, ''strin'')');
  % end

  % get the current legend strings


  ch = get(gcf, 'Children');
  leg = [];

  for j=1:length(ch)

    tag = get(ch(j), 'Tag');

    if strcmp(tag, 'legend')
      leg = get(ch(j));
    end

  end
  str = [];
  % get(leg, 'XLabel')
  if ~isempty(leg)
    for j=length(leg.Children):-1:1

      ch = leg.Children(j);

      tag = get(ch, 'Tag');

      if ~strcmp(tag, '')

        str = strvcat(str, tag);
      end
    end
  end

  str = strvcat(str, strin);

  legend(str);

end

