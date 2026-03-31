% EXPORT export the data of an analysis object to a text file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: EXPORT export the data of an analysis object to a text file.
%              The x-values will be stored in the first column of the text
%              file and the y-values the second column. 
% 
%              If the y-values are complex then stores this method the real 
%              part of the y-values in the second column and the imaginary 
%              part in the third column.
% 
%              If the analysis object has error values (dy) then these will
%              be exported in the last column.
%
% CALL:        export(a, 'blah.txt');
%              export(a, plist);
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'export')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = export(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  [pl, pl_invars, rest] = utils.helper.collect_objects(varargin(:), 'plist', in_names);

  % Combine plists
  pl = applyDefaults(getDefaultPlist, pl);

  % get filename from plist
  filename = find_core(pl, 'filename');
  if isempty(filename)
    for jj = 1:numel(rest)
      if ischar(rest{jj})
        filename = rest{jj};
        break
      end
    end
  end
  if isempty(filename)
    error('### You must specify a filename. Either directly, or in a plist');
  end

  if length(as) > 1
    error('### Export can only deal with one AO at a time.');
  end

  if isa(as.data, 'data2D') && ~isa(as.data, 'data3D')
    if isreal(as.data.getY)
      if isempty(as.dy)
        out = [as.data.getX as.data.getY];
      else
        out = [as.data.getX as.data.getY as.dy];
      end
    else
      switch pl.find_core('complex format')
        case 'absdeg'
          out = [as.data.getX abs(as.data.getY) utils.math.phase(as.data.getY)];
        case 'realimag'
          out = [as.data.getX real(as.data.getY) imag(as.data.getY)];
        case 'absrad'
          out = [as.data.getX abs(as.data.getY) angle(as.data.getY)];
        otherwise
      end
      
      if ~isempty(as.dy)
        out = [out as.dy];
      end
    end
  elseif isa(as.data, 'cdata')
    out = as.data.getY;
  else
    error('### Please code me up for the class [%s]', class(as.data));
  end

  if pl.find_core('binary')
    [path, name, ext] = fileparts(filename);
    filename = fullfile(path, [name '.mat']);
    save(filename, 'out');
  else
    [path, name, ext] = fileparts(filename);
    filename = fullfile(path, [name '.txt']);
    save(filename, 'out', '-ASCII', '-DOUBLE', '-TABS');
  end
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
  ii.setOutmin(0);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function plo = buildplist()
  plo = plist({'filename', 'The filename to export to.'}, paramValue.EMPTY_STRING);

  p = param({'complex format', 'The format to write the complex values.'}, {2, {'absdeg', 'realimag', 'absrad'}, paramValue.SINGLE});
  plo.append(p);
  
  p = param({'binary', 'Export binary mat files.'}, paramValue.FALSE_TRUE);
  plo.append(p);
  
  
end


