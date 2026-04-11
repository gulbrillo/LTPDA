function varargout = phasetrack(varargin)

ALGONAME = mfilename;
VERSION  = '$Id$';
CATEGORY = 'Signal Processing';

%% Check if this is a call for parameters, the CVS version string 
% or the function category
if nargin == 1 && ischar(varargin{1})
  in = char(varargin{1});
  if strcmp(in, 'Params')
    varargout{1} = getDefaultPL();
    return
  elseif strcmp(in, 'Version')
    varargout{1} = VERSION;
    return
  elseif strcmp(in, 'Category')
    varargout{1} = CATEGORY;
    return
  end
end


invars = {};
for j=1:nargin
  invars = [invars cellstr(inputname(j))];
end



as = [];
pl = [];
for j=1:nargin
  a = varargin{j};
  if isa(a, 'plist')
    pl = a;
  end
  if isa(a, 'ao')
    for k=1:length(a)
      ak = a(k);
      d = ak.data;
      if isa(d, 'tsdata')
        as = [as ak];
      else
        warning('### works only for time series');
      end
    end
  end
end
na = length(as);
% unpack parameter list
plo = plist();

% Initialise output
bo = [];

for i=1:na

  % get data out
  a = as(i);
  d = a.data;
  dinfo = whos('d');
  if ~isa(d, 'tsdata')
    error('### I only work with time-series at the moment.');
  end
  if ~isreal(d.y)
    error('### I only work with real time-series at the moment.');
  end
  add = 0;
  ydata = a.data.y;
  y = ydata;
  
  for i = 2:length(ydata)

    diff = ydata(i)-ydata(i-1);
    if diff > pi/2
        add = add-pi;
    elseif diff < -pi/2
        add = add+pi;
    end
    y(i) = ydata(i) + add;  
  end
  % Make output analysis object
  nameStr = sprintf('phasetrack(%s)', d.name);

  % create new output data
  data = tsdata(y, d.fs);
  data = set(data, 'name', nameStr);
  data = set(data, 'xunits', d.xunits);
  data = set(data, 'yunits', d.yunits);

  % create new output history
  h = history(ALGONAME, VERSION, pl, a.hist);
  h = set(h, 'invars', invars);

  % make output analysis object
  b = ao(data, h);

  % set name
  % name for this object
  if isempty(invars{j})
    n1 = a.name;
  else
    n1 = invars{j};
  end

  nameStr = sprintf('phasetrack(%s)', n1);
  b = setnh(b, 'name', nameStr);

  % Add to output array
  bo = [bo b];


end
varargout{1} = bo;

%--------------------------------------------------------------------------
% Get default params
function plo = getDefaultPL()

disp('* creating default plist...');
plo = plist();
disp('* done.');


% END


