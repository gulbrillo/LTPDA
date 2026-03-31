% SUBMITFIGURE submits the given figure to an LTPDA repository.
%
% The figure is saved on disk, converted to a byte string and packed into a
% plist with the key "FIG_DATA".
%
% The plist is then uploaded to the designated repository and the
% submission plist returned to the user with the IDS field filled in.
%
% CALL:
%            utils.plottools.submitFigure(hfig)
%            utils.plottools.submitFigure(hfig, subplist)
% 
% INPUTS
%            hfig - a matlab figure handle (or object)
%        subplist - a submission plist (see help ao/submit for details)
%
% M Hewitson 2014-11-18
%
function varargout = submitFigure(varargin)
  
  
  if numel(varargin) == 0
    help(mfilename)
    error('Incorrect inputs');
  end
  
  % parse inputs
  hfig = varargin{1};
  
  if ~isgraphics(hfig)
    error('The first input should be a valid graphics handle');
  end
  
  % check the figure has valida data objects
  fig_objs = get(hfig, 'UserData');
  if isempty(fig_objs) || ~any(cellfun(@(x)isa(x, 'ltpda_uo'), fig_objs))
    error('The figure contains objects in the UserData which are not ltpda_uo subclasses');
  end
  
  % Save figure  
  fname = strcat(tempname(), '.fig');
  hgsave(hfig, fname, '-v7.3');
  
  % read back in as a byte string
  fd = fopen(fname, 'r');
  bin = fread(fd, inf, 'int8=>int8');
  fclose(fd);
  delete(fname);
  
  % pack in a plist
  pl = plist('fig_data', bin);
    
  % Submit the plist  
  
  if numel(varargin) > 1 && isa(varargin{2}, 'plist')
    subpl = varargin{2};
    sub_out = submit(pl, subpl);
  else
    sub_out = submit(pl);
  end  

  % create repo patch on plot
  utils.plottools.addRepositoryPatch(hfig, sub_out);  
  
  if nargout > 0
    varargout{1} = sub_out;
  end
  
end
% END
