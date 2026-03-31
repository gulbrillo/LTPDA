% IPLOT calls ao/iplot on all inner ao objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: IPLOT calls ao/iplot on all inner ao objects.
%
% CALL:        obj = iplot(mat)
%              obj = mat.iplot()
%
% Note: if the matrix object does not contain AOs, then an error will be
% thrown.
%
% <a href="matlab:utils.helper.displayMethodInfo('matrix', 'iplot')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = iplot(varargin)
  
  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end
  
  % Collect all matrices and plists
  [as, matrix_invars, rest] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);
  [pl, pl_invars, rest]     = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
  
  % NOTE: don't process the user's input plists, just pass them on to ao/iplot
  % for processing.
  hFig = [];
  hAx = [];
  hLi = [];
  for kk=1:numel(bs)
    m = bs(kk);
    if isa(m.objs, 'ao')
      localObjs = [];
      for ii=1:numel(m.objs)
        localObjs = [localObjs, m.getObjectAtIndex(ii)];
      end
      [hfig, hax, hli] = iplot(localObjs, pl);
      hFig = [hFig hfig];
      hAx = [hAx hax];
      hLi = [hLi hli];
    else
      error('Input matrix %d does not contain AOs.', kk);
    end
  end
  
  % Deal with outputs
  if nargout == 1
    varargout{1} = hFig;
  end
  if nargout == 2
    varargout{1} = hFig;
    varargout{2} = hAx;
  end
  if nargout == 3
    varargout{1} = hFig;
    varargout{2} = hAx;
    varargout{3} = hLi;
  end
  
  if nargout > 3
    error('### Incorrect number of outputs');
  end
  
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  
  % get the information from ao/iplot
  aoii = ao.getInfo(mfilename());
  
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', aoii.sets, aoii.plists);
end

