% MD5 computes an MD5 checksum from an analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MD5 computes an MD5 checksum from an analysis objects.
%
% CALL:        h = md5(a)
%
% INPUTS:      a - input analysis object
%
% OUTPUTS:     h - md5 hash
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'md5')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = md5(varargin)

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
  as = utils.helper.collect_objects(varargin(:), 'ao', in_names);

  h = {};
  for ii = 1:numel(as)

    %%%%%%%%%%% Convert object to XML
    % make pointer to xml document
    xml = com.mathworks.xml.XMLUtils.createDocument('ltpda_object');
    % extract parent node
    parent = xml.getDocumentElement;
    % write obj into xml
    utils.xml.xmlwrite(as(ii), xml, parent, '');    % Save the XML document.

    h = [h cellstr(utils.prog.hash(xmlwrite(xml), 'MD5'))];

  end

  % Set outputs
  h = reshape(h, size(as));
  if numel(h) == 1
    varargout{1} = cell2mat(h);
  else
    varargout{1} = h;
  end
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
  ii.setModifier(false);
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

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end

