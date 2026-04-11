% HORIZONTALLINE plots a horizontal line(s) to an axes handle.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HORIZONTALLINE plots a horizontal line(s) to an axes handle.
%
% CALL:        utils.plottools.horizontalLine(hax, double)
%              utils.plottools.horizontalLine(hax, ..., 'Label String')
%              utils.plottools.horizontalLine(hax, ..., {'Label 1', 'Label 2'})
%              utils.plottools.horizontalLine(gca, ...)
%        lhs = utils.plottools.horizontalLine(gca, ...) % returns line handles
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = horizontalLine(hax, varargin)
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Check first input
  if ~ishandle(hax)
    error('The first input must be a handle to the axes');
  end
  
  % Collect inputs
  allY = [];
  lbls = {};
  
  for ii = 1:numel(varargin)
    
    obj = varargin{ii};
    switch class(obj)
      case 'double'
        allY = [allY obj];
      case 'cell'
        if iscellstr(obj)
          lbls = [lbls obj];
        end
      case 'char'
        lbls = [lbls {obj}];
    end
  end
  
  % Get y-limits
  xLimits = get(hax, 'XLim');
  lhs = [];
  for ii=1:numel(allY)
    y = allY(ii);
    lh = line(xLimits, [y y], 'Parent', hax, 'Color', 'k', 'LineWidth', 3);
    lhs = [lhs lh];
    if ii <= numel(lbls)
      % Add a label box if the user have defined one.
      
      % Get axes position
      axPos = get(hax, 'Position');
      % Get x-limits
      yLimits = get(hax, 'YLim');
      
      % Convert the x- and y- values into normalized coordinates
      x = xLimits(2) - sum(abs(xLimits))*.9;
      xNorm = axPos(1) + ((x - xLimits(1))/(xLimits(2)-xLimits(1))) * axPos(3);
      yNorm = axPos(2) + ((y - yLimits(1))/(yLimits(2)-yLimits(1))) * axPos(4);
      
      % Replace underline "_" with "\_"
      lbl  = strrep(lbls{ii}, '_', '\_');
      
      hAnno = annotation('textarrow', [xNorm xNorm], [yNorm-0.015, yNorm], 'String' , lbl, 'FontSize', 15);
      try
        hAnno.pinAtAffordance(1);
        hAnno.pinAtAffordance(2);
      catch
      end
    end
  end
  
  if nargout > 0
    varargout{1} = lhs;
  end
end


