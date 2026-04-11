
function s = recoverString(jString)
  
  s = utils.xml.mchar(jString);
  if ~isempty(s)
    % Recover the new line character.
    s = strrep(s, utils.xml.WILDCARD_NEWLINE, sprintf('\n'));
    
    % Recover the cvs tag characters
    nWILDCARD = numel(utils.xml.WILDCARD_CVS);
    if strncmp(s, utils.xml.WILDCARD_CVS, nWILDCARD) && (s(end) == '$')
      s = utils.xml.recoverVersionString(s);
    end
  end
  
end
