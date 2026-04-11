% DISP overloads display functionality for ltpda_vector objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for ltpda_vector objects.
%
% CALL:        txt     = disp(ltpda_vector)
%
% INPUT:       ltpda_vector - an ltpda_vector object
%
% OUTPUT:      txt     - cell array with strings to display the ltpda_vector object
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  % Get ltpda_vector objects
  objs = [varargin{:}];

  % get display text
  txt = {};
  for kk=1:numel(objs)
    banner = sprintf('-------- ltpda_vector %02d ------------', kk);
    txt{end+1} = banner;

    txt{end+1} = sprintf('  data:  [%dx%d], %s', size(objs(kk).data), class(objs(kk).data));
    txt{end+1} = sprintf(' ddata:  [%dx%d], %s', size(objs(kk).ddata), class(objs(kk).ddata));
    txt{end+1} = sprintf(' units:  %s', char(objs(kk).units));
    txt{end+1} = sprintf('  name:  %s', objs(kk).name);

    banner_end(1:length(banner)) = '-';
    txt{end+1} = banner_end;

    txt{end+1} = ' ';
  end
  
  

  if nargout == 0
    for ii = 1:length(txt)
      disp(txt{ii});
    end
  else
    varargout{1} = txt;
  end

end

