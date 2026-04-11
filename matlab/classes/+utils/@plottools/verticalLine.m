% VERTICALLINE plots a vertical line(s) to an axes handle.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: VERTICALLINE plots a vertical line(s) to an axes handle.
%
% CALL:        utils.plottools.verticalLine(hax, time-object)
%              utils.plottools.verticalLine(hax, double)
%              utils.plottools.verticalLine(hax, ..., 'Label String')
%              utils.plottools.verticalLine(hax, ..., {'Label 1', 'Label 2'})
%              utils.plottools.verticalLine(gca, ...)
%        lhs = utils.plottools.verticalLine(gca, ...) % returns line handles
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = verticalLine(hax, varargin)
  
  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Check first input
  if ~ishandle(hax)
    error('The first input must be a handle to the axes');
  end
  
  % Get the UserData from the axes.
  t0 = time(0);
  axesData = get(hax, 'UserData');
  if isa(axesData, 'plist')
    t0 = axesData.find_core('t0');
  elseif isa(axesData, 'time')
    t0 = axesData;
  end
  
  % Collect inputs
  allX = [];
  lbls = {};
  
  for ii = 1:numel(varargin)
    
    obj = varargin{ii};
    switch class(obj)
      case 'time'
        allX = [allX [obj.utc_epoch_milli]/1e3 - t0.utc_epoch_milli/1e3];
      case 'double'
        allX = [allX obj];
      case 'cell'
        if iscellstr(obj)
          lbls = [lbls obj];
        end
      case 'char'
        lbls = [lbls {obj}];
    end
  end
  
  % Get y-limits
  yLimits = get(hax, 'YLim');
  lhs = [];
  for ii=1:numel(allX)
    x = allX(ii);
    lh = line([x x], yLimits, 'Parent', hax, 'Color', 'k', 'LineWidth', 3);
    lhs = [lhs lh];
    if ii <= numel(lbls)
      % Add a label box if the user have defined one.
      
      % Get axes position
      axPos = get(hax, 'Position');
      % Get x-limits
      xLimits = get(hax, 'XLim');
      
      % Convert the x- and y- values into normalized coordinates
      y = yLimits(2) - sum(abs(yLimits))*.1;
      xNorm = axPos(1) + ((x - xLimits(1))/(xLimits(2)-xLimits(1))) * axPos(3);
      yNorm = axPos(2) + ((y - yLimits(1))/(yLimits(2)-yLimits(1))) * axPos(4);
      
      % Replace underline "_" with "\_"
      lbl  = strrep(lbls{ii}, '_', '\_');
      
      hAnno = annotation('textarrow', [xNorm+.015 xNorm], [yNorm, yNorm], 'String' , lbl, 'FontSize', 15);
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


