% GETFIRSTCOMMENTLINE returns the first comment line of a class method.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: GETFIRSTCOMMENTLINE returns the first comment line of a
%              class method.
%
% CALL:        h1 = docHelper.getFirstCommentLine(metaFcn)
%              h1 = docHelper.getFirstCommentLine(cl, fcn)
%
% INPUTS:      metaFcn - Meta data of a function
%           or
%              cl      - String of the class name
%              fcn     - String of the function name
%
% VERSION:     $Id$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function info = getFirstCommentLine(varargin)
  
  if nargin == 1
    metaFcn = varargin{1};
  elseif nargin == 2
    metaFcn = docHelper.getMetaFcnFromClAndFcn(varargin{:});
  else
    error('### Unknown number of inputs');
  end
  
  % Defile default return value
  defInfo = '(No help available)';
  
  % Open the mfile to get the H1 line
  fid=fopen(which(sprintf('%s/%s', metaFcn.DefiningClass.Name, metaFcn.Name)), 'r');
  
  if fid<0
    
    % Try to get the first line from the help. It might be that the method
    % is defined in the constructor.
    line = help(sprintf('%s/%s', metaFcn.DefiningClass.Name, metaFcn.Name));
    info = strtok(line, sprintf('\n'));
    
  else
    
    found = false;
    while ~found && ~feof(fid);
      line = fgetl(fid);
      
      if feof(fid)
        % Do nothing if we reach the end of file
        
      elseif ~isempty(line)
        
        % Check the line for a comment
        idx = strfind(line,'%');
        if ~isempty(idx)
          found = true;
          info = line(idx(1)+1:length(line));
        end % if ~isempty
      end % if length
      
    end % while
    fclose(fid);
    
  end
  
  % Remove leading and trailing white spaces
  info = strtrim(info);
  % Remove function name at the front.
  expr = sprintf('^%s[^\\w]*', metaFcn.Name);
  info = regexprep(info, expr, '', 'ignorecase');
  
  info = strtrim(info);
  if ~isempty(info)
    info(1) = upper(info(1));
  else
    info = defInfo;
  end
  
end
