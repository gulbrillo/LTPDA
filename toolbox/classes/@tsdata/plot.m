% PLOT plots the given cdata on the given axes
%
% CALL:
%         [lh, xlabel] = plot(data, ah)
%         [lh, xlabel] = plot(data, displayName, ah)
%         [lh, xlabel] = plot(data, displayName, ah, fcn)
%
%
function lh = plot(varargin)
  
  switch nargin
    case 2
      data = varargin{1};
      pi   = varargin{2};
      displayName = 'unknown';
      fcn         = 'plot';
    case 3
      data        = varargin{1};
      displayName = varargin{2};
      pi          = varargin{3};
      fcn         = 'plot';
    case 4
      data        = varargin{1};
      displayName = varargin{2};
      pi          = varargin{3};
      fcn         = varargin{4};
    otherwise
      error('Incorrect inputs');
  end
  
  % get axis handles
  ah = pi.axes;
  
  % prepare plotting function
  [f, x, y] = prepareForPlotting(data, pi.showErrors, fcn);
  
  % we need to update the toffset to be compatible with any existing t0 on
  % the axes
  xoffset = getXoffset(data.t0, ah);  
  x = x + xoffset;
  
  % plot data
  lh = f(ah, x, y);
  
  % set line display name
  set(lh, 'displayname', displayName);  
  
  % update axis labels
  xlabel(data.xunits, ah, sprintf('Origin: %s - ', char(data.t0-xoffset)));
  ylabel(data.yunits, ah, 'Value');
  
  % store t0 in the user data
  storeT0(ah, data.t0);
  
end

function xoff = getXoffset(t0, ah)
  lastT0 = getLastT0(ah);
  if isempty(lastT0)
    xoff = 0;
    return;
  end
  
  xoff = double(t0 - lastT0);
end

function storeT0(ah, t0)
  lastT0 = getLastT0(ah);
  if isempty(lastT0)
    udata = get(ah, 'UserData');
    if ~isa(udata, 'plist')
      udata = plist();
    end
    udata.pset('t0', t0);
    set(ah, 'UserData', udata);
  end
end

function lastT0 = getLastT0(ah)
  udata = get(ah, 'UserData');
  if isa(udata, 'plist')
    lastT0 = udata.find('t0');
  else
    lastT0 = [];
  end  
end

% END
