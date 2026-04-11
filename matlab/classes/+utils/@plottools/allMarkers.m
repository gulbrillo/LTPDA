% ALLMARKERS Set all the markers on the current axes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ALLMARKERS Set all the markers on the current axes.
%
% CALL:        utils.plottools.allMarkers(marker)
%              utils.plottools.allMarkers(marker, size)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allMarkers(varargin)
  
  marker = varargin{1};
  size = [];
  if nargin > 1
    size = varargin{2};
  end
  
  ch = get(gca, 'Children');
  for ll=1:numel(ch)
    if strcmpi(get(ch(ll), 'Type'), 'line')
      set(ch(ll), 'Marker', marker);
      if ~isempty(size)
        set(ch(ll), 'MarkerSize', size);
      end
    end
  end

end

% END