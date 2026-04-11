% ADDALTERNATIVEKEY adds a key to the list of keys
% 
function addAlternativeKey(p, key)
  
  % check the key is a string
  if ~ischar(key)
    error('The specified key is not a string');
  end
  
  % check if the requested key already exists
  if any(strcmpi(key, p.key))
    error('The requested key already exists.');
  end
  
  % add the key
  p.key = [p.key cellstr(key)];
  
end