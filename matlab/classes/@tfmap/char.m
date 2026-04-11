% CHAR convert a tfmap into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a tfmap object into a string.
%
% CALL:        string = char(tfmap)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  % Collect all ltpda_data-objects
  objs = [varargin{:}];

  %%% Add the size of the data (all)
  pstr = sprintf('Ndata = %s, %s, [%sx%s]', num2str(length(objs.x)), num2str(length(objs.y)), num2str(size(objs.z,1)), num2str(size(objs.z,2)));

  varargout{1} = pstr;
end

