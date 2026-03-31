% IPLOT calls ao/iplot on all inner ao objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: IPLOT calls ao/iplot on all inner ao objects.
%
% CALL:        obj = iplot(coll)
%              obj = coll.iplot()
%
% Note: if the collection object does not contain AOs, then an error will be
% thrown.
% 
% <a href="matlab:utils.helper.displayMethodInfo('collection', 'iplot')">Parameters Description</a>
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
  [as, coll_invars, rest] = utils.helper.collect_objects(varargin(:), 'collection', in_names);
  [pl, pl_invars, rest]     = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  
  % Decide on a deep copy or a modify
  bs = copy(as, nargout);
 
  % NOTE: don't process the user's input plists, just pass them on to ao/iplot
  % for processing.
  hFig = [];
  hAx = [];
  hLi = [];
  for kk=1:numel(bs)
    coll = bs(kk);
      localObjs = [];
      for ii=1:numel(coll.objs)
        obj = coll.getObjectAtIndex(ii);
        if isa(obj, 'ao')
          localObjs = [localObjs, obj];
        else
          warning('Skipping object [%s] - it is not an AO', obj.name);
        end
      end
      
      if isempty(localObjs)
        error('Input collection %d does not contain AOs.', kk);
      end
      
      [hfig, hax, hli] = iplot(localObjs, pl);
      hFig = [hFig hfig];
      hAx = [hAx hax];
      hLi = [hLi hli];
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
  aoii = ao.getInfo('iplot');  
  
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', aoii.sets, aoii.plists);
end

