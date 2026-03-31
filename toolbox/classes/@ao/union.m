% UNION overloads the union operator for Analysis Objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: UNION overloads the union operator for Analysis
%              Objects.
%
% CALL:        out = union(a1, a2);
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'union')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = union (varargin)

% Check if this is a call for parameters
if utils.helper.isinfocall(varargin{:})
  varargout{1} = getInfo(varargin{3});
  return
end

% Collect input variable names
in_names = cell(size(varargin));
try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

% Collect all AOs
[as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
pl              = utils.helper.collect_objects(varargin(:), 'plist');

% Check input arguments number
if length(as) ~= 2
  error ('### Incorrect inputs. This method needs two input AOs.');
end

% make sure we have an output argument
if nargout == 0
  error('### Union cannot be used as a modifier. Please give an output variable.');
end

% Check that data types match
if ~strcmpi(class(as(1).data),class(as(2).data))
  error('### Union requires two inputs with the same data type');
end

% Check that xunits types match
if as(1).xunits ~= as(2).xunits
  error('### Union requires two inputs with the same xunits');
end

% Check that yunits types match
if as(1).yunits ~= as(2).yunits
  error('### Union requires two inputs with the same yunits');
end

% Combine input PLIST with default PLIST
pl = applyDefaults(getDefaultPlist(), pl);

% switch on data type
switch class(as(1).data)
  case {'tsdata','xydata','fsdata'}
    % compute union of x data
    xunion = union(as(1).x,as(2).x);
    
    % copy relevant other data from the two objects
    idx1 = 1;
    idx2 = 1;
    yunion = zeros(size(xunion));
    
    for ii = 1:numel(xunion)
      if xunion(ii) == as(1).x(idx1)
        yunion(ii) = as(1).y(idx1);
        idx1 = idx1+1;
      elseif xunion(ii) == as(2).x(idx2)
        yunion(ii) = as(2).y(idx2);
        idx2 = idx2+1;
      end
    end
    
    % object plist
    obj_pl = plist(...
      'type',class(as(1).data),...
      'xvals',xunion,...
      'xunits',as(1).xunits,...
      'yvals',yunion,...
      'yunits',as(1).yunits,...
      'name',['union(', as(1).name, ',', as(2).name, ')']);
    
    
    switch class(as(1).data)
      case 'tsdata'
        obj_pl.pset('fs',as(1).fs);
        if xunion(1) == as(1).x(1)
          obj_pl.pset('toffset',as(1).toffset);
          obj_pl.pset('t0',as(1).t0);
        else
          obj_pl.pset('toffset',as(2).toffset);
          obj_pl.pset('t0',as(2).t0);
        end
      case 'fsdata'
        obj_pl.pset('fs',as(1).fs);
    end
    
    %build object
    out = ao(obj_pl);
    
  case 'cdata'
    % compute union of x data
    yunion = union(as(1).y,as(2).y);
    
    % object plist
    obj_pl = plist(...
      'type','cdata',...
      'vals',yunion,...
      'yunits',as(1).yunits,...
      'name',['union(', as(1).name, ',', as(2).name, ')']);
    
    %build object
    out = ao(obj_pl);
    
end



% Set output
varargout{1} = out;
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
ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pl);
ii.setModifier(false);
ii.setArgsmin(2);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
persistent pl;
if ~exist('pl', 'var') || isempty(pl)
  pl = buildplist();
end
plout = pl;
end

function out = buildplist()
out = plist();


end

