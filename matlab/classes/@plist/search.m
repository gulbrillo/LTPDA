% SEARCH returns a subset of a parameter list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: SEARCH returns a subset of a parameter list.
%              Please notice that this method is just a wrapper of plist/subset.
%
% CALL:        p = search(pl, 'key')
%              p = search(pl, search_pl)
%              p = search(pl, 'key1', 'key2')
%              p = search(pl, {'key1', 'key2'})
%
% REMARK:      It is possible to use a star (*) as a wild-card.
%
% A warning is given for any key not in the original plist.
%
% <a href="matlab:utils.helper.displayMethodInfo('plist', 'search')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = search(varargin)
  
  if nargout > 0
    out = ltpda_run_method('subset', varargin{:});
    varargout = utils.helper.setoutputs(nargout, out);
  else
    ltpda_run_method('subset', varargin{:});
    varargout{1} = [varargin{:}];
  end
  
end



