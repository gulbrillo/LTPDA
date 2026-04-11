



function allFiles = addLicenseToFile(path, licenseFile)
  
  allFiles = getRecursiveAllFiles(path, {});
  
  addLicenseToSupportedExtension(allFiles, licenseFile);
  
end

function allFiles = getRecursiveAllFiles(path, allFiles)
  
  files = dir(path);
  [~, I] = sort([files.isdir]);
  files = files(I);
  
  for ff = 1:numel(files)
    
    file = files(ff);
    if file.isdir && ~strcmp(file.name(1), '.')
      allFiles = getRecursiveAllFiles(fullfile(path, file.name), allFiles);
    elseif ~file.isdir
      if exist(path, 'dir')
        allFiles = [allFiles, {fullfile(path, file.name)}];
      else
        allFiles = [allFiles, {file.name}];
      end
    end
    
  end
  
end

function addLicenseToSupportedExtension(allFiles, licenseFile)
  
  allExt = regexp(allFiles, '\.\w*$', 'match', 'once');
  
  uniqueExt = unique(lower(allExt));
  
  licenseTxt = fileread(licenseFile);
        
  for ii = 1:numel(uniqueExt)
    
    ext = lower(uniqueExt{ii});
    switch ext
      case '.m'
        
        idxM = strcmpi(allExt, '.m');
        files = allFiles(idxM);
        
        addLicenseToExtension_M(files, licenseTxt)
        
        
      otherwise
        
        fprintf(2, 'No rule for extension: [%s]', ext);
        
    end
    
  end
  
end

function addLicenseToExtension_M(files, licenseTxt)
  
  for ff = 1:numel(files)
    file = files{ff};
    txt = fileread(file);
    
    % Check here if the license already exist
    if strfind(txt, licenseTxt), continue; end
    
    if ~isempty(strfind(txt, 'classdef'))
      keyWord = 'classdef';
    else
      keyWord = 'function';
    end
    
    rep = sprintf('%s\n', licenseTxt);
    exp = sprintf('(?=^[ ]*%s)(.*)', keyWord);
    t = regexprep(txt, exp, [rep, '$1'], 'once', 'lineanchors');
    fid = fopen(file, 'w');
    c = onCleanup(@() fclose(fid));
    fwrite(fid, t);
    
  end
  
  
end


function txt = addCommentCharToLicense_M_file(txt)
  
  txt = strrep(txt, sprintf('\n'), sprintf('\n%% '));
  txt = [sprintf('\n%% ') txt];
  txt = [txt sprintf('\n')];
  
end



