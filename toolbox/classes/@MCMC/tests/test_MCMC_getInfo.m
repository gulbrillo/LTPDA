%
% Tests the minfo object
%
function test_MCMC_getInfo(~)
  
  message = 'Pass';
  
  % Some keywords
  clss = 'MCMC';
  mthd = 'MCMC';
  
  try
    % Call for no sets
    io(1) = eval([clss '.getInfo(''' mthd ''', ''None'')']);
    % Call for all sets
    io(2) = eval([clss '.getInfo(''' mthd ''')']);
    % Call for each set
    for kk=1:numel(io(2).sets)
      io(kk+2) = eval([clss '.getInfo(''' mthd ''', ''' io(2).sets{kk} ''')']);
    end
    result = true;
  catch err
    result = false;
    message = sprintf('Fail. Error message: %s', err.message);
  end
  
  if ~isempty(io(1).sets),                     result = false; end
  if ~isempty(io(1).plists),                   result = false; end
  if ~any(strcmpi(io(2).sets, 'Default')),     result = false; end
  if numel(io(2).plists) ~= numel(io(2).sets), result = false; end
  
  assert(result, message)
  
end