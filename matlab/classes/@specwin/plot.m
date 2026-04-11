% PLOT plots a specwin object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLOT plots a specwin object.
%
% CALL:            plot(specwin)
%              h = plot(specwin)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = plot(varargin)

  % Get specwin objects
  ws = [varargin{:}];

  hl = [];

  hold on
  grid on;

  colors = getappdata(0,'ltpda_default_plot_colors');

  titleStr  = '';
  legendStr = '';

  for i=1:numel(ws)
    w   = ws(i);
    if ~isempty(w.win)
      win = w.win;
    else
      dummy = specwin(w.type, 100);
      win = dummy.win;
    end
    hl  = [hl plot(win)];
    col = colors{mod(i-1,length(colors))+1};
    set(hl(end), 'Color', col);
    xlabel('sample');
    ylabel('amplitude');
    titleStr = [titleStr, utils.prog.label(w.type), ', '];
    lstr = [sprintf('alpha = %g\n', w.alpha)...
      sprintf('psll = %g\n', w.psll)...
      sprintf('rov = %g\n', w.rov)...
      sprintf('nenbw = %g\n', w.nenbw)...
      sprintf('w3db = %g\n', w.w3db)...
      sprintf('flatness = %g\n', w.flatness)];
    legendStr = [legendStr cellstr(lstr)];
  end

  legend(legendStr);
  titleStr = titleStr(1:end-2);
  title(sprintf('Window: %s', titleStr));

  if nargout > 0
    varargout{1} = hl;
  end

  hold off
end

