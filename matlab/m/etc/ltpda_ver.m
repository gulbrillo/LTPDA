function v = ltpda_ver()
% LTPDA_VER  Return LTPDA toolbox version information.
%
% Replacement for ver('LTPDA'). MATLAB R2025a no longer discovers user
% toolboxes by scanning Contents.m on the path, so ver('LTPDA') returns
% empty. This function parses Contents.m directly.
%
% Returns a struct with fields: Name, Version, Release, Date
%   (same shape as the struct returned by ver())

  persistent cached;
  if ~isempty(cached)
    v = cached;
    return;
  end

  % Default fallback values
  v.Name    = 'LTPDA Toolbox';
  v.Version = '4.0.0-PSSL';
  v.Release = '(R2025a)';
  v.Date    = '31-Mar-2026';

  % Try to find and parse Contents.m
  try
    startupFile = which('ltpda_startup');
    if ~isempty(startupFile)
      contentsFile = fullfile(fileparts(fileparts(fileparts(startupFile))), 'Contents.m');
      if exist(contentsFile, 'file')
        fid = fopen(contentsFile, 'r');
        line1 = fgetl(fid);
        line2 = fgetl(fid);
        fclose(fid);
        % Line 1: % LTPDA Toolbox
        if ischar(line1) && startsWith(strtrim(line1), '%')
          v.Name = strtrim(line1(2:end));
        end
        % Line 2: % Version 3.0.13 (R2017a) 04-08-17
        if ischar(line2)
          tok = regexp(line2, 'Version\s+(\S+)\s+(\(\S+\))\s+(\S+)', 'tokens', 'once');
          if numel(tok) == 3
            v.Version = tok{1};
            v.Release = tok{2};
            v.Date    = tok{3};
          end
        end
      end
    end
  catch
    % Silently keep fallback values
  end

  cached = v;
end
