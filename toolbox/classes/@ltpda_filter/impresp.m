% IMPRESP Make an impulse response of the filter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: IMPRESP Make an impulse response of the filter.
%              The input filter should be an miir or mfir object.
%
%              The response is returned as a xydata in an analysis object.
%
%              If no outputs are specified, the xydata is plotted.
%
% CALL:        a = impresp(filt, pl)
%                  impresp(filt, pl);
%
% OUTPUTS:     a - an analysis object
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_filter', 'impresp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = impresp(varargin)
  
  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  %%% get input filter
  [filts, filt_invars] = utils.helper.collect_objects(varargin(:), 'ltpda_filter', in_names);
  pl                   = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  %%% Collects parameters
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Get Number of samples
  Nsamp = find_core(pl, 'Nsamp');
  if isa(Nsamp, 'ao') && isa(Nsamp.data, 'cdata')
    % It is necessary to keep the shape
    Nsamp = Nsamp.data.y;
  end
  
  % how to process a bank?
  bank = find_core(pl, 'bank');
  
  % set samples vector
  xdat = [1:Nsamp].';
  % set input data
  idat = [1; zeros(Nsamp-1,1)];
  
  % Loop over filters
  bs = [];
  name = '';
  for jj=1:numel(filts)
    filt = filts(jj);
    
    %%% Compute filter impulse response
    num = filt(jj).a;
    
    if filt.isprop('b')
      den = filt(jj).b;
    else
      den = 1;
    end
    % makes imp resp with matlab filter
    odat = filter(num,den,idat);
    
    
    fsd = xydata(xdat, odat);
%     % set yunits = ounits./iunits
%     fsd.setXunits('Hz');
%     fsd.setYunits(filt.ounits./filt.iunits);
    % make output analysis object
    b = ao(fsd);
    % add to outputs
    switch lower(bank)
      case 'none'
        % Add history
        b.addHistory(getInfo('None'), pl, [], filt.hist);
        % set name
        b.setName(sprintf('impresp(%s)', filt_invars{jj}));
        bs = [bs b];
      case 'serial'
        if isempty(bs)
          bs = b;
          name = filt.name;
        else
          bs = bs .* b;
          name = [name '.*' filt.name];
        end
        
      case 'parallel'
        if isempty(bs)
          bs = b;
          name = filt.name;
        else
          bs = bs + b;
          name = [name '+' filt.name];
        end
      otherwise
        error('Unknown option for parameter ''bank'': %s', bank);
    end
  end
  
  if strcmpi(bank, 'parallel') || strcmpi(bank, 'serial')
    % Add history
    bs.addHistory(getInfo('None'), pl, [], [filts(:).hist]);
    % set name
    bs.setName(sprintf('impresp(%s)', name));
  end
  
  if strcmpi(bank, 'none')
    bs = reshape(bs, size(filts));
  end
  
  % Outputs
  if nargout == 0
    iplot(bs,plist('Ylabels',{'All','Amplitude'},'Xlabels',{'All','Samples'}))
  elseif nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  else
    % Single output
    varargout{1} = bs;
  end
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
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  ii.setArgsmin(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function plo = buildplist()
  plo = plist();
  
  p = param({'bank', ['How to handle a vector of input filters<br /><table>' ...
                       '<tr valign="top"><td>''<b>None</b>''</td><td>Process each filter individually</td></tr>', ...
                       '<tr valign="top"><td>''<b>Serial</b>''</td><td>Return the response of a serial filter bank</td></tr>', ...
                       '<tr valign="top"><td>''<b>Parallel</b>''</td><td>Return the response of a parallel filter bank.</td></tr>', ...
                       '</table>']}, {1, {'None', 'Serial', 'Parallel'}, paramValue.SINGLE});
  plo.append(p);
  
  p = param({'Nsamp', 'Number of samples to be calculated'}, paramValue.DOUBLE_VALUE(100));
  plo.append(p);
end

