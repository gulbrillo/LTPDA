
function s = prepareString(s)
  
  if ~isempty(s)
    % Convert the string into one line.
    % Attention: The method which calls this method must store the shape of
    %            the string.
    s = reshape(s, 1, []);
    
    % Replace the new line character with the new line wildcard
    s = strrep(s, sprintf('\n'), utils.xml.WILDCARD_NEWLINE);
    
    % Replace the cvs tag characters with a wildcard
    if ~isempty(s) && (s(1) == '$') && (s(end) == '$')
      s = utils.xml.prepareVersionString(s);
    end
  end
  
end
