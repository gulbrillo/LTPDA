% CHAR convert a tsdata object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a tsdata object into a string.
%
% CALL:        string = char(tsdata)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)
  
  % Collect all tsdata objects
  objs = [varargin{:}];
  
  % REMARK: This method can not handle multiple input objects. But even the
  %         previous version couldn't handle multiple input objects.
  
  %%% Add the size of the data
  pstr = sprintf('Ndata=[%dx%d],', size(objs.yaxis.data));
  
  %%% Add the sample rate of data
  pstr = sprintf('%s fs=%g,', pstr, objs.fs);
  
  %%% Add the length of this time-series in seconds
  pstr = sprintf('%s nsecs=%d,', pstr, objs.nsecs);
  
  %%% Add time-stamp of the first data sample
  pstr = sprintf('%s t0=%s,', pstr, char(objs.t0));
  
  %%% Add y-units
  pstr = sprintf('%s yunits=%s', pstr, char(objs.yaxis.units));
  
  varargout{1} = pstr;
end

