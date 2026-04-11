% DISP implement terminal display for history object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP implement terminal display for history object.
%
% CALL:        txt = disp(history)
%
% INPUT:       history - history object
%
% OUTPUT:      txt     - cell array with strings to display the history object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  hists  = [varargin{:}];

  txt = utils.helper.objdisp(hists);

  if nargout == 0
    for ii=1:length(txt)
      disp(txt{ii});
    end
  end

  varargout{1} = txt;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function new_txt = single_cell(txt_field)

  new_txt = {};
  for ii=1:length(txt_field)
    if iscell(txt_field{ii})
      hh = single_cell(txt_field{ii});
      new_txt(end+1:end+length(hh)) = hh(1:end);
    else
      new_txt{end+1} = txt_field{ii};
    end
  end
end

