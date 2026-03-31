% PROG helper class for prog utility functions.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PROG is a helper class for prog utility functions.
%
% To see the available static methods, call
%
% >> methods utils.prog
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef prog

  %------------------------------------------------
  %--------- Declaration of Static methods --------
  %------------------------------------------------
  methods (Static)

 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Info call
    function ii = getInfo(varargin)
      if nargin == 0
        VERSION  = '';
        CATEGORY = 'Constructor';        
        % Build info object
        ii = minfo(mfilename, mfilename, 'ltpda', CATEGORY, VERSION, {''}, plist);
      else
        if strcmp(varargin{1}, mfilename)
          ii = utils.prog.getInfo;
        else
          ii = eval(sprintf('utils.prog.%s(''INFO'');', varargin{1}));
        end
      end
    end
    

    %-------------------------------------------------------------
    % List other methods
    %-------------------------------------------------------------
    
    s         = rstruct(varargin); % Recursive structure converter
    string    = cell2str(cellstr); % Convert a cell array to string
    out       = find_in_models(modelname,varargin);
    childrenHandles = findchildren(parentHandle,varargin)
    parentHandles   = findparent(childHandle,varargin)
    varargout = gcbsh();
    pth       = get_curr_m_file_path (m_file_name)
    fnames    = fields2list(fields)
    files     = filescan(root_dir, ext)
    dirs      = dirscan(root_dir, pattern)
    h         = funchash(fcnname)
    h         = hash(inp,meth)
    newCell   = str2cells(someString)
    cell      = strs2cells(varargin)
    ss        = rnfield(s,oldname,newname)
    out       = structcat(varargin)
    so        = strpad(varargin)
    s         = wrapstring(s, n)
    varargout = disp(varargin)
    s         = label(si)
    varargout = mcell2str(varargin)
    out       = yes2true(in)
    r         = mup2mat(r)
    output    = convertComString(varargin)
    s         = csv(x)
    bin       = obj2binary(obj)
    xml       = obj2xml(obj)
    varargout = cutString(varargin)
    varargout = issubclass(varargin)
    varargout = strjoin(varargin)
    
    varargout = mcolor2jcolor(varargin)
    varargout = jcolor2mcolor(varargin)
    
    varargout = struct2csvFile(varargin)
    varargout = csvFile2struct(varargin)
    
  end % End static methods


end

% END
