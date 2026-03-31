% ALLLINES Set all the line styles and widths on the current axes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ALLLINES Set all the line styles and widths on the current axes.
%
% CALL:        utils.plottools.allLines(style)
%              utils.plottools.allLines(style, width)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allLines(varargin)
  
  style = varargin{1};
  width = [];
  if nargin > 1
    width = varargin{2};
  end
  
  ch = get(gca, 'Children');
  for ll=1:numel(ch)
    if strcmpi(get(ch(ll), 'Type'), 'line')
      set(ch(ll), 'LineStyle', style);
      if ~isempty(width)
        set(ch(ll), 'LineWidth', width);
      end
    end
  end

end
% END