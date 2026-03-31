function plot_gauss_hist(varargin)
  
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
  [pli, pl_invars, rest] = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  pl = parse(pli, getDefaultPlist());

  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  % get parameters
  timestring = find(pl, 'timestring');
  % We filter out the data3D objects here since we don't know what to do
  % with them so far.
  aos = [];
  inhists = [];
  for kk=1:numel(bs)
    if isa(bs(kk).data, 'data3D')
      warning('!!! Skipping ao [%s] - can''t operate on data3D objects at the moment.', bs(kk).name);
    else
      aos = [aos bs(kk)];
      inhists = [inhists bs(kk).hist];
    end
  end
  if isempty(aos)
    error('### Please give at least one AO of type cdata or data2D');
  end
    x = aos(2).y;
    gauss_value = aos(1).y;
    stdev = aos(1).dy;
    mean_val = mean(aos(2));
    miny = find(aos(1).procinfo,'min');
    maxy = find(aos(1).procinfo,'max');
    n    = find(aos(1).procinfo,'bins');

    [ny,nx]=hist(x,n,miny,maxy);
    max_val = max(ny);
    
    yunit = aos(2).yunits.strs;
%     figure, 
    hist(x,n)
%     xlabel(sprintf(' [%s]',yunit{1}));
    ylabel('Counts');
    hold on
    plot(nx,max_val*gauss_value,'r')
    hold off
    v = axis;
    mean_value=['Mean: ',num2str(mean_val.y)];
    std_value=['Sigma: ',num2str(stdev)];
    max_value=['Max: ',num2str(max_val)];
    xper=.27;yper=.05;
    text(v(1)*xper+v(2)*(1-xper),v(3)*yper+v(4)*(1-yper),mean_value)
    yper=yper+.05;
    text(v(1)*xper+v(2)*(1-xper),v(3)*yper+v(4)*(1-yper),std_value)
    yper=yper+.05;
    text(v(1)*xper+v(2)*(1-xper),v(3)*yper+v(4)*(1-yper),max_value)
  
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
  ii = minfo(mfilename, 'ao', 'ltpda', utils.const.categories.op, '', sets, pl);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function pl_default = getDefaultPlist()
  pl_default = plist('timestring','');
end

% END
