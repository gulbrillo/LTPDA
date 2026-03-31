% CHAR convert a ltpda_data object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a ltpda_data object into a string.
%
% CALL:        string = char(ltpda_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)
  
  % Collect all ltpda_data objects
  objs = [varargin{:}];
  
  % REMARK: This method can not handle multiple input objects. But even the
  %         previous version couldn't handle multiple input objects.
  
  %%% Add the size of the data
  pstr = sprintf('Ndata=[%dx%d],', size(objs.yaxis.data));
  
  %%% Add y-units
  pstr = sprintf('%s yunits=%s', pstr, char(objs.yaxis.units));
  
  varargout{1} = pstr;
end

