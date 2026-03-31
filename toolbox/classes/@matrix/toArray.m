% TOARRAY unpacks the objects in a matrix and places them into a MATLAB
% array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TOARRAY unpacks the objects in a matrix and places them into a MATLAB
% array.
%
% CALL:        out = toArray(in);
%
%
%
% Note: this is just a convenient wrapper around matrix/getObjectAtIndex.
% The output objects will be the result of calling matrix/getObjectAtIndex
% for the correct index. This method does not add history, instead the
% history contains the call to getObjectAtIndex.
%
% INPUTS:      in      -  input matrix object
%
% OUTPUTS:     out     -  array of output objects
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'toArray')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = toArray(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Apply defaults to plist
  pl = applyDefaults(getDefaultPlist('default'), varargin{:});
  
  % Collect all smodels and plists
  ms = utils.helper.collect_objects(varargin(:), 'matrix');
  if numel(ms) ~= 1
    error('matrix/toArray can only work on a single matrix object');
  end
  
  % check that we're either 1D or 2D
  s = ms.osize();
  if numel(s) > 2
    error('matrix/toArray only works with 1D or 2D matrix objects');
  end
  
  % first extract data into cell arra
  out = cell(s);
  n = zeros(s);
  otype = lower(pl.find('type'));
  for ii = 1:s(1)
    for jj = 1:s(2)
      switch otype
        case 'ao'
          aout(ii,jj) = ms.getObjectAtIndex(ii,jj);
        case 'doublex'
          out{ii,jj} = x(ms.getObjectAtIndex(ii,jj));
        case 'doubley'
          out{ii,jj} = y(ms.getObjectAtIndex(ii,jj));
        otherwise
      end
      % record size of this element
      n(ii,jj) = numel(out{ii,jj});
    end
  end
  
  
  
  
  % For double outputs, extract data
  if ~strcmpi(otype,'ao')
    
    % check if we need to pad
    notEven = numel(unique(n)) > 1;
    % check if we're allowed to
    doPad = pl.find('pad');
    if notEven && ~doPad
      error(['Matrix elements are not of even length. If you wish '...
        'to zero-pad shorter objects, please set the ''pad'' option ' ...
        'to true when calling matrix/toArray']);
    end
    
    %initialize
    outSize = [s max(max(n))];
    aout = zeros(outSize);
    
    % copy data
    for ii =1:outSize(1)
      for jj = 1:outSize(2)
        aout(ii,jj,1:n(ii,jj))=out{ii,jj};
      end
    end
    
    % reshape
    aout = permute(aout,[2,1,3]);
    aout = squeeze(aout);
  end
  
  % set output
  varargout{1} = aout;
  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  elseif nargin == 1 && ~isempty(varargin{1}) && ischar(varargin{1})
    sets{1} = varargin{1};
    pl = getDefaultPlist(sets{1});
  else
    sets = SETS();
    % get plists
    pl(size(sets)) = plist;
    for kk = 1:numel(sets)
      pl(kk) =  getDefaultPlist(sets{kk});
    end
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
end

%--------------------------------------------------------------------------
% Defintion of Sets
%--------------------------------------------------------------------------

function out = SETS()
  out = {...
    'default'};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist(varargin)
  persistent pl;
  persistent lastset;
  
  if nargin == 1, set = varargin{1}; else set = 'default'; end
  
  if ~exist('pl', 'var') || isempty(pl) || ~strcmp(lastset, set)
    pl = buildplist(set);
    lastset = set;
  end
  plout = pl;
end

function pl = buildplist(set)
  
  pl = plist();
  
  switch lower(set)
    case 'default'
      
      % axis
      p = param(...
        {'type',['controls type of output array.<ul>'...
        '<li>ao - xdata, time, or Fourier frequency </li>', ...
        '<li>doublex - double sourced from xdata of xydata,tsdata, or fsdata object </li>', ...
        '<li>doubley - double sourced from ydata of xydata,tsdata, or fsdata object </li>']},...
        {1, {'ao','doublex', 'doubley'}, paramValue.SINGLE});
      pl.append(p);
      
      % pad
      p = param(...
        {'pad','Use zero-padding to handle objects with uneven lengths'},...
        paramValue.FALSE_TRUE);
      pl.append(p);
      
    otherwise
      error('unrecognized set %s',set);
  end
  
  
end