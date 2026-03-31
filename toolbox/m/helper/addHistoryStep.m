% ADDHISTORYSTEP Adds a history step of a non LTPDA method to  object with history.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Adds a history step of a non LTPDA method to  object with
%              history.
%
% CALL:        obj = addHistoryStep(obj, minfo, h_pl, ver, var_name, inhists, ...);
%
% INPUT:       obj:      Object with histry like AOs, SSMs, MFIRs, MIIRs, ...
%              h_pl:     Plist which should go into the history.
%              ver:      cvs version of the user defined method. Only
%                        necessary if no minfo is passed in.
%              minfo:    Information object of the function. If not defined
%                        this method will take the following:
%                        minfo(CALLED_METHOD, 'none', '', 'User defined', ver, {'Default'}, h_pl);
%              var_name: Cell-array with the variable manes of the object(s)
%              inhists:  History objects which should be add to the input
%                        object. e.g. [a.hist b.hist]
%
% REMARK:      Don't use this method inside a sub function
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = addHistoryStep(varargin)
  
  % Collect objects
  objs     = varargin{1};
  mi       = varargin{2};
  pls      = varargin{3}; 
  
  nin = nargin;
  if nin > 3, ver      = varargin{4}; else ver = ''; end
  if nin > 4, invars   = varargin{5}; else invars = {}; end
  if nin > 5, in_hists = [varargin{6:end}]; else in_hists = []; end  
  
  % addHistory(obj, minfo, h_pl, var_name, inhists, ...);
  varargout{1} = addHistory(objs, mi, pls, invars, in_hists);
end
% END