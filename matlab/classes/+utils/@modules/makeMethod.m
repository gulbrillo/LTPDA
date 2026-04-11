% MAKEMETHOD prepares a new LTPDA method
%
% DESCRIPTION:  This utility creates a new LTPDA method file according to
% the standard template. It also creates a unit-test directory inheriting
% the standard tests. The tests are run at the end of the creation process.
% 
% 
% CALL:
%            utils.modules.makeMethod(extension_dir, class, name)
% 
% INPUTS:
%       extension_dir - the directory where the extension module resides
%               class - the LTPDA user-object class that this method belongs
%                       to. 
%                name - the name of the new method
% 
% If you are making a new method in an existing extension module, then a
% typical call would be:
% 
% utils.models.makeMethod('path/to/extension', ...
%                               'ao', ...
%                               'myNewMethod');
% 
% 


function makeMethod(varargin)
  
  if nargin ~= 3
    help('utils.models.makeMethod')
    error('Incorrect inputs');
  end
  
  extDir  = varargin{1};
  mclass  = varargin{2};
  mname   = varargin{3};
  
  % check mclass is one of the known LTPDA uo classes
  if ~utils.helper.isSubclassOf(mclass, 'ltpda_uoh')
    error('The specified class must be an LTPDA user-object with history subclass (i.e. a subclass of ltpda_uoh).');
  end
  
  % remove bad characters from the model name
  mname = utils.helper.genvarname(mname);
  
  % read the template file
  lines = readMethodTemplateFile(mclass, mname, extDir);
  
  % write the lines back out to the destination file
  methodfile = [mname '.m'];
  dstDir  = fullfile(extDir, 'classes', mclass);
  dstFile = fullfile(dstDir, methodfile);
  fprintf('+ Writing method file %s...\n', dstFile);
  % Check if the destination file for the new model exists
  if exist(dstFile, 'file') == 2
    r = input(sprintf('A file exists at the chosen location (%s). \nDo you want to overwrite it? (yes/no) ', dstFile), 's');
    if ~strcmpi(r, 'yes')
      return;
    end
  end
  
  if exist(dstDir, 'dir') == 0
    [success,message,messageid] = mkdir(dstDir);
    if ~success
      error('Failed to create classes directory %s [%s]', dstDir, message);
    end
  end
  
  writeFile(dstFile, lines);
  
  % read test-class template file
  lines = readTestClassTemplateFile(mclass, mname, extDir);
  
  % write test class
  fullmname = [mclass '_' mname];
  testClass = ['@test_' fullmname];
  testName = ['test_' fullmname];
  testConstructor = [testName '.m'];
  testClassPath = fullfile(extDir, 'tests', 'classes', mclass);
  testClassDir = fullfile(testClassPath, testClass);
  [success,message,messageid] = mkdir(testClassDir);
  if ~success
    error('Failed to create unit-test directory %s [%s]', testClassDir, message);
  end
  addpath(testClassPath);
  savepath;
  
  testClassFilePath = fullfile(testClassDir, testConstructor);  
  fprintf('+ Writing method test-class constructor file %s...\n', testClassFilePath);
  % Check if the destination test class file for the new model exists
  if exist(testClassFilePath, 'file') == 2
    r = input(sprintf('A file exists at the chosen location (%s). \nDo you want to overwrite it? (yes/no) ', testClassFilePath), 's');
    if ~strcmpi(r, 'yes')
      return;
    end
  end
  writeFile(testClassFilePath, lines);
  
  fprintf(1, '\n');
  fprintf(1, '--------------------------------------------------------------\n');
  fprintf(1, '\n');
  fprintf(1, 'Created method file %s\n', dstFile);
  fprintf(1, 'Created method test class at %s\n', testClassFilePath);
  fprintf(1, '\n');
  fprintf(1, 'You should now run ltpda_startup to install the new method.\n');
  fprintf(1, '\n');
  fprintf(1, 'It would also make sense to set some sensible test data in the unit-test constructor.\n');
  fprintf(1, 'The default empty object may fail some tests.\n');
  fprintf(1, '\n');
  fprintf(1, 'You can run the tests with the command:\n');
  fprintf(1, '  ltpda_test_runner.RUN_TESTS(''test_%s'')\n', fullmname);
  fprintf(1, '\n');
  fprintf(1, '--------------------------------------------------------------\n');
  
  edit(testClassFilePath);
  edit(dstFile);  
  
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

function lines = readTestClassTemplateFile(mclass, mname, extDir)
  
  % Check extDir and look for module XML file
  info = utils.modules.moduleInfo(extDir);
  
  path = fileparts(which('utils.modules.makeMethod'));
  templateFile = fullfile(path, 'method_unittest_template.m');
  lines = readFile(templateFile, mclass, mname, info.name);

end


function lines = readMethodTemplateFile(mclass, mname, extDir)
  
  % Check extDir and look for module XML file
  info = utils.modules.moduleInfo(extDir);
  
  path = fileparts(which('utils.modules.makeMethod'));
  templateFile = fullfile(path, 'method_template.m');
  lines = readFile(templateFile, mclass, mname, info.name);

end

function lines = readFile(filename, mclass, mname, modname)
  fd = fopen(filename, 'r');
  if fd < 0
    error('Failed to read template file %s', filename);
  end
  
  lines = {};
  while ~feof(fd)
    l = makeSubstitutions(fgetl(fd), mclass, mname, modname);
    lines = [lines {l}];
  end
  
  % close file
  fclose(fd);
end


function s = makeSubstitutions(s, mclass, mname, modname)
  
  s = strrep(s, '<CLASS>', mclass);
  s = strrep(s, '<METHOD>', mname);  
  s = strrep(s, '<METHOD_UPPER>', upper(mname));
  s = strrep(s, '<MODULE>', modname);
  
end

% END

