% RETRIEVEFIGURE retreives a figure plist from an LTPDA repository.
%
% The user passes the ID of the plist object in the LTPDA repository (the
% plist which contains the FIG_DATA key), and this function will retrieve
% it, extract the figure data, rebuild the figure and return the data
% objects and figure handle to the user.
%
% CALL:
%                         utils.plottools.retrieveFigure(repopl)
%                  hfig = utils.plottools.retrieveFigure(repopl)
%          [hfig, objs] = utils.plottools.retrieveFigure(repopl)
%
% INPUTS:
%             repopl - a repository plist (including the ID of the plist to
%                      retrieve)
%
%
% M Hewitson 2014-11-18
%
function varargout = retrieveFigure(varargin)
  
  if numel(varargin) == 0
    help(mfilename)
    error('Incorrect inputs');
  end
  
  repopl = varargin{1};
  
  if ~isa(repopl, 'plist')
    error('Invalid repository plist');
  end
  
  % Apply the defaults so that we also have the alternitive keys
  dpl = plist.FROM_REPOSITORY_PLIST();  
  repopl = applyDefaults(dpl, repopl);
  
  % retrieve the plist again
  fpl = plist(repopl);
  
  if numel(fpl) > 1
    error('This function works only for one ID')
  end
  
  if ~isa(fpl, 'plist')
    error('The retrieved object with ID %d is not a plist', fpl.find('ID'));
  end
  
  if ~isparam(fpl, 'fig_data')
    error('The retrieve plist doesn''t contain a FIG_DATA entry');
  end
  
  % recreate plot
  
  % write the bytes from the plist to a mat file
  fname = [tempname '.mat'];
  fd = fopen(fname, 'w+');
  fwrite(fd, fpl.find('fig_data'), 'int8');
  fclose(fd);
  
  % load the mat file
  hfig_retrieved = hgload(fname);
  
  % Get original AOs out of the figure UserData  
  fig_objs = get(hfig_retrieved, 'UserData');
  
  % create repo patch on plot
  utils.plottools.addRepositoryPatch(hfig_retrieved, repopl);  
  
  if nargout > 0
    varargout{1} = hfig_retrieved;
  end
  
  if nargout > 1
    varargout{2} = fig_objs;
  end
  
end
% END