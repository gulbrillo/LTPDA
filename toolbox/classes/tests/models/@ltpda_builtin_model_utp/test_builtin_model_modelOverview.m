% Test that the built-in model works with minfo/modelOverview and that the
% link exists in the help text
%

function varargout = test_builtin_model_modelOverview(varargin)
  
  utp = varargin{1};
  
  % Get the model name from the unit test plan (UTP)
  mname = utp.modelFilename;
  
  ii = feval(mname, 'info');
  html = modelOverview(ii);
  
  assert(ischar(html));
  assert(~isempty(html));
  
  % check help text
  htext = fileread([mname '.m']);
  pattern = sprintf('matlab:utils.models.displayModelOverview(''%s''', mname);
  matches = regexp(htext, pattern, 'match');
  assert(numel(matches) > 0)
  assert(~isempty(matches{1}));
  
  varargout{1} = 'Model works with minfo/modelOverview';
  
end
