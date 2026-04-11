% FIL a wrapper for the LISO fil executable.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FIL a wrapper for the LISO fil executable.
%
% CALL:        utils.bin.fil('foo.fil')
%              utils.bin.fil('foo.fil', 'foo2.fil', 'foo3.fil', ...)
%              utils.bin.fil('foo.fil', 'foo2.fil', 'foo3.fil', '-c', ...)
%
%              >> a = utils.bin.fil('foo.fil') % get result as AO
%              >> f = utils.bin.fil('foo_iir.fil') % get result as MIIR 
% 
%              >> utils.bin.fil % get fil help
% 
% INPUTS:
%          'filename'  - one or more .fil filenames
%          'option'    - pass options to fil
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = fil(varargin)

  % Get my location
  p = mfilename('fullpath');
  p = p(1:end-length(mfilename));
  
  switch computer
    case 'MACI'
      LISO = fullfile(p, 'liso/maci');
      % Point to fil binary
      FIL = ['LISO_DIR="' LISO '" ' fullfile(LISO, 'fil')];
    case 'PCWIN'
      LISO = fullfile(p, 'liso/win32');
      % Point to fil binary
      FIL = ['LISO_DIR="' LISO '" ' fullfile(LISO, 'fil.exe')];
    otherwise
      error('### I do not have a binary for LISO on %s', computer)
  end
  
  if nargin == 0
    system(FIL);
    return
  end
  
  % Loop for any options first
  opts = '';
  for jj=1:nargin
    if ischar(varargin{jj})
      if varargin{jj}(1) == '-'
        opts = [opts ' -n ' varargin{jj}];
      end
    end
  end
  
  % Now loop over input files
  outs = {};
  for jj=1:nargin
    if ischar(varargin{jj})
      % is this a filename or an option?
      if varargin{jj}(1) ~= '-'
        % Check the file
        filename = varargin{jj};        
        [path, name, ext] = fileparts(filename);
        if ~strcmp(ext, '.fil')
          error('### The input filename does not appear to be a fil file. [%s]', filename);
        end
        
        % run FIL
        cmd = [FIL ' ' opts ' ' filename];
        disp(['*** running: ' cmd]);
        [status, result] = system(cmd);
        disp(result)
      
        if status
        else
          % try to load the output file
          outfile = fullfile('.', path, [name '.out']);
          if exist(outfile, 'file')
            % What type of LISO output do we get here?
            
            min = textread(filename,'%s');
            
            % look for keywords in file
            tfoutput = false;
            iir = false;
            fit = false;
            if any(strcmp('tfoutput', min)), tfoutput = true; end
            if any(strcmp('iir', min)), iir = true; end
            if any(strcmp('fit', min)), fit = true; end

            if iir
              % we have an IIR filter so we load that instead of the .out
              % file
              filt = miir(filename);
              if ~isempty(filt.a)
                if nargout == 0
                  iplot(resp(filt));
                else
                  outs = [outs {filt}];
                end
              end
            elseif fit || tfoutput
              % load data
              fid = fopen(outfile, 'r');
              
              % Look for the first line of data
              comment_char = '#';
              while ~feof(fid)
                f = strtrim(fgetl(fid));
                if ~isempty(f)
                  if f(1) ~= comment_char
                    break;
                  end
                end
              end

              % Scan it to find how many columns we have in the file
              c = regexp(f, ' +', 'split');
              nc = numel(c);
              scanformat = repmat('%f ', 1, nc);

              % rewind file
              fseek(fid, 0, 'bof');
              % Read all data
              din = textscan(fid, scanformat, 'CommentStyle', comment_char, 'CollectOutput', 1);
              % close file
              fclose(fid);
              % did we get data?
              if ~isempty(din{1})
                din = din{1};
                if tfoutput
                  % what kind of columns do we have?
                  dbdeg  = false;
                  reim   = false;
                  absdeg = false;
                  if any(strcmp('db:deg', min)), dbdeg = true; end
                  if any(strcmp('re:im', min)), reim = true; end
                  if any(strcmp('abs:deg', min)), absdeg = true; end
                  if dbdeg
                    disp('-- TF is in db:deg');
                    amp = 10.^(din(:,2)/20) .* exp(1i*din(:,3)*pi/180);
                  elseif reim
                    disp('-- TF is in re:im');
                    amp = complex(din(:,2), din(:,3));
                  elseif absdeg
                    disp('-- TF is in abs:deg');
                    amp = din(:,2) .* exp(1i*din(:,3)*pi/180);
                  else
                    error('### unknown data format. I only understand: abs:deg, db:deg, re:im, at the moment');
                  end
                else
                  % we need to look for nout:
                  dbdeg  = false;
                  reim   = false;
                  absdeg = false;
                  abs    = false;
                  db     = false;
                  re     = false;
                  im     = false;
                  if any(strcmp('nout:db:deg', min)), dbdeg = true; end
                  if any(strcmp('nout:re:im', min)), reim = true; end
                  if any(strcmp('nout:abs:deg', min)), absdeg = true; end
                  if any(strcmp('db', min)), db = true; end
                  if any(strcmp('re', min)), re = true; end
                  if any(strcmp('im', min)), im = true; end
                  if any(strcmp('abs', min)), abs = true; end
                  if dbdeg
                    amp = 10.^(din(:,2)./20) .* exp(1i*din(:,3)*pi/180);
                    disp('-- Fit is in db:deg');
                  elseif reim
                    amp = complex(din(:,2), din(:,3));
                    disp('-- Fit is in re:im');
                  elseif absdeg
                    amp = din(:,2) .* exp(1i*din(:,3)*pi/180);
                    disp('-- Fit is in abs:deg');
                  elseif abs || re || im
                    amp = din(:,2);
                  elseif db
                    amp = 10.^(din(:,2)/20);
                  else
                    error('### unknown data format. I only understand: abs:deg, db:deg, re:im, at the moment');
                  end
                  
                end
                % build output AO
                a = ao(din(:,1), amp);
                a.setName(name);
                a.setXunits('Hz');
                outs = [outs {a}];
              end
            else
              warning('### unknown output type');
            end % End switch over output type
          end % If output file exists
        end % If command suceeded
      end % If is a fil file
    end % char argument
  end % loop over args  
  
  if nargout == 0
    % do nothing
  elseif nargout == numel(outs)
    varargout{:} = outs{:};
  elseif nargout == 1
    allSame = true;
    for jj=2:numel(outs)
      if ~strcmp(class(outs{1}), class(outs{jj}))
        allSame = false;
      end
    end
    if allSame
      varargout{1} = [outs{:}];
    else
      varargout{1} = outs;
    end
  else
    error('### Unknown outputs');
  end
  
end

