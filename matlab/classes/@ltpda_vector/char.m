% CHAR convert a ltpda_vector object into a string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CHAR convert a ltpda_vector object into a string.
%
% CALL:        string = char(sw);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = char(varargin)

  % Collect all ltpda_vector objects
  objs = [varargin{:}];
  
  pstr = '';
  %%% Add the size of the data objects
  for kk=1:numel(objs)
    obj = objs(kk);
    pstr = [pstr sprintf('(Name=%s, Ndata=[%sx%s], Units=[%s]), ', obj.name, num2str(size(obj.data,1)), num2str(size(obj.data,2)), char(obj.units))];
  end
  
  varargout{1} = pstr;

end

