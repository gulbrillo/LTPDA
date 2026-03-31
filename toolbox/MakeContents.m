function MakeContents(toolbox_name, version_str)
% MAKECONTENTS makes Contents file in current working directory and subdirectories
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MAKECONTENTS makes Contents file in current working directory and
%              subdirectories. MakeContents creates a standard "Contents.m" file
%              in the current directory by assembling the first comment (H1)
%              line in each function found in the current working directory. The
%              Contents file in the mean directory will also contain the H1
%              comments from the files in the subdirectories.
%              MakeContents create also Contents files in the subdirectories with
%              the H1 comments of the files in this subdirectories.
%
% CALL:        MakeContents('toolbox_name', 'Version xxx dd-mmm-yyyy');
%              MakeContents('ltpda', '0.2 (R2007a) 21-May-2007');
%
% H1 COMMENT   Function name in upper case letter (optional) plus the description
% DEFINITION:  e.g.: FUNCTION_NAME (optional) description
%
% VERSION:     $Id$
%
% HISTORY: 05-06-2007 Diepholz
%             Creation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% set default variables
if nargin < 1
  toolbox_name = 'no toolbox name';
end

if nargin < 2
  flags       = '';
  version_str = 'no version number';
end

contents_file = 'Contents.m';

percent_line(1:80) = '%';
header        = ['% Toolbox        ' toolbox_name];
version       = ['% Version        ' version_str];
contents_path = ['% Contents path  ' pwd];

fcontents_main = fopen(contents_file,'w');

fprintf(fcontents_main, '%% %s Toolbox\n', toolbox_name);
fprintf(fcontents_main, '%% Version %s\n', version_str);
fprintf(fcontents_main, '%s\n%%\n', percent_line);
fprintf(fcontents_main, '%s\n%%\n', header);
fprintf(fcontents_main, '%s\n%%\n',version);

fprintf(fcontents_main, '%s\n%%\n%%\n',contents_path);

do_list('.', fcontents_main);

fclose (fcontents_main);

return

%% Subfunction

function do_list(path_in, fcontents_main)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DO_LIST go recursive through the directories and create the
%              standart Contents "Contents.m" file.
%
% CALL:        do_list('starting_directory',  file_identifier);
%              do_list('.', fcontents_main);
%
% H1 COMMENT   Function name in upper case letter (optional) plus the description
% DEFINITION:  FUNCTION_NAME (optional) description
%
% VERSION:     $Id$
%
% HISTORY: 05-06-2007 Diepholz
%             Creation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define directory list and m-file list
dirlist  = dir(path_in);
dir_i    = [dirlist.isdir];
dirnames = {dirlist(dir_i).name};

% remove . and .. from directory list
dirnames = dirnames(~(strcmp('.', dirnames) | strcmp('..', dirnames)));

filenames = {dirlist(~dir_i).name};
mfiles = {};
% Find .m files, excluding Contents file
for f = 1:length(filenames)
  fname = filenames{f};

  [pathstr,name,ext] = fileparts(fname);

  if length(fname) > 2              && ...
     strcmp(ext, '.m')              && ...
     ~strcmpi('contents.m', fname)

    mfiles = [mfiles {fname}];
  end
end

%% Define the print directory
if strcmp(path_in, '.')
  print_dir = '';
else
  % Remove the './' from the path_in
  print_dir = [path_in(3:end) filesep];
end

%% Create Contents.m files in the current search path
fcontents     = [];
contents_file = 'Contents.m';

if ~strcmp(path_in, '.') && ~isempty(mfiles)
  fcontents = fopen([path_in filesep contents_file], 'w');
end

% Remove 'classes/@' from print_dir
% hint: Matlab have a problem to display a class path by using a relative path
if length (print_dir) > 8 && strcmp(print_dir(1:9), 'classes/@')
  print_dir = print_dir(10:end);
  header = ['%%%%%%%%%%%%%%%%%%%%   class: ' ...
             print_dir(1:end-1)              ...
            '   %%%%%%%%%%%%%%%%%%%%'];
else
  header = ['%%%%%%%%%%%%%%%%%%%%   path: ' ...
             print_dir(1:end-1)              ...
            '   %%%%%%%%%%%%%%%%%%%%'];
end

if ~isempty(mfiles)
  fprintf (fcontents_main, '%s\n%%\n', header);
  if ~isempty(fcontents)
    fprintf (fcontents     , '%s\n%%\n', header);
  end
end

maxlen = size(char(mfiles),2) + length(print_dir);

%% Each m-file in the directory
for i = 1:length(mfiles)

  %% Open the mfile to get the H1 line
  mfile = mfiles{i};
  fid=fopen(fullfile(path_in, mfile),'r');
  if fid == -1
     error(['Could not open file: ' fullfile(path_in, mfile)]);
  end

%   line = '';
%   while(isempty(line))
%     line = fgetl(fid);
%   end
% 
%   % Remove leading and trailing white spaces
%   line = strtrim(line);
% 
%   if length(line) > 7  && strcmp(line(1:8),'function') == 1,

    found = 0;
    while found < 1 && feof(fid)==0;
      line = fgetl(fid);

      %% End of file is reached
      if feof(fid)==1
        fn = [print_dir strtok(mfile,'.')];
        n  = maxlen - length(fn) - 1;
        line = ['%   ' fn blanks(n) '- (No help available)'];

        fprintf(fcontents_main,'%s\n',line);
        if ~isempty(fcontents)
          fprintf(fcontents     ,'%s\n',line);
        end

      elseif ~isempty(line)

        if ~isempty(findstr(line,'%'))
          found = found + 1;
          rr=line(2:length(line));

          % Remove leading and trailing white spaces
          rr = strtrim(rr);

          % get first word
          [tt,rr2]=strtok(line(2:length(line)));

          % Is first word equal to the m-file then remove it
          if findstr (lower(mfile), lower(tt))
            rr = rr2;
          end

          if isempty(rr)
            rr = '(No help available)';
          end
          
          fn = [print_dir strtok(mfile,'.')];
          asd = ['<a href="matlab:help ' fn '">' fn '</a>'];
          n = maxlen - length(fn) - 1;
          line = ['%   ' asd blanks(n) '- ' rr];

          fprintf(fcontents_main,'%s\n',line);
          if ~isempty(fcontents)
            fprintf(fcontents     ,'%s\n',line);
          end

        end % if ~isempty
      end % if length

    end % while
%   end % if strcmp
  fclose(fid);
end % for

if ~isempty(mfiles)
  fprintf(fcontents_main,'%%\n%%\n');
end

if ~isempty(fcontents)
  fclose (fcontents);
end

%% recurse down directory tree
for d = 1:length(dirnames)
  do_list(fullfile(path_in, dirnames{d}), fcontents_main);
end

return
