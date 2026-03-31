

function LTPDAprintf(style, format, varargin)
  
  % Process the text string
  str = sprintf(format,varargin{:});
  
  % Get the normalized style name and underlining flag
  style = processStyleInfo(style);
  
  % Get the current CW position
  cmdWinDoc = com.mathworks.mde.cmdwin.CmdWinDocument.getInstance;
  lastPos = cmdWinDoc.getLength;
  
  % Display a hyperlink element in order to force element separation
  % (otherwise adjacent elements on the same line will me merged)
  fprintf('<a href=""> </a>');
  
  % Get a handle to the Command Window component
  xCmdWndView = com.mathworks.mde.cmdwin.XCmdWndView.getInstance();
  
  % Store the CW background color as a special color pref
  % This way, if the CW bg color changes (via File/Preferences),
  % it will also affect existing rendered strs
  com.mathworks.services.Prefs.setColorPref('CW_BG_Color', xCmdWndView.getBackground);
  
  % Display the text in the Command Window
  cmdWinDoc = com.mathworks.mde.cmdwin.CmdWinDocument.getInstance();
  jStr = java.lang.String(str);
  cmdWinDoc.flushBuffer(jStr.toCharArray, 0, jStr.length, false)
  
  drawnow;
  docElement = cmdWinDoc.getParagraphElement(lastPos+1);
  
  % Set the leading hyperlink space character ('_') to the bg color, effectively hiding it
  % Note: old Matlab versions have a bug in hyperlinks that need to be accounted for...
  tokens = docElement.getAttribute('SyntaxTokens');
  try
    styles = tokens(2);
    styles(end-1) = java.lang.String('CW_BG_Color');
    styles(end) = java.lang.String(style);
  end
  
  % Get the Document Element(s) corresponding to the latest fprintf operation
  while docElement.getStartOffset < cmdWinDoc.getLength
    % Set the last Element token to the requested style:
    setElementStyle(docElement, style);
    
    docElement2 = cmdWinDoc.getParagraphElement(docElement.getEndOffset+1);
    if isequal(docElement,docElement2),  break;  end
    docElement = docElement2;
  end
  
  % Force a Command-Window repaint
  % Note: this is important in case the rendered str was not '\n'-terminated
  xCmdWndView.repaint;
  
end

% Process the requested style information
function style = processStyleInfo(style)
  if isnumeric(style) && length(style)==3
    style = getColorStyle(style);
  else
    error('LTPDAprintf:InvalidStyle','Invalid style - Please use a RGB color vector in the range [0 .. 255] or in the range [0.0 .. 1.0]')
  end
end

% Convert a Matlab RGB vector into a java style name (e.g., '[255,37,0]')
function styleName = getColorStyle(color)
  if all(color <= 1)
    color = int32(floor(color*255));
  else
    color = int32(floor(color));
  end
  javaColor = java.awt.Color(color(1), color(2), color(3));
  styleName = sprintf('[%d,%d,%d]',color);
  com.mathworks.services.Prefs.setColorPref(styleName, javaColor);
end

% Set an element to a particular style (color)
function setElementStyle(docElement, style)
  
  % Set the last Element token to the requested style:
  tokens = docElement.getAttribute('SyntaxTokens');
  try
    styles = tokens(2);
    styles(end) = java.lang.String(style);
  end
  
  % Correct empty URLs to be un-hyperlinkable (only underlined)
  urls = docElement.getAttribute('HtmlLink');
  try
    urlTargets = urls(2);
    for urlIdx = 1 : length(urlTargets)
      if urlTargets(urlIdx).length < 1
        urlTargets(urlIdx) = [];  % '' => []
      end
    end
  end
  
end

