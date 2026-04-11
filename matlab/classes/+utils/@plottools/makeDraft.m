% MAKEDRAFT labels a figure as draft, or not.
%
% utils.plottools.makeDraft(hfig)
% utils.plottools.makeDraft(hfig, state)
%

function makeDraft(varargin)
  
  hfig = gcf;
  if nargin > 0
    hfig = varargin{1};
  end
  
  isDraft = true;
  if nargin > 1
    isDraft = varargin{2};
  end
  
  lh = getLegends(hfig);
  
  for kk=1:numel(lh)
    if isDraft
      set(lh(kk), 'EdgeColor', 'k');
      set(lh(kk), 'Linewidth', 1);
    else
      set(lh(kk), 'EdgeColor', 'b');
      set(lh(kk), 'Linewidth', 3);
    end
  end
  
end


function h = getLegends(fh)
  
  h = [];
  for ff=1:numel(fh)
    children = get(fh(ff), 'children');
    for kk=1:numel(children)
      tag = get(children(kk), 'Tag');
      if strcmp(tag, 'legend')
        h = [h children(kk)];
      end
    end
  end
end

% END