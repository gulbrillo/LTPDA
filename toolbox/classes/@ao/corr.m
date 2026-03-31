% CORR estimate linear correlation coefficients.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CORR estimate linear correlation coefficients.
%
%              The method returns a P-by-P matrix containing the pairwise
%              linear correlation coefficient between each pair of columns
%              in the N-by-P matrix X formed from the length-N vectors of
%              the P input AOs. The coefficients are calculated using
%              Pearson's product-moment method.
%
% CALL:        >> c = corr(a,b)
%              >> c = corr(a,b,c,...)
%
% INPUTS:      a,b,c,...  - input analysis objects
%
% OUTPUTS:     c    - output analysis object containing the correlation matrix.
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'corr')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = corr(varargin)
  
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
  
  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);
  
  if nargout == 0
    error('### corr cannot be used as a modifier. Please give an output variable.');
  end
  
  if numel(as) < 2
    error('### corr requires at least two input AOs to work.');
  end
  
  % Convolute the data
  smat = [];
  inunits = unit;
  name = '';
  desc = '';
  for jj=1:numel(as)
    smat = [smat as(jj).data.getY];
    inunits = inunits .* as(jj).data.yunits;
    name = strcat(name, [',' ao_invars{jj}]);
    desc = strcat(desc, [' ' as(jj).description]);
  end
  desc = strtrim(desc);
  
  % compute the sample correlation using Pearson's product-moment coefficient
  Cv = cov(smat);
  C = zeros(size(Cv));
  for ii=1:size(Cv, 1)
    for kk=1:size(Cv,2)
      C(ii,kk) = Cv(ii,kk) ./ (sqrt(Cv(ii,ii))*sqrt(Cv(kk,kk)));
    end
  end
  
  bs = ao(cdata(C));
  bs.name = sprintf('corr(%s)', name(2:end));
  bs.description = desc;
  bs.data.setYunits(inunits);
  bs.addHistory(getInfo('None'), getDefaultPlist, ao_invars, [as(:).hist]);
  
  % Set output
  if nargout == numel(bs)
    % List of outputs
    for ii = 1:numel(bs)
      varargout{ii} = bs(ii);
    end
  else
    % Single output
    varargout{1} = bs;
  end
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
  ii.setModifier(false);
  ii.setArgsmin(2);
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

function pl_default = buildplist()
  pl_default = plist.EMPTY_PLIST;
end

