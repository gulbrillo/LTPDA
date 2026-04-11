% MAKEBUILTINMODEL prepares a new built-in model template
%
% DESCRIPTION:  This utility creates a new built-in model file according to
% the standard template. It also creates a unit-test directory inheriting
% the standard built-in model tests. The tests are run at the end of the
% creation process.
% 
% 
% CALL:
%            utils.models.makeBuiltInModel(extension_dir, class, name)
% 
% INPUTS:
%       extension_dir - the directory where the extension module resides
%               class - the LTPDA user-object class that this model belongs
%                       to. 
%                name - the name of the new model
% 
% If you are making a new model in an existing extension module, then a
% typical call would be:
% 
% utils.models.makeBuiltInModel('path/to/extension', 'ao', 'myNewModel');
% 
% 

function makeBuiltInModel(varargin)
  
  if nargin ~= 3
    help('utils.models.makeBuiltInModel')
    error('Incorrect inputs');
  end
  
  extDir  = varargin{1};
  mclass  = varargin{2};
  mname   = varargin{3};
  module  = utils.modules.moduleInfo(extDir).name;
  
  % check mclass is one of the known LTPDA uo classes
  if ~utils.helper.isSubclassOf(mclass, 'ltpda_uo')
    error('The specified class must be an LTPDA user-object subclass (i.e. a subclass of ltpda_uo).');
  end
  
  %%%%%   Create model template
  
  % remove bad characters from the model name
  mname = utils.helper.genvarname(mname);
  
  % read the template file
  lines = readModelTemplateFile(mclass, mname, module);
  
  % write the lines back out to the destination file
  fullmname = [mclass '_model_' mname];
  mdlfile = [fullmname '.m'];
  dstDir  = fullfile(extDir, 'models', mclass);
  dstFile = fullfile(dstDir, mdlfile);
  fprintf('+ Writing model file %s...\n', dstFile);
  % Check if the destination file for the new model exists
  if exist(dstFile, 'file') == 2
    r = input(sprintf('A file exists at the chosen location (%s). \nDo you want to overwrite it? (yes/no) ', dstFile), 's');
    if ~strcmpi(r, 'yes')
      return;
    end
  end
  [success, message] = mkdir(dstDir);
  if ~success
    error('Failed to create model directory %s [%s]', dstDir, message);
  end
  addpath(dstDir);
  savepath;
  writeFile(dstFile, lines);
  
  %%%%%   Check if the unit test class (TCM_<module>_Misc_<CLASS>) already exist for the model
  testClass = sprintf('TCM_%s_Misc_%s', strrep(module, '_Module', ''), mclass);
  testClassPath = fullfile(extDir, 'tests', 'modelUnitTests', mclass);
  testClassDir = fullfile(testClassPath, strcat('@', testClass));
  if ~exist(testClass, 'class')
    [success, message] = mkdir(testClassDir);
    if ~success
      error('Failed to create unit-test directory %s [%s]', testClassDir, message);
    end
    
    % read template for the TestCaseModel class
    lines = readClassTestCaseModelTemplateFile(mclass, strrep(module, '_Module', ''));
    testClassFileName = fullfile(testClassDir, strcat(testClass, '.m'));
    writeFile(testClassFileName, lines);
    
    % Add path to MATLAB's path
    addpath(genpath(testClassPath));
    savepath;
    
  end
  
  
  %%%%%   Create unit test
  
  % read test-class template file
  lines = readTestClassTemplateFile(mclass, mname);
  
  % write test class
  testName = strcat('test_', fullmname);
  testSuite = [testName '.m'];
  addpath(testClassPath);
  savepath;
  
  testClassFilePath = fullfile(testClassDir, testSuite);  
  fprintf('+ Writing model test-class constructor file %s...\n', testClassFilePath);
  % Check if the destination test class file for the new model exists
  if exist(testClassFilePath, 'file') == 2
    r = input(sprintf('A file exists at the chosen location (%s). \nDo you want to overwrite it? (yes/no) ', testClassFilePath), 's');
    if ~strcmpi(r, 'yes')
      return;
    end
  end
  writeFile(testClassFilePath, lines);
  
  fprintf(2, 'Created model file %s\n', dstFile);
  fprintf(2, 'Created model test file  %s\n', testClassFilePath);
  fprintf(2, 'Run the unit tests with the commands:\n');
  fprintf(2, '  mc();\n');
  fprintf(2, '  utc = %s;\n', testClass);
  fprintf(2, '  r   = utc.run(''%s'');\n', testName);
  
  edit(dstFile);
  edit(testClassFilePath);
  
end

function writeFile(filename, lines)
  fd = fopen(filename, 'w+');
  if fd < 0
    error('Could not open destination file for writing: %s', filename);
  end
  
  for kk=1:numel(lines)
    l = lines{kk};
    fprintf(fd, '%s\n', l);
  end
  
  fclose(fd);
  
  fprintf('   - wrote model file %s\n', filename);
end

function lines = readTestClassTemplateFile(mclass, mname)
  
  path = fileparts(which('utils.models.makeBuiltInModel'));
  templateFile = fullfile(path, 'template_built_in_model_unittest.m');
  lines = readFile(templateFile, mclass, mname, '');

end

function lines = readModelTemplateFile(mclass, mname, module)
  
  path = fileparts(which('utils.models.makeBuiltInModel'));
  templateFile = fullfile(path, 'template_built_in_model.m');
  lines = readFile(templateFile, mclass, mname, module);
  
end

function lines = readClassTestCaseModelTemplateFile(mclass, module)
  
  path = fileparts(which('utils.models.makeBuiltInModel'));
  templateFile = fullfile(path, 'template_class_TestCaseModel.m');
  lines = readFile(templateFile, mclass, '', module);
  
end

function lines = readFile(filename, mclass, mname, module)
  fd = fopen(filename, 'r');
  if fd < 0
    error('Failed to read template file %s', filename);
  end
  
  lines = {};
  while ~feof(fd)
    l = makeSubstitutions(fgetl(fd), mclass, mname, module);
    lines = [lines {l}];
  end
  
  % close file
  fclose(fd);
end


function s = makeSubstitutions(s, mclass, mname, module)
  
  s = strrep(s, '<CLASS>', mclass);
  s = strrep(s, '<NAME>', mname);
  s = strrep(s, '<MODULE>', module);
  
end

% END

