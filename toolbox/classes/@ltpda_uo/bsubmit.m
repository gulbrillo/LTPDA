% BSUBMIT Submits the given collection of objects in binary form to an LTPDA repository
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Submits the given collection of objects in binary form only to an LTPDA
% repository. If multiple objects are submitted together a corresponding
% collection entry will be made.
%
% If not explicitly disabled the user will be prompt for entering submission
% metadata and for chosing the database where to submit the objects.
%
% CALL:        OUT      = bsubmit(O1, PL)
%              OUT      = bsubmit(O1, O2, PL)
%
% INPUTS:      O1, O2, ... - objects to be submitted
%              PL          - plist whih submission and repository informations
%
% OUTPUTS:     OUT     - a plist object with fields:
%                   IDS         - IDs assigned to the submitted objects
%                   CID         - ID of the collection entry
%                   UUIDS       - UUIDs of the submitted objects
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ltpda_uo', 'bsubmit')">Parameters Description</a>
%
% METADATA:
%
%   'experiment title'       - title for the submission (required >4 characters)
%   'experiment description' - description of this submission (required >10 characters)
%   'analysis description'   - description of the analysis performed (required >10 characters)
%   'quantity'               - the physical quantity represented by the data
%   'keywords'               - comma-delimited list of keywords
%   'reference ids'          - comma-delimited list object IDs
%   'additional comments'    - additional comments
%   'additional authors'     - additional author names
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = bsubmit(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);

  % just call submit with the right outputs
  out = submit(plist('binary', true), varargin{:});
  
  % pass back outputs
  if nargout > 0
    varargout{1} = out;
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist();
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
  ii.setModifier(false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function plout = getDefaultPlist()
  persistent pl;
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;
end

function plo = buildplist()
  plo = copy(plist.TO_REPOSITORY_PLIST, 1);
  
  p = param({'sinfo filename', 'Path to an XML file containing submission metadata'}, paramValue.EMPTY_STRING);
  plo.append(p);
  
end

