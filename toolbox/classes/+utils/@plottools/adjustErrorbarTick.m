% ADJUSTERRORBARTICK Adjust the width of y-errorbars.
%                    The input W is given as a ratio of X axis length (1/W)
%
% CALL:
%         utils.plottools.adjustErrorbarTick(fh)
%         utils.plottools.adjustErrorbarTick(ah)
%
% INPUTS:
%         fh - Graphical handle (figure- or axes- handle)
%
function adjustErrorbarTick(hs, w)
  
  if nargin < 2
    w = 100;
  end
  
  for ii=1:numel(hs)
    
    h = hs(ii);
    
    % Check if we have a axes or figure handle
    if strcmp(get(h, 'type'), 'figure')
      % The handle is a figure handle
      ahs = findobj(h, 'type', 'axes', 'tag', '');
    elseif strcmp(get(h, 'type'), 'axes') && isempty(get(h, 'tag'))
      % The handle is a figure handle
      ahs = h;
    else
      error('Please provide only figure- or axes- handles');
    end
    
    for jj = 1:numel(ahs)
      
      ah = ahs(jj);
      dx = diff(get(ah, 'XLim'));
      w = dx/w;
      
      % The following code works only for MATLAB version equal or less than R2014a
      if verLessThan('MATLAB', '8.4')
        
        % Get all lines (lines with error bars are grouped to a hggroup object)
        lhs = findobj(ah, 'type', 'hggroup');
        
        for kk = 1:numel(lhs)
          
          lh = lhs(kk);
          eh = get(lh,'children');
          errVals  = get(eh(2),'xdata');
          
          errVals(4:9:end) = errVals(1:9:end)-w/2;
          errVals(7:9:end) = errVals(1:9:end)-w/2;
          errVals(5:9:end) = errVals(1:9:end)+w/2;
          errVals(8:9:end) = errVals(1:9:end)+w/2;
          
          set(eh(2),'xdata',errVals(:))	% Change error bars on the figure
          
        end % Loop: line handles
        
      else
        
        % Get all errorbar lines
        ehs = findobj(ah, 'type', 'errorbar');
        
        for kk = 1:numel(ehs)
          
          eh = ehs(kk);
          
          errVals = eh.Bar.VertexData(1,:);
          l  = length(errVals)/3;
          X  = errVals(1:l);     % error at x-Position
          DX = errVals(l+1:end); % +- values for 
          dp = length(errVals)/3;
          for asd = 1:l/2
            idx = asd*2;
            idxLeft  = [idx-1 l+idx-1];
            idxRight = [idx   l+idx];
            DX(idxLeft)  = X(idx)-w/2;
            DX(idxRight) = X(idx)+w/2;
          end
          eh.Bar.VertexData(1,1:end) = [X DX];
          
        end % Loop: errorbar handles
        
      end
      
    end % Loop: axes handles
  end % Loop: input handles
  
end
