% DISPLAYMODELOVERVIEW displays the model overview in the MATLAB browser.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISPLAYMODELOVERVIEW displays the model overview in the
%              MATLAB browser.
%
% CALL:        displayModelOverview(modelName)
%
% INPUTS:      modelName: String with the model name
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = displayModelOverview(varargin)
  
  % Check the inputs
  if nargin ~= 1
    error('### Unknown number of inputs');
  elseif ~ischar(varargin{1})
    error('### The input must be a model name (String)');
  end
  
  modelName = varargin{1};
  
  txt = modelOverview(feval(modelName, 'info'));
  
  % Workaround for the broken anchor tags in the HTML page.
  % It is necessary to write the HTML page to disk.
  dynamicHelpPath = fullfile(prefdir(), 'dynamicHelp', 'models');
  
  if ~exist(dynamicHelpPath, 'dir')
    mkdir(dynamicHelpPath);
  end

  filename = sprintf('%s.html', modelName);
  
  file = fullfile(dynamicHelpPath, filename);
  
  fid = fopen(file, 'w');
  fwrite(fid, txt, 'char');
  fclose(fid);
  
  web(file, '-new', '-noaddressbox');
  
end
