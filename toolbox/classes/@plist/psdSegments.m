% PSDSEGMENTS returns the time-series segments from a PSD plist.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PSDSEGMENTS returns the time-series segments from a PSD
%              plist. The resulting plist is suitable for passing to
%              ao/split.
% 
%              In addition to the nominal PSD plist, the input plist should
%              specify the data length (number of samples) that this will
%              be used on. 
%
% CALL:        split_pl = psdSegments(psd_pl)
% 
% 
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'psdSegments')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = psdSegments(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  pls = utils.helper.collect_objects(varargin(:), 'plist');
  
  pls_out = [];
  
  for kk=1:numel(pls)
    
    pl = pls(kk);
    

    % Parse inputs
    L            = find_core(pl, 'L');
    if isempty(L)
      error('Please specify the length of the data series that will be analysed');
    end
    
    if isa(L, 'ao')
      L = L.len;
    end
    
    pl           = utils.helper.process_spectral_options(pl, 'lin', L);
    nfft         = find_core(pl, 'Nfft');
    olap         = find_core(pl, 'Olap');
    xOlap        = round(olap*nfft/100); % Should this be round or floor?
    
    % Compute segment details    
    nSegments = fix((L - xOlap) ./ (nfft - xOlap));

    % Compute start and end indices of each segment
    segmentStep = nfft - xOlap;
    segmentStarts = 1 : segmentStep : nSegments*segmentStep;
    segmentEnds   = segmentStarts + nfft - 1;

    plo = plist(...
      'samples', reshape([segmentStarts; segmentEnds], 1, []), ...
      'mask', ones(size(segmentStarts)));
    
    pls_out = [pls_out plo];
  end
  
  % set output
  varargout{1} = copy(pls_out, 1);
  
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
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
  ii.setModifier(false);
  ii.setArgsmin(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pl = getDefaultPlist()
  
  pl = copy(plist.WELCH_PLIST, 1);
  
  % Key
  p = param({'L', 'The length of the data in samples. You can also give the target AO here.'}, paramValue.EMPTY_DOUBLE);
  p.addAlternativeKey('length');
  p.addAlternativeKey('nsamples');
  pl.append(p);  
  
end

