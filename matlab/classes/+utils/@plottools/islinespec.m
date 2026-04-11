function varargout = islinespec(str)
% ISLINESPEC checks a string to the line spec syntax.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: ISLINESPEC checks a string to the line spec syntax.
%
% CALL:        ret               = islinespec(str);
%              [style_array ret] = islinespec(str);
%
% REMARK:      The style_array is a cell array with the line style, marker style
%              and the color style.
%              style_array{1}: line style
%              style_array{2}: marker style
%              style_array{3}: color style
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if nargin == 0
    str = '';
  elseif nargin == 1
    if ~ischar(str)
      error('### The type of the input argument must be a ''char''.');
    end
  else
    error('### Unknown nuber of inputs.');
  end

  line_style             = {'-.', '--', '-', ':'};
  full_name_marker_style = {'square', 'diamond', 'pentagram' , 'hexagram'};
  marker_style =           {'+', 'o', 'O', '*', '.', 'x', '^', ...
                            '<', '>', 's', 'd', 'h', 'p', };
  full_name_color_style  = {'red',   'green', 'cyan',    'yellow', ...
                            'white', 'blue',  'magenta', 'black'};
  color_style            = {'r', 'g', 'c', 'y', 'w', 'b', 'm', 'k'};

  out_line_style   = '';
  out_marker_style = '';
  out_color_style  = '';

  copy_str           = str;
  found_marker_style = false;
  found_color_style  = false;

  %%%%%%%%%%   Check the line_style   %%%%%%%%%%
  for ii = 1:length(line_style)
    idx = strfind(copy_str, line_style{ii});
    if ~isempty(idx)
      copy_str = strrep(copy_str, line_style{ii}, '');
      out_line_style = line_style{ii};
      break;
    end
  end

  %%%%%%%%%%   Check full name marker style   %%%%%%%%%%
  for ii = 1:length(full_name_marker_style)
    idx = strfind(copy_str, full_name_marker_style{ii});
    if ~isempty(idx)
      copy_str = strrep(copy_str, full_name_marker_style{ii}, '');
      out_marker_style = full_name_marker_style{ii};
      found_marker_style = true;
      break;
    end
  end

  %%%%%%%%%%   Check full name color style   %%%%%%%%%%
  for ii = 1:length(full_name_color_style)
    idx = strfind(copy_str, full_name_color_style{ii});
    if ~isempty(idx)
      copy_str = strrep(copy_str, full_name_color_style{ii}, '');
      out_color_style = full_name_color_style{ii};
      found_color_style = true;
      break;
    end
  end

  %%%%%%%%%%   Check full marker style   %%%%%%%%%%
  if found_marker_style == false
    for ii = 1:length(marker_style)
      idx = strfind(copy_str, marker_style{ii});
      if ~isempty(idx)
        copy_str = strrep(copy_str, marker_style{ii}, '');
        out_marker_style = marker_style{ii};
        break;
      end
    end
  end

  %%%%%%%%%%   Check full color style   %%%%%%%%%%
  if found_color_style == false
    for ii = 1:length(color_style)
      idx = strfind(copy_str, color_style{ii});
      if ~isempty(idx)
        copy_str = strrep(copy_str, color_style{ii}, '');
        out_color_style = color_style{ii};
        break;
      end
    end
  end

  %%%%%%%%%%   Set the output   %%%%%%%%%%
  if isempty(copy_str)
    ret = true;
  else
    ret = false;
  end

  if nargout == 0 || nargout == 1
    varargout{1} = ret;
  elseif nargout == 2
    varargout{1} = ret;
    varargout{2} = {out_line_style, out_marker_style, out_color_style};
  else
    error('### Unknown numbers of outputs.');
  end

end
