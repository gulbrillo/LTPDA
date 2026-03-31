% CHAR convert a ltpda_data-object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a ltpda_data object into a string.
%
% CALL:        string = char(fsdata)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  % Collect all ltpda_data-objects
  objs = [varargin{:}];

  %%% Add the size of the data (all)
  pstr = sprintf('Ndata = %s, %s, [%sx%s]', num2str(length(objs.x)), num2str(length(objs.yaxis.data)), num2str(size(objs.zaxis.data,1)), num2str(size(objs.zaxis.data,2)));

  varargout{1} = pstr;
end

