
function varargout = displayConstructorExamples(varargin)
  
  % Get the class which we want to display from the input
  cl = varargin{1};
  
  helpDir = utils.helper.getHelpPath();
  
  fileName = sprintf('constructor_examples_%s.html', cl);
  file = fullfile(helpDir, 'ug', fileName);
  web(file, '-helpbrowser');
  
end